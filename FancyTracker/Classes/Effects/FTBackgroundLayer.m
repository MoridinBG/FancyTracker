//
//  FTBackgroundLayer.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/13/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBackgroundLayer.h"

@implementation FTBackgroundLayer

- (void) setBackgroundWithImageNamed:(NSString*) name
{
    NSImage *bg = [NSImage imageNamed:name];
    if(!bg.isValid)
    {
        NSLog(@"Ignored loading invalid image for background layer");
        return;
    } else
        self.contents = bg;
}

@end
