//
//  FTEffectContainerView.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <TUIOFramework/TuioClient.h>
#import <Syphon/Syphon.h>

#import "FTQueue.h"

#import "FTBoundariesBurnEffect.h"
#import "Effects/FTPainterEffect.h"
#import "Effects/FTColorTrails.h"

@interface FTEffectContainerView : NSView
{
    TuioClient *_tuioClient;
    SyphonServer *_syphon;
    
    FTBaseGLLayer *_currentEffect;
    FTQueue *_effectsQueue;
    
    NSTimer *_renderTimer;
}

- (void) awakeFromNib;

- (void) drawRect:(NSRect) dirtyRect;
-(void) sendToSyphon:(NSTimer*) aTimer;

- (void) switchToNextEffect;

- (BOOL)acceptsFirstResponder;
- (void)keyDown:(NSEvent *)event;

@end
