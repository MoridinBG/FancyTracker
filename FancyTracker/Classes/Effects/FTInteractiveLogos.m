//
//  FTInteractiveLogos.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTInteractiveLogos.h"

@implementation FTInteractiveLogos

- (id) init
{
    if(self = [super init])
    {
        _physics = [[FTb2Physics alloc] init];
        
        _logoObjects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self loadImages];
}

- (void) loadImages
{
    [_physics createGroundWithDimensions:CGSizeMake(_aspect, 1.f)];

    NSImage *logo1 = [NSImage imageNamed:@"C1.png"];
    NSImage *logo2 = [NSImage imageNamed:@"C2.png"];
    NSImage *logo3 = [NSImage imageNamed:@"C3.png"];
    
    for(int i = 0; i < NUM_LOGOS; i++)
    {
        CALayer *layer = [CALayer layer];
        if(logo1.isValid)
            layer.contents = logo1;
        else
            NSLog(@"Disaster");
        
        CGPoint glPosition = [self getRandomGLPointWithinDimension];
        CGPoint caPosition = [self convertGLPointToCAPoint:glPosition];
        
        layer.bounds = CGRectMake(caPosition.x, caPosition.y, LOGO_WIDTH, LOGO_HEIGHT);
        CGSize glSize = CGSizeMake((LOGO_WIDTH / self.bounds.size.width) * _aspect, LOGO_HEIGHT / self.bounds.size.height);
        
        FTInteractiveObject *layerObject = [_physics createCircleBodyAtPosition:glPosition
                                                                       withSize:glSize
                                                                    withDensity:1.f
                                                                withRestitution:0.6f];
        layerObject.isPhysicsControlled = TRUE;
        layerObject.userObject = layer;
        [_logoObjects addObject:layerObject];
        [self addSublayer:layer];
    }
}

- (void) drawGL
{
    for(FTInteractiveObject *blob in [_blobs allValues])
	{
        [[blob color] stepColors];
        [self renderContourOfObject:blob];
	}
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.f];
    for(FTInteractiveObject *logo in _logoObjects)
    {
        CALayer *layer = logo.userObject;
        CGPoint position = logo.position;
        layer.position = [self convertGLPointToCAPoint:position];
        layer.transform = CATransform3DMakeRotation(logo.angle, 0.f, 0.f, 1.f);
    }
    [CATransaction commit];
    
    [_physics step];
}

- (void) tuioBoundsAdded:(TuioBounds*) newBounds
{
    [super tuioBoundsAdded:newBounds];
    
    FTInteractiveObject *object = [_blobs objectForKey:newBounds.sessionID];
    [_physics attachEllipsoidBodyWithSize:newBounds.dimensions
                                rotatedAt:0.f
                                 toObject:object];
    [_physics attachMouseJointToBody:object.physicsData
                              withId:object.uid];
    object.type = ELLIPSE;
    object.shouldResizePhysics = TRUE;
}

- (void) tuioBoundsUpdated:(TuioBounds*) updatedBounds
{
    [super tuioBoundsUpdated:updatedBounds];
    [_physics updateMouseJointWithId:updatedBounds.sessionID
                          toPosition:updatedBounds.position];
}

- (void) tuioBoundsRemoved:(TuioBounds*) deadBounds
{
    FTInteractiveObject *object = [_blobs objectForKey:deadBounds.sessionID];
    [_physics destroyBody:object.physicsData];
//    [_physics detachMouseJointWithId:deadBounds.sessionID];   //FIXME: Crash!
    
    [super tuioBoundsRemoved:deadBounds];
}

@end
