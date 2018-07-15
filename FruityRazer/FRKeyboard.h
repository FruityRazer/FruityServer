//
//  FRKeyboard.h
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

#import <Foundation/Foundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>

#import "FRRGB.h"
#import "FRCommon.h"
#import "FRDevice.h"

@interface FRKeyboard : NSObject <FRDevice> {
    NSMutableArray<NSMutableArray<FRRGB *> *> *_colors;
    IOUSBDeviceInterface **_dev;
}

- (instancetype)initWithDeviceInterface:(IOUSBDeviceInterface **)deviceInterface;

- (void)setColor:(FRRGB *)color;
- (void)setColor:(FRRGB *)color forRow:(int)row;
- (void)setColor:(FRRGB *)color forKey:(FRKeyIndex *)key;

- (BOOL)updateDeviceState;

@end
