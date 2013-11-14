//
//  consts.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#ifndef FancyTracker_consts_h
#define FancyTracker_consts_h

#pragma mark Debug Flags
#define DEBUG_TOUCH_STATE TRUE
#define DEBUG_TOUCH_MOVE_STATE TRUE
#define DEBUG_LISTENER_STATE FALSE
#define DEBUG_LISTENER_MOVE_STATE FALSE
#define DEBUG_RENDER_STATE TRUE
#define DEBUG_PHYSICS_STATE FALSE
#define DEBUG_ERROR_STATE TRUE

#define DEBUG_GENERAL_STATE TRUE

typedef enum debugstate {DEBUG_TOUCH, DEBUG_TOUCH_MOVE, DEBUG_LISTENER, DEBUG_LISTENER_MOVE, DEBUG_GENERAL, DEBUG_RENDER, DEBUG_PHYSICS, DEBUG_ERROR} DebugState;
#pragma mark -

#pragma mark Math Constants
#define PI 3.14159265f
#define DEG2RAD PI / 180.0f
#define RAD2DEG 180.f / PI
#pragma mark -

#define MIN_RANDOM_COLOR 40
#define BACKGROUND 0.f, 0.f, 0.f //BLACK

#define PHYSICS_DRAG_ELASTICITY 1000.f
#define ELLIPSOID_RESOLUTION 12
#define PHYSICS_SCALE 100.f
#define PHYSICS_SENSOR_FACTOR 3.f
#endif
