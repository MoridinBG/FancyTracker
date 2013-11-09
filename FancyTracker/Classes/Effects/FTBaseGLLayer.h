//
//  FTBaseGLLayer.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>

#import <TUIOFramework/TuioClient.h>

#import "FTRGBA.h"
#import "FTInteractiveObject.h"

#import "consts.h"

@interface FTBaseGLLayer : CAOpenGLLayer <TuioBoundsListener>
{
    NSMutableDictionary *_blobs;
	GLUtesselator *_tess;
    
    CGLContextObj _glContext;
    GLuint _textureId;
	GLuint _rboId;
	GLuint _fboId;
    
    BOOL _mustGlClear;
    
	GLbitfield _clearBitfield;
}
@property (readonly) CGLContextObj glContext;
@property (readonly) GLuint textureId;

@property BOOL mustGLClear;

- (id) init;

- (CGLContextObj) copyCGLContextForPixelFormat:(CGLPixelFormatObj) pixelFormat;
- (CGLPixelFormatObj) copyCGLPixelFormatForDisplayMask:(uint32_t) mask;
- (void) releaseCGLPixelFormat:(CGLPixelFormatObj) pixelFormat;

- (void) drawInCGLContext:(CGLContextObj) glContext
              pixelFormat:(CGLPixelFormatObj) pixelFormat
             forLayerTime:(CFTimeInterval) interval
              displayTime:(const CVTimeStamp *) timeStamp;
- (void) drawGL;

- (void) renderContourOfObject:(FTInteractiveObject*) object;

- (void) tuioBoundsAdded: (TuioBounds*) newBounds;
- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds;
- (void) tuioFrameFinished;
- (void) tuioStopListening;


@end
