//
//  FRBaseStation.m
//  FruityRazer
//
//  Created by Eduardo Almeida on 14/07/18.
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

#import "FRBaseStation.h"

#import "RazerSoftwareChroma.h"

@implementation FRBaseStation

- (instancetype)initWithDeviceInterface:(IOUSBDeviceInterface **)deviceInterface {
    if (self = [super init]) {
        _colors = [[NSMutableArray alloc] init];
        
        for (int i = 0; i <= 14; i++)
            [_colors addObject:[[FRRGB alloc] initWithRed:0 green:0 blue:0]];
        
        _dev = deviceInterface;
    }
    
    return self;
}

- (void)setColor:(FRRGB *)color {
    for (int i = 0; i <= 14; i++)
        [self setColor:color forPart:i];
}

- (void)setColor:(FRRGB *)color forPart:(int)part {
    _colors[part] = color;
}

- (BOOL)updateDeviceState {
    char *parts = calloc(78, sizeof(char));
    
    for (int i = 0; i <= 14; i++) {
        parts[(i * 3)] = _colors[i].r;
        parts[(i * 3) + 1] = _colors[i].g;
        parts[(i * 3) + 2] = _colors[i].b;
    }
    
    razer_base_station_pre(_dev);
    razer_base_station_set_colors(_dev, parts);
    
    return true;
}

@end
