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
    NSLog(@"Alive");
    [self.window makeKeyAndOrderFront:self];
    _tuioClient = [[TuioClient alloc] initWithPortNumber:3333
                                  andDelegateDimensions:self.frame.size
                                     relativeCoordinates:true];
    _effectsQueue = [[FTQueue alloc] initWithSingleClass:[FTBaseGLLayer class]];

    _currentEffect = [FTColorTracks layer];
    _currentEffect.mustGLClear = TRUE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [FTColorTrails layer];
    _currentEffect.mustGLClear = TRUE;
    _currentEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_effectsQueue enqueue:_currentEffect];
    
    _currentEffect = [FTBoundariesBurnEffect layer];
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

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    switch(key)
    {
        case 'n' : case 'N':
		{
            [self switchToNextEffect];
		} break;
        case 'g' : case 'G':
		{

		} break;

    }
}
#pragma mark -

@end
