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
    GLuint _texture;
    GLuint _textureStencil;
}

- (id) init;
- (void) drawGL;
- (void) tuioBoundsAdded: (TuioBounds*) newBounds;

@end
