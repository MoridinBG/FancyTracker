//
//  FTPainterEffect.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/8/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"

@interface FTPainterEffect : FTBaseGLLayer
{
}

- (void) drawGL;

- (void) tuioBoundsAdded: (TuioBounds*) newBounds;
@end
