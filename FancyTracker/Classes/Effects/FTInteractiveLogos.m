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
    [_physics createGroundWithDimensions:CGSizeMake(_aspect, 1.f)];
}

- (void) loadImagesFrom:(NSArray*)imagePaths withNumOfEach:(int)num withSize:(CGSize) size
{
    for(NSString *path in imagePaths)
    {
        NSImage *image = [NSImage imageNamed:path];
        if(!image.isValid)
        {
            NSLog(@"Ignoring invalid image path");
            continue;
        }
        
        for(int i = 0; i < num; i++)
        {
            CALayer *layer = [CALayer layer];
            layer.contents = image;
            
            CGPoint glPosition = [self getRandomGLPointWithinDimension];
            CGPoint caPosition = [self convertGLPointToCAPoint:glPosition];
            
            layer.frame = CGRectMake(caPosition.x, caPosition.y, size.width, size.height);
            CGSize glSize = CGSizeMake((size.width / self.bounds.size.width) * _aspect, size.height / self.bounds.size.height);
            
            FTInteractiveObject *layerObject = [_physics createCircleBodyAtPosition:glPosition
                                                                           withSize:glSize
                                                                        withDensity:1.f
                                                                    withRestitution:0.6f];
            layerObject.isPhysicsControlled = TRUE;
            layerObject.userObject = layer;
            layerObject.shouldResizePhysics = TRUE;
            layerObject.type = CIRCLE;
            [_logoObjects addObject:layerObject];
            [self addSublayer:layer];
        }
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

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    switch(key)
    {
        case '-' :
        {
            float stepSize = 0.9f;
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.f];
            for(FTInteractiveObject *logo in _logoObjects)
            {
                CALayer *layer = logo.userObject;
                CGRect frame = CGRectMake(layer.bounds.origin.x,
                                          layer.bounds.origin.y ,
                                          layer.bounds.size.width * stepSize,
                                          layer.bounds.size.height * stepSize);
                layer.bounds = frame;
                logo.size = CGSizeMake(logo.size.width * stepSize, logo.size.height * stepSize);
            }
            [CATransaction commit];
        } break;
            
        case '+' :
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.f];
            for(FTInteractiveObject *logo in _logoObjects)
            {
                float stepSize = 1.1f;
                CALayer *layer = logo.userObject;
                CGRect frame = CGRectMake(layer.bounds.origin.x,
                                          layer.bounds.origin.y ,
                                          layer.bounds.size.width * stepSize,
                                          layer.bounds.size.height * stepSize);
                layer.bounds = frame;
                logo.size = CGSizeMake(logo.size.width * stepSize, logo.size.height * stepSize);
            }
            [CATransaction commit];
        } break;
    }
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
    [object setFixedPhysicsRotation:TRUE];
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
