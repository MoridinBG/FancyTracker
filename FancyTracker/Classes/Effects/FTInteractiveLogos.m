//
//  FTInteractiveLogos.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTInteractiveLogos.h"

@implementation FTInteractiveLogos

#pragma mark Initialization
- (id) init
{
    if(self = [super init])
    {
        _physics = [[FTb2Physics alloc] init];
        _mustRunPhysics = TRUE;
        _mustCreateSensors = FALSE;
        _mustDistanceJointNeihgbours = FALSE;
        _logoObjects = [[NSMutableArray alloc] init];
        _connections = [[NSMutableArray alloc] init];
        _queuedForJoints = [[NSMutableArray alloc] init];
        
        _pictureId = 0;
    }
    
    return self;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [_physics createGroundWithDimensions:CGSizeMake(_aspect, 1.f)];
}

- (void) setupSensors
{
    _contactDetector = [_physics addContactDetector];
    _contactDetector.effect = self;
}

- (void) loadImagesFrom:(NSArray*)imagePaths withNumOfEach:(int)num withSize:(CGSize) size
{
    _mustRunPhysics = TRUE;
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
                                                                        withDensity:LOGO_DENSITY
                                                                    withRestitution:LOGO_RESTITUTION];
            _pictureId--;
            layerObject.uid = [NSNumber numberWithLong:_pictureId];
            layerObject.isPhysicsControlled = TRUE;
            layerObject.userObject = layer;
            layerObject.shouldResizePhysics = TRUE;
            layerObject.type = CIRCLE;
            if(_mustCreateSensors)
                [_physics attachCircleSensorWithSize:glSize toObject:layerObject];
            
            [_logoObjects addObject:layerObject];
            [self addSublayer:layer];
        }
    }
}
#pragma mark -

#pragma mark Drawing
- (void) drawGL
{
    for(FTConnection *conn in _queuedForJoints)
    {
        NSValue *joint = [_physics distanceJointBody:conn.endA.physicsData
                                            withBody:conn.endB.physicsData
                                            withFreq:SPRING_FREQ
                                            withDamp:SPRING_DAMP];
        if(joint == nil)
            NSLog(@"Impossible to make a joint now");
        conn.joint = joint;
    }
    [_queuedForJoints removeAllObjects];
    
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
    
    for(FTConnection *connection in _connections)
    {
        [connection render];
    }
    
    if(_mustRunPhysics)
        [_physics step];
}
#pragma mark -

#pragma mark Event handling
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
    if(object)
    {
        [_physics destroyBody:object.physicsData];
//      [_physics detachMouseJointWithId:deadBounds.sessionID];   //FIXME: Crash!
    }
    
    [super tuioBoundsRemoved:deadBounds];
}

- (void) tuioStopListening
{
    for(FTInteractiveObject *object in [_blobs allValues])
    {
        [_physics destroyBody:object.physicsData];
    }
    [_blobs removeAllObjects];
    _mustRunPhysics = FALSE;
}
#pragma mark -

#pragma mark Contact Handlers
- (void) contactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj
{
	[firstObj addNeighbour:secondObj];
	[secondObj addNeighbour:firstObj];
	
	if((firstObj.connectedNeighboursCount < CONNECTED_NEIGHBOURS) && (secondObj.connectedNeighboursCount < CONNECTED_NEIGHBOURS))
		if(![firstObj isConnectedToNeighbour:secondObj])
		{
			FTConnection *connection = [[_connectionDrawer alloc] initWithendA:firstObj
                                                                          endB:secondObj
                                                                   beginningAt:0.f
                                                                      endingAt:1.f];
			
			[firstObj connectTo:secondObj withConnection:connection];
			[secondObj connectTo:firstObj withConnection:connection];
            
            if(_mustDistanceJointNeihgbours)
            {
                NSValue *joint = [_physics distanceJointBody:firstObj.physicsData
                                                    withBody:secondObj.physicsData
                                                    withFreq:SPRING_FREQ
                                                    withDamp:SPRING_DAMP];
                if(joint == nil)
                {
                    [_queuedForJoints addObject:connection];
                }
            }
            
			[_connections addObject:connection];
		}
}

- (void) removedContactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj
{
	[firstObj removeNeighbour:secondObj];
	[secondObj removeNeighbour:firstObj];
	
	if([firstObj isConnectedToNeighbour:secondObj])
	{
		FTConnection *connection = [firstObj disconnectFrom:secondObj];
		[secondObj disconnectFrom:firstObj];
        
        if(connection.joint != nil)
        {
            [_physics destroyJoint:connection.joint];
        }
        
		[_connections removeObject:connection];
	}
}

@end
