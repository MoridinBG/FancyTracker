//
//  FTInteractiveLogos.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"
#import "FTb2Physics.h"
#import "FTContactDetector.h"
#import "FTProximitySensorListener.h"
#import "FTConnection.h"

#define SPRING_FREQ 1.f
#define SPRING_DAMP 0.1f
#define CONNECTED_NEIGHBOURS 5
#define LOGO_RESTITUTION 1.f
#define LOGO_DENSITY 1.f

#define SUBIMAGES_MAX_DISTANCE 0.25f
#define SUBIMAGES_MIN_DISTANCE 0.1f

@interface FTInteractiveLogos : FTBaseGLLayer <FTProximitySensorListener>
{
    FTb2Physics *_physics;
    FTContactDetector *_contactDetector;
    BOOL _mustRunPhysics;
    BOOL _mustCreateSensors;
    BOOL _mustDistanceJointNeihgbours;
    BOOL _mustDrawConnections;
    
    NSMutableArray *_logoObjects;
    NSMutableArray *_queuedForJoints;
    
    long _pictureId;
    
    NSMutableArray *_connections;
    Class _connectionDrawer;
}
@property float restitution;
@property float density;

@property BOOL mustRunPhysics;
@property BOOL mustCreateSensors;
@property BOOL mustDistanceJointNeihgbours;
@property BOOL mustDrawConnections;

@property(assign) Class connectionDrawer;

- (id) init;
- (void) setBounds:(CGRect)bounds;
- (void) setupSensors;

- (void) loadImagesFrom:(NSArray*)imagePaths
          withNumOfEach:(int)num
               withSize:(CGSize) size
     connectsAllToFirst:(BOOL)connectsAll;

- (void) drawGL;

- (void)keyDown:(NSEvent *)event;

- (void) tuioBoundsAdded:(TuioBounds*) newBounds;
- (void) tuioBoundsUpdated:(TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved:(TuioBounds*) deadBounds;

- (void) contactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj;
- (void) removedContactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj;

@end