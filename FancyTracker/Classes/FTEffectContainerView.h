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
#import "FTLineConnectionDrawer.h"

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
    FTInteractiveLogos *_logos1, *_logos2;
    FTInteractiveLogos *_logos3, *_logos4;
    FTInteractiveLogos *_logos5, *_logos6;
    
    NSTimer *_renderTimer;
    CATextLayer *_text;
    
    CARenderer *_syphonRenderer;
    CGLContextObj _syphonContext;
    GLuint _syphoneTextureId;
    GLuint _syphonFboId;
}

- (void) awakeFromNib;
- (void) loadEffects;
- (void) createSyphonContext;


- (void) setBounds:(NSRect)aRect;
-(void) sendToSyphon:(NSTimer*) aTimer;

- (BOOL)acceptsFirstResponder;
- (void)keyDown:(NSEvent *)event;

@end
