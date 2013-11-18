//
//  FTPictureReveal.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/12/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTPictureReveal.h"

@implementation FTPictureReveal

- (id) init
{
    if(self = [super init])
    {
    }
    return self;
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat
{
	CGLContextObj contextObj = [super copyCGLContextForPixelFormat:pixelFormat];
	
    NSImage *img = [NSImage imageNamed:@"back_1.jpg"];
    if(!img.isValid)
        NSLog(@"Trash");
    
    _texture = [FTUtilityFunctions getTextureFromImage:[img CGImageForProposedRect:NULL context:NULL hints:NULL]];
	
	return contextObj;
}

- (void) drawGL
{
    glEnable(GL_TEXTURE_2D);
//    glBindTexture( GL_TEXTURE_2D, _texture);
////    glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
//    glColor3f(1, 1, 1);
//    glBegin( GL_QUADS );
//    glTexCoord2f( 0.0f, 0.0f);
//    glVertex2f(  0.0f, 1.0f);
//    
//    glTexCoord2f( 1.0f, 0.0f);
//    glVertex2f(  1.0f, 1.0f);
//    
//    glTexCoord2f( 1.0f, 1.0f);
//    glVertex2f(  1.0f, 0.0f);
//    
//    glTexCoord2f( 0.0f, 1.0f);
//    glVertex2f( 0.0f, 0.0f);
//    glEnd();
    
    for(FTInteractiveObject *blob in [_blobs allValues])
	{
        [[blob color] stepColors];
        [self renderContourOfObject:blob];
	}
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    glColor3f(1, 0.f, 0.f);
    // Disable writing to any of the color fields
    glColorMask(GL_TRUE, GL_FALSE, GL_FALSE, GL_FALSE);
    
//    glStencilOp(GL_INCR, GL_INCR, GL_INCR);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    glStencilFunc(GL_ALWAYS, 1, 1);
    
    glEnable(GL_STENCIL_TEST);
    // Draw our blocking poly
    glBegin(GL_POLYGON);
    glVertex2f( 0.5f, 0.5f );
    glVertex2f( 0.5f,     0.75f );
    glVertex2f( 0.75f, 0.75f );
    glEnd();
    
    // Re enable drawing of colors
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    // Enable use of textures
    glEnable(GL_TEXTURE_2D);
    glColor3f(1, 1, 1);
    
    // Bind desired texture for drawing
    glBindTexture(GL_TEXTURE_2D,_texture);
    
    // Draw the box with colors
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0f, 0.0f);
    glVertex2f(  0.0f, 1.0f);
    
    glTexCoord2f( 1.0f, 0.0f);
    glVertex2f(  1.0f, 1.0f);
    
    glTexCoord2f( 1.0f, 1.0f);
    glVertex2f(  1.0f, 0.0f);
    
    glTexCoord2f( 0.0f, 1.0f);
    glVertex2f( 0.0f, 0.0f);
    glEnd();
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	[super tuioBoundsAdded:newBounds];
	FTInteractiveObject * object = [_blobs objectForKey:[newBounds getKey]];
	object.color = [FTRGBA randomColorWithMinimumValue:10];
}

@end
