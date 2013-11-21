//
//  FTInteractiveObject.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <TUIOFramework/TuioBounds.h>

#import "FTRGBA.h"
#import "consts.h"

#ifdef __cplusplus
    #import <Box2D/Dynamics/b2Body.h>
    #import <Box2D/Dynamics/b2World.h>
    #import <Box2D/Dynamics/b2Fixture.h>
    #import "b2PolygonShape.h"
    #import "b2CircleShape.h"
#endif

#import "FTUtilityFunctions.h"

typedef enum type {CIRCLE, ELLIPSE, RECTANGLE, CIRCLE_SENSOR, ELLIPSE_SENSOR, RECTANGLE_SENSOR} Type;
#define PHYS_AREA_DIFF              0.2f
#define AVG_RECENT_STEPS            3
#define VEL_ANGLE_RECENT_STEPS      5
#define VELOCITY_ANGLE_MOVE_TRESHOLD     0.01f

@class FTConnection;
@interface FTInteractiveObject : NSObject
{
    //Actually needed to be declared, as accessors are user defined, so property not explictly synthesized -> no auto _position object
    CGPoint _position;
    CGSize _size;
    float _angle;
    
#ifdef __cplusplus
	b2Body *_physicsData;
#endif
}
@property Type type;

@property CGPoint position;
@property NSMutableArray * positionHistory;

@property id userObject;

@property CGSize physicsSize;
@property BOOL shouldResizePhysics;
@property BOOL isPhysicsControlled;
@property BOOL isManualNeighboured;

@property CGSize size;
@property float angle;
@property CGPoint velocity;
@property (readonly) float velocityAngle;                           //Radians
@property (readonly) float avgRecentMovement;

@property NSMutableArray *contour;
@property NSMutableArray *contourHistory;

@property FTRGBA *color;
@property NSNumber *uid;

@property NSMutableArray *neighbours;
@property NSMutableDictionary *connectedNeighbours;

+ (id) interactiveFrom:(TuioBounds*)bounds;

- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size;

#ifdef __cplusplus
- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size
	  physicsBackedBy:(b2Body*)physicsBody
			 withType:(Type)type;
#endif

- (void) updateWithTuioBounds:(TuioBounds*)bounds;

- (void) setPhysicsData:(NSValue *)data;
- (NSValue*) physicsData;

- (void) setFixedPhysicsRotation:(BOOL) rotation;

- (void) destroyPhysicsData;

- (void) addNeighbour:(FTInteractiveObject*)neighbour;
- (void) removeNeighbour:(FTInteractiveObject*)neigbour;

- (void) connectTo:(FTInteractiveObject*)neighbour withConnection:(FTConnection*)connection;
- (FTConnection*) disconnectFrom:(FTInteractiveObject*)neighbour;
- (bool) isConnectedToNeighbour:(FTInteractiveObject*)neighbour;

- (unsigned long) neighboursCount;
- (unsigned long) connectedNeighboursCount;

@end
