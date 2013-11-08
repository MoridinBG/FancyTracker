//
//  FTEffectContainerView.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <TUIOFramework/TuioClient.h>
#import "FTBoundariesBurnEffect.h"

@interface FTEffectContainerView : NSView
{
    TuioClient *_tuioClient;
    FTBaseGLLayer *_dumbLayer;
}

- (void) awakeFromNib;

- (void) drawRect:(NSRect) dirtyRect;

@end
