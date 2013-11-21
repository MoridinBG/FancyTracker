//
//  FTSparkleEmitter.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/19/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"
#import "FTUtilityFunctions.h"

//TODO: Highly inefficient. CAEmitterLayer hosted in CAOpenGLLayer?!
@interface FTSparkleEmitter : FTBaseGLLayer
{
    CALayer *_hostingLayer;
    NSMutableDictionary *_emitters;
    NSArray *_paths;
}

- (id) init;
- (void) setBounds:(CGRect)bounds;

- (void) tuioBoundsAdded:(TuioBounds *)newBounds;

@end
