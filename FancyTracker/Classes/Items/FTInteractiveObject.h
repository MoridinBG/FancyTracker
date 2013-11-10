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
#endif

typedef enum type {CIRCLE, ELIPSE, RECTANGLE, RECTANGLE_SENSOR, CIRCLE_SENSOR} Type;

@interface FTInteractiveObject : NSObject
{
    Type _type;
    
#ifdef __cplusplus
	b2Body *_physicsData;
#endif
}

@property CGPoint position;
@property NSMutableArray * positionHistory;

@property CGSize size;
@property double angle;
@property CGPoint velocity;

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

- (void) addNeighbour:(FTInteractiveObject*)neighbour;
- (void) removeNeighbour:(FTInteractiveObject*)neigbour;

- (bool) isConnectedToNeighbour:(FTInteractiveObject*)neighbour;
- (unsigned long) neighboursCount;
- (unsigned long) connectedNeighboursCount;

@end
