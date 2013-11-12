//
//  FTEffectContainerView.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTEffectContainerView.h"

@implementation FTEffectContainerView

#pragma mark Initialization

- (void) awakeFromNib
{

//    [self enterFullScreenMode:[[NSScreen screens] objectAtIndex:0] withOptions:NULL];
    
    [self.window makeKeyAndOrderFront:self];
    _tuioClient = [[TuioClient alloc] initWithPortNumber:3333
                                  andDelegateDimensions:self.frame.size
                                     relativeCoordinates:true];
    _tuioClient.isCalibrating = TRUE;
    
    _effectsQueue = [[FTQueue alloc] initWithSingleClass:[FTBaseGLLayer class]];

    _currentEffect = [FTInteractiveLogos layer];
    _currentEffect.mustGLClear = TRUE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [FTBoundariesBurnEffect layer];
    _currentEffect.mustGLClear = TRUE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [FTColorTracks layer];
    _currentEffect.mustGLClear = TRUE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [FTColorTrails layer];
    _currentEffect.mustGLClear = TRUE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [FTPainterEffect layer];
    _currentEffect.mustGLClear = FALSE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [_effectsQueue peek];
    [_tuioClient addObjectToDelegates:_currentEffect];
	[self.layer addSublayer:_currentEffect];
    
    _text = [CATextLayer layer];
    
    _renderTimer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(sendToSyphon:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSRunLoopCommonModes];
}

- (void) dealloc
{
    [_syphon stop];
}
#pragma mark -

#pragma mark Implementation

- (void) drawRect:(NSRect) dirtyRect
{
	[super drawRect:dirtyRect];
}

- (void) setBounds:(NSRect)aRect
{
    _currentEffect.frame = aRect;
}

-(void) sendToSyphon:(NSTimer*) aTimer
{
    if(_syphon == nil)
        _syphon = [[SyphonServer alloc] initWithName:@"MultiEffect" context:_currentEffect.glContext options:nil];
    
    if([_syphon hasClients])
    {
        [_syphon publishFrameTexture:_currentEffect.textureId
                       textureTarget:GL_TEXTURE_2D
                         imageRegion:NSMakeRect(0, 0, _currentEffect.frame.size.width, _currentEffect.frame.size.height)
                   textureDimensions:_currentEffect.frame.size
                             flipped:NO];
    }
}
#pragma marka -

#pragma mark Effect switching

- (void) switchToNextEffect
{
    [_tuioClient removeObjectFromDelegates:_currentEffect];
    [_currentEffect removeFromSuperlayer];
    [_effectsQueue dequeue];
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [_effectsQueue peek];
    [_tuioClient addObjectToDelegates:_currentEffect];
    [self.layer addSublayer:_currentEffect];
}

#pragma mark Keyboard Handler
- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void) printLimits
{
    _text.string = [NSString stringWithFormat:@"Min X: %f; Max X: %f; Min Y: %f; Max Y:%f", _tuioClient.contourMinX, _tuioClient.contourMaxX, _tuioClient.contourMinY, _tuioClient.contourMaxY];
    CGColorRef fgColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
	_text.foregroundColor = fgColor;
	CGColorRelease(fgColor);
    _text.fontSize = 20.f;
    [self.layer addSublayer:_text];
    
    _text.frame = CGRectMake(0, 0, 800, 600);
    
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    [self printLimits];
    switch(key)
    {
        case 'n' : case 'N':
		{
            [self switchToNextEffect];
		} break;
        case 'g' : case 'G':
		{

		} break;
            case 'p':
        {
            [self printLimits];
        } break;
            
        case 'w':
        {
            [_tuioClient calibrateContourMaxYAdd:0.025f];
        } break;
        case 's':
        {
            [_tuioClient calibrateContourMaxYAdd:-0.025f];
        } break;
        case 'a':
        {
            [_tuioClient calibrateContourMaxXAdd:-0.025f];
        } break;
        case 'd':
        {
            [_tuioClient calibrateContourMaxXAdd:0.025f];
        } break;
            
            
        case 'i':
        {
            [_tuioClient calibrateContourMinYAdd:0.025f];
        } break;
        case 'k':
        {
            [_tuioClient calibrateContourMinYAdd:-0.025f];
        } break;
        case 'j':
        {
            [_tuioClient calibrateContourMinXAdd:-0.025f];
        } break;
        case 'l':
        {
            [_tuioClient calibrateContourMinXAdd:0.025f];
        } break;
    }
}
#pragma mark -

@end
