//
//  FTInteractiveLogos.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"
#import "FTb2Physics.h"


@interface FTInteractiveLogos : FTBaseGLLayer
{
    FTb2Physics *_physics;
    NSMutableArray *_logoObjects;
}
@property float restitution;
@property float density;

- (id) init;

- (void) loadImagesFrom:(NSArray*)imagePaths withNumOfEach:(int)num withSize:(CGSize) size;

- (void) drawGL;

- (void)keyDown:(NSEvent *)event;

- (void) tuioBoundsAdded:(TuioBounds*) newBounds;
- (void) tuioBoundsUpdated:(TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved:(TuioBounds*) deadBounds;

@end