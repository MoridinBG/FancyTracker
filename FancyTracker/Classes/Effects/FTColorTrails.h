//
//  FTColorTrails.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"

#define CONTOURS_BACK 10

@interface FTColorTrails : FTBaseGLLayer
{
}

- (id) init;
- (void) addBlurFilter;
- (void) drawGL;

@end
