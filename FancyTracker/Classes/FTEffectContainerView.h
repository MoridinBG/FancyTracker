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
#import "Effects/FTColorTracks.h"
#import "Effects/FTInteractiveLogos.h"
#import "Effects/FTPictureReveal.h"
#import "Effects/FTBackgroundLayer.h"

@interface FTEffectContainerView : NSView
{
    TuioClient *_tuioClient;
    SyphonServer *_syphon;
    
    FTBackgroundLayer *_background;
    
    FTBaseGLLayer *_currentEffect;
    
    NSTimer *_renderTimer;
    CATextLayer *_text;
}

- (void) awakeFromNib;

-(void) sendToSyphon:(NSTimer*) aTimer;

- (BOOL)acceptsFirstResponder;
- (void)keyDown:(NSEvent *)event;

@end
