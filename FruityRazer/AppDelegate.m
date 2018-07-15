//
//  AppDelegate.m
//  FruityRazer
//
//  Created by Eduardo Almeida on 09/07/18.
//  Copyright © 2018 Eduardo Almeida. All rights reserved.
//

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Should you need to contact me, the author, you can do so by
 * e-mail - Eduardo Almeida <hello [_at_] edr [_dot_] io>
 */

#import "AppDelegate.h"

#import "DeviceQuery.h"

#import "razercommon.h"
#import "razerkbd_driver.h"

#import "RazerSoftwareChroma.h"

#import "FRBaseStation.h"
#import "FRKeyboard.h"

#define RAZER_DIRECTION_LEFT   0x31
#define RAZER_DIRECTION_RIGHT  0x32

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.server = [[CRHTTPServer alloc] init];
    
    [self setRoutes];
    
    [self.server startListening:nil portNumber:24577];
}

- (NSData *)createErrorResponseFromError:(NSError *)error {
    NSDictionary *dict = @{
                           @"success": @false,
                           @"error": error.description
                          };
    
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

- (void)handleSynapse2ReadWithDevice:(razer_device)device error:(NSError **)error {
#warning TODO: This!
    
    IOUSBDeviceInterface **dev = dq_get_device(device.usbId);
    
    
    
    dq_close_device(dev);
}

- (BOOL)handleSynapse2WriteWithDevice:(razer_device)device request:(CRRequest * _Nonnull)request error:(NSError **)error {
    IOUSBDeviceInterface **dev = dq_get_device(device.usbId);
    
    NSDictionary *data = request.body;
    
    if (data[@"type"]) {
        if ([data[@"type"] isEqual:@"wave"]) {
            char direction = RAZER_DIRECTION_LEFT;
            
            if ([data[@"direction"] isEqual:@"right"])
                 direction = RAZER_DIRECTION_RIGHT;
            
            razer_attr_write_mode_wave(dev, &direction, 1);
        } else if ([data[@"type"] isEqual:@"spectrum"]) {
            char direction = RAZER_DIRECTION_LEFT;
            
            if ([data[@"direction"] isEqual:@"right"])
                direction = RAZER_DIRECTION_RIGHT;
            
            razer_attr_write_mode_spectrum(dev, &direction, 1);
        } else if ([data[@"type"] isEqual:@"reactive"]) {
            UInt8 speed = [data[@"speed"] intValue];
            
            FRRGB *color = [[FRRGB alloc] initWithRed:0 green:0 blue:0];
            
            if (data[@"color"])
                color = [[FRRGB alloc] initWithHex:data[@"color"]];
            
            char c[4] = { speed, color.r, color.g, color.b };
            
            razer_attr_write_mode_reactive(dev, c, 4);
        } else if ([data[@"type"] isEqual:@"static"]) {
            FRRGB *color = [[FRRGB alloc] initWithRed:0 green:0 blue:0];
            
            if (data[@"color"])
                color = [[FRRGB alloc] initWithHex:data[@"color"]];
            
            void *c = color.RGBArray;
            
            {
                razer_attr_write_mode_static(dev, c, 3);
            }
            
            free(c);
        } else if ([data[@"type"] isEqual:@"breath"]) {
            FRRGB *color = [[FRRGB alloc] initWithRed:0 green:0 blue:0];
            
            if (data[@"color"])
                color = [[FRRGB alloc] initWithHex:data[@"color"]];
            
            void *c = color.RGBArray;
            
            {
                razer_attr_write_mode_breath(dev, c, 3);
            }
            
            free(c);
        }
    }
    
    dq_close_device(dev);
    
    return false;
}

- (BOOL)handleSynapse3WriteWithDevice:(razer_device)device request:(CRRequest * _Nonnull)request error:(NSError **)error {
    IOUSBDeviceInterface **dev = dq_get_device(device.usbId);
    
    bool ret = false;
    
    switch (device.type) {
        case keyboard: {
            FRKeyboard *keyboard = [[FRKeyboard alloc] initWithDeviceInterface:dev];
            
            NSDictionary *data = request.body;
            
            if (data[@"type"] && [data[@"type"] isEqual:@"raw"]) {
                NSArray *rows = data[@"rows"];
                
                for (int i = 0; i < rows.count; i++) {
                    NSArray *row = rows[i];
                    
                    for (int j = 0; j < row.count; j++) {
                        FRKeyIndex key = { .row = i, .column = j };
                        
                        [keyboard setColor:[[FRRGB alloc] initWithHex:row[j]] forKey:&key];
                    }
                }
                
                [keyboard updateDeviceState];
            }
            
            ret = true;
            
            break;
        }
            
        case misc_basestation: {
            FRBaseStation *bs = [[FRBaseStation alloc] initWithDeviceInterface:dev];
            
            NSDictionary *data = request.body;
            
            if (data[@"type"] && [data[@"type"] isEqual:@"raw"]) {
                NSArray *parts = data[@"parts"];
                
                for (int i = 0; i < parts.count; i++)
                    [bs setColor:[[FRRGB alloc] initWithHex:parts[i]] forPart:i];
                
                [bs updateDeviceState];
            }
            
            ret = true;
            
            break;
        }
            
        default:
            break;
            
    }
    
    dq_close_device(dev);
    
    return ret;
}

- (BOOL)checkAuthorizationWithRequest:(CRRequest * _Nonnull)request response:(CRResponse * _Nonnull)response completionHandler:(CRRouteCompletionBlock  _Nonnull)completionHandler {
    bool authorized = true;
    
    if (self.key) {
        NSString *receivedKey = request.allHTTPHeaderFields[@"X-FruityRazer-Key"];
        
        authorized = (receivedKey && [self.key isEqual:receivedKey]);
    }
    
    if (!authorized) {
        [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @false, @"error": @"UNAUTHORIZED"} options:0 error:nil]];
        
        completionHandler();
    }
    
    return authorized;
}

