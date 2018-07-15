//
//  FRKeyboard.m
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

#import "FRKeyboard.h"

#import "RazerSoftwareChroma.h"

@implementation FRKeyboard

- (instancetype)initWithDeviceInterface:(IOUSBDeviceInterface **)deviceInterface {
    if (self = [super init]) {
        _colors = [[NSMutableArray alloc] init];
        
        for (int i = 0; i <= 8; i++) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            for (int j = 0; j <= 25; j++)
                [arr addObject:[[FRRGB alloc] initWithRed:0 green:0 blue:0]];
            
            [_colors addObject:arr];
        }
        
        _dev = deviceInterface;
    }
    
    return self;
}

- (void)setColor:(FRRGB *)color {
    for (int i = 0; i <= 8; i++)
        [self setColor:color forRow:i];
}

- (void)setColor:(FRRGB *)color forRow:(int)row {
    for (int i = 0; i <= 25; i++) {
        FRKeyIndex idx = { .row = row, .column = i };
        
        [self setColor:color forKey:&idx];
    }
}

- (void)setColor:(FRRGB *)color forKey:(FRKeyIndex *)key {
    _colors[key->row][key->column] = color;
}

- (BOOL)updateDeviceState {
    for (int i = 0; i <= 8; i++) {
        char *keys = calloc(78, sizeof(char));
        
        for (int j = 0; j <= 25; j++) {
            keys[(j * 3)] = _colors[i][j].r;
            keys[(j * 3) + 1] = _colors[i][j].g;
            keys[(j * 3) + 2] = _colors[i][j].b;
        }
        
        razer_huntsman_set_row_raw(_dev, i, keys, 25);
    }
    
    return false;
}

@end
