//
//  FRHyperflux.h
//  FruityRazer
//
//  Created by Eduardo Almeida on 19/03/19.
//  Copyright © 2019 Eduardo Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>

#import "FRRGB.h"
#import "FRCommon.h"
#import "FRDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRHyperflux : NSObject <FRDevice> {
    NSMutableArray<FRRGB *> *_colors;
    IOUSBDeviceInterface **_dev;
}

- (instancetype)initWithDeviceInterface:(IOUSBDeviceInterface **)deviceInterface;

- (void)setColor:(FRRGB *)color;
- (void)setColor:(FRRGB *)color forPart:(int)part;

- (BOOL)updateDeviceState;

@end

NS_ASSUME_NONNULL_END
