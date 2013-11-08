//
//  FTBoundariesBurnEffect.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"
#import <TUIOFramework/TuioClient.h>

#import "FTInteractiveObject.h"

@interface FTBoundariesBurnEffect : FTBaseGLLayer <TuioBoundsListener>
{
    
}
- (id) init;

- (void) drawGL;

- (void) tuioBoundsAdded: (TuioBounds*) newBounds;

@end
