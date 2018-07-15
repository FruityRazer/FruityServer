//
//  FRRGB.m
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

#import "FRRGB.h"

@implementation FRRGB

- (instancetype)initWithRed:(UInt8)red green:(UInt8)green blue:(UInt8)blue {
    if (self = [super init]) {
        _r = red;
        _g = green;
        _b = blue;
    }
    
    return self;
}

- (instancetype)initWithHex:(NSString *)hex {
    if (self = [super init]) {
        NSException *invalidInputException = [NSException exceptionWithName:@"EXC_INVALID_INPUT" reason:@"The inserted input is invalid." userInfo:nil];
        
        if (hex.length != 6 && hex.length != 7)
            @throw invalidInputException;
        
        if (hex.length == 7) {
            if (![[hex substringWithRange:NSMakeRange(0, 1)] isEqual:@"#"])
                @throw invalidInputException;
            
            hex = [hex substringWithRange:NSMakeRange(1, 6)];
        }
        
        NSString *redComponent = [hex substringWithRange:NSMakeRange(0, 2)];
        NSString *greenComponent = [hex substringWithRange:NSMakeRange(2, 2)];
        NSString *blueComponent = [hex substringWithRange:NSMakeRange(4, 2)];
        
        _r = strtoull(redComponent.UTF8String, NULL, 16);
        _g = strtoull(greenComponent.UTF8String, NULL, 16);
        _b = strtoull(blueComponent.UTF8String, NULL, 16);
    }
    
    return self;
}

- (void *)RGBArray {
    char *arr = malloc(3 * sizeof(char));
    
    arr[0] = _r;
    arr[1] = _g;
    arr[2] = _b;
    
    return arr;
}
    
@end
