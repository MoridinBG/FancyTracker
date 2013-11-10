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
#import "FTInteractiveObject.h"
#import "FTContactDetector.h"

@interface FTb2Physics : NSObject
{
#ifdef __cplusplus
	b2World *world;
	b2Body *_groundBody;
	DebugDraw debugDraw;
#endif
	NSOperationQueue *operationQueue;
    
	float timeStep;
	int velocityIterations;
	int positionIterations;
	
	NSMutableDictionary *mouseJoints;
}

- (id) init;
- (void) createGroundWithDimensions:(CGSize)dimensions;
- (void) step;
- (FTContactDetector *) addContactDetector;

#pragma mark Create/Destroy Bodies
- (void) attachRectangleBodyWithSize:(CGSize)size rotatedAt:(float)angle toObject:(FTInteractiveObject*)object;
- (FTInteractiveObject*) createRectangleBodyAtPosition:(CGPoint)position withSize:(CGSize)size rotatedAt:(float)angle;

- (void) attachCircleBodyWithSize:(CGSize)size toObject:(FTInteractiveObject*)object;
- (FTInteractiveObject*) createCircleBodyAtPosition:(CGPoint)position withSize:(CGSize)size;

- (void) attachRectangleSensorWithSize:(CGSize)size rotatedAt:(float)angle toObject:(FTInteractiveObject*)object;
- (FTInteractiveObject*) createRectangleSensorAtPosition:(CGPoint)position withSize:(CGSize)size rotatedAt:(float)angle;

- (void) attachCircleSensorWithSize:(CGSize)size toObject:(FTInteractiveObject*)object;
- (FTInteractiveObject*) createCircleSensorAtPosition:(CGPoint)position withSize:(CGSize)size;

- (void) destroyBody:(NSValue*)packedBody;
#pragma mark -

#pragma mark Modify Bodies

#pragma mark -

#pragma mark Create/Destroy Mouse Joints
- (void) attachMouseJointToBody:(NSValue*)body withId:(NSNumber*)uid;
- (void) detachMouseJointWithId:(NSNumber*)uid;
- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position;
#pragma mark -

- (NSMutableArray *) createBlobAt:(CGPoint)position
					   withRadius:(float) blobRadius;
@end
