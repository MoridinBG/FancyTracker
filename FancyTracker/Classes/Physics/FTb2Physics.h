//
//  FTb2Physics.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <CoreServices/CoreServices.h>
#import <mach/mach_time.h>

#ifdef __cplusplus
#import "Box2D.h"
#import "Render.h"
#endif

//#import "GlobalFunctions.h"
#import "consts.h"
#import "FTInteractiveObject.h"
#import "FTContactDetector.h"

@interface FTb2Physics : NSObject
{
#ifdef __cplusplus
	b2World *_world;
	b2Body *_groundBody;
	DebugDraw debugDraw;
#endif
	NSOperationQueue *operationQueue;
    
	float timeStep;
	int velocityIterations;
	int positionIterations;
	
	NSMutableDictionary *mouseJoints;
    NSMutableArray *_lockedDeadBodies;
    NSMutableArray *_lockedDeadJoints;
}

@property BOOL mustDebugDraw;

- (id) init;
- (void) createGroundWithDimensions:(CGSize)dimensions;
- (void) step;

- (FTContactDetector *) addContactDetector;
- (void) removeContactDetector;

#pragma mark Create/Destroy Bodies
- (void) attachRectangleBodyWithSize:(CGSize)size
                           rotatedAt:(float)angle
                         withDensity:(float)density
                     withRestitution:(float)restitution
                            toObject:(FTInteractiveObject*)object;

- (FTInteractiveObject*) createRectangleBodyAtPosition:(CGPoint)position
                                              withSize:(CGSize)size
                                             rotatedAt:(float)angle
                                           withDensity:(float)density
                                       withRestitution:(float)restitution;

- (void) attachCircleBodyWithSize:(CGSize)size
                      withDensity:(float)density
                  withRestitution:(float)restitution
                         toObject:(FTInteractiveObject*)object;

- (FTInteractiveObject*) createCircleBodyAtPosition:(CGPoint)position
                                           withSize:(CGSize)size
                                        withDensity:(float)density
                                    withRestitution:(float)restitution;

- (void) attachEllipsoidBodyWithSize:(CGSize)size
                           rotatedAt:(float)angle
                         withDensity:(float)density
                     withRestitution:(float)restitution
                            toObject:(FTInteractiveObject*)object;

- (FTInteractiveObject*) createEllipsoidleBodyAtPosition:(CGPoint)position
                                                withSize:(CGSize)size
                                               rotatedAt:(float)angle
                                             withDensity:(float)density
                                         withRestitution:(float)restitution;

- (void) attachRectangleSensorWithSize:(CGSize)size rotatedAt:(float)angle toObject:(FTInteractiveObject*)object;
- (FTInteractiveObject*) createRectangleSensorAtPosition:(CGPoint)position withSize:(CGSize)size rotatedAt:(float)angle;

- (void) attachCircleSensorWithSize:(CGSize)size toObject:(FTInteractiveObject*)object;
- (FTInteractiveObject*) createCircleSensorAtPosition:(CGPoint)position withSize:(CGSize)size;

- (void) attachEllipsoidSensorWithSize:(CGSize)size
                             rotatedAt:(float)angle
                              toObject:(FTInteractiveObject*)object;

- (void) destroyBody:(NSValue*)packedBody;
#pragma mark -

#pragma mark Create/Destroy Joints
- (NSValue*) distanceJointBody:(NSValue*)packedBody1
                      withBody:(NSValue*)packedBody2
                      withFreq:(float)freq
                      withDamp:(float)damp;
- (void) destroyJoint:(NSValue*)packedJoint;
#pragma mark

#pragma mark Modify Bodies

#pragma mark -

#pragma mark Create/Destroy Mouse Joints
- (void) attachMouseJointToBody:(NSValue*)body withId:(NSNumber*)uid;
- (void) detachMouseJointWithId:(NSNumber*)uid;
- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position;
#pragma mark -
@end
