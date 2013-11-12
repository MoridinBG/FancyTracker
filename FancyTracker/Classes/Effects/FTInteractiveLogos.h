//
//  FTInteractiveLogos.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"
#import "FTb2Physics.h"

#define NUM_LOGOS 5
#define LOGO_WIDTH 100.f
#define LOGO_HEIGHT 100.f

@interface FTInteractiveLogos : FTBaseGLLayer
{
    FTb2Physics *_physics;
    NSMutableArray *_logoObjects;
}
@property float restitution;
@property float density;

- (id) init;
- (void) setBounds:(CGRect)bounds;

- (void) loadImages;



- (void) drawGL;

- (void) tuioBoundsAdded:(TuioBounds*) newBounds;
- (void) tuioBoundsUpdated:(TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved:(TuioBounds*) deadBounds;

@end