- (void)setRoutes {
    [self.server add:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        [response setValue:[NSBundle mainBundle].bundleIdentifier forHTTPHeaderField:@"Server"];
        [response setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [response setValue:request.allHTTPHeaderFields[@"Origin"] forHTTPHeaderField:@"Access-Control-Allow-Origin"];
        [response setValue:@"GET, POST, PUT, HEAD" forHTTPHeaderField:@"Access-Control-Allow-Methods"];
        [response setValue:request.allHTTPHeaderFields[@"Access-Control-Request-Headers"] forHTTPHeaderField:@"Access-Control-Allow-Headers"];
        
        completionHandler();
    }];
    
    [self.server options:nil block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        [response send:@""];
        
        completionHandler();
    }];
    
    [self.server get:@"/devices" block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        if (![self checkAuthorizationWithRequest:request response:response completionHandler:completionHandler])
            return;
        
        razer_device_r deviceList = dq_get_device_list();
        
        NSMutableArray<NSDictionary *> *retArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < deviceList.length; i++) {
            razer_device d = deviceList.devices[i];
            
            NSDictionary *dict = @{
                                   @"shortName": [NSString stringWithUTF8String:d.shortName],
                                   @"fullName": [NSString stringWithUTF8String:d.fullName],
                                   @"connected": @(dq_check_device_connected(d.usbId))
                                  };
            
            [retArray addObject:dict];
        }
        
        NSError *error = nil;
        
        NSData *json = [NSJSONSerialization dataWithJSONObject:@{@"devices": retArray} options:0 error:&error];
        
        if (error)
            [response sendData:[self createErrorResponseFromError:error]];
        else
            [response sendData:json];
        
        completionHandler();
    }];
    
    [self.server get:@"/devices/:shortName/lighting" block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        if (![self checkAuthorizationWithRequest:request response:response completionHandler:completionHandler])
            return;
        
        NSString *shortName = request.query[@"shortName"];
        
        razer_device_r deviceList = dq_get_device_list();
        
        for (int i = 0; i < deviceList.length; i++) {
            razer_device d = deviceList.devices[i];
            
            if ([shortName isEqualToString:[NSString stringWithUTF8String:d.shortName]]) {
                BOOL connected = dq_check_device_connected(d.usbId);
                
                if (!connected) {
                    [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @false, @"error": @"NOT_CONNECTED"} options:0 error:nil]];
                    
                    break;
                }
                
                NSError *error = nil;
                
                if (d.synapse != synapse2)
                    [self handleSynapse2ReadWithDevice:d error:&error];
                else
                    [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @false, @"error": @"NOT_SUPPORTED"} options:0 error:nil]];
                
                if (error)
                    [response sendData:[self createErrorResponseFromError:error]];
                else
                    [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @true} options:0 error:&error]];
            }
        }
        
        completionHandler();
    }];
    
    [self.server post:@"/devices/:shortName/lighting" block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        if (![self checkAuthorizationWithRequest:request response:response completionHandler:completionHandler])
            return;
        
        NSString *shortName = request.query[@"shortName"];
        
        razer_device_r deviceList = dq_get_device_list();
        
        for (int i = 0; i < deviceList.length; i++) {
            razer_device d = deviceList.devices[i];
            
            if ([shortName isEqualToString:[NSString stringWithUTF8String:d.shortName]]) {
                BOOL connected = dq_check_device_connected(d.usbId);
                
                if (!connected) {
                    [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @false, @"error": @"NOT_CONNECTED"} options:0 error:nil]];

                    break;
                }
                
                NSError *error = nil;
                
                if (d.synapse == synapse2)
                    [self handleSynapse2WriteWithDevice:d request:request error:&error];
                else
                    [self handleSynapse3WriteWithDevice:d request:request error:&error];
                
                if (error)
                    [response sendData:[self createErrorResponseFromError:error]];
                else
                    [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @true} options:0 error:&error]];
            }
        }
        
        completionHandler();
    }];
    
    [self.server get:@"/key" block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        if (self.key)
            [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @false} options:0 error:nil]];
        else {
            self.key = [[NSProcessInfo processInfo] globallyUniqueString];
            
            [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"success": @true, @"key": self.key} options:0 error:nil]];
        }
        
        completionHandler();
    }];
    
    [self.server get:@"/" block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        [response sendData:[NSJSONSerialization dataWithJSONObject:@{@"app": @"FruityRazer (Driver)", @"version": [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]} options:0 error:nil]];
        
        completionHandler();
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
