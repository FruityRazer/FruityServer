//
//  FRHyperflux.m
//  FruityRazer
//
//  Created by Eduardo Almeida on 19/03/19.
//  Copyright © 2019 Eduardo Almeida. All rights reserved.
//

#import "FRHyperflux.h"

#import "RazerSoftwareChroma.h"

@implementation FRHyperflux

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
    
    razer_hyperflux_set_colors(_dev, parts);
    
    return true;
}

@end
