//
//  FTPictureReveal.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/12/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"

@interface FTPictureReveal : FTBaseGLLayer
{
}

- (id) init;
- (void) drawGL;
- (void) tuioBoundsAdded: (TuioBounds*) newBounds;

@end
