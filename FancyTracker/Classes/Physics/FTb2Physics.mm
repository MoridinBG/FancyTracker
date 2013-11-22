//
//  FTb2Physics.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTb2Physics.h"

@implementation FTb2Physics


- (id) init
{
	if(self = [super init])
	{
		timeStep = 1.0f / 60.0f;
		velocityIterations = 10;
		positionIterations = 10;
		
		b2Vec2 gravity(0.0f, 0.0f);
		
		_world =  new b2World(gravity);
		b2BodyDef frameBodyDef;
		_groundBody = _world->CreateBody(&frameBodyDef);
		
		mouseJoints = [[NSMutableDictionary alloc] init];
        
        
        uint32 flags = 0;
        flags += 1			* b2Draw::e_shapeBit;
        flags += 0			* b2Draw::e_jointBit;
        flags += 0			* b2Draw::e_aabbBit;
        flags += 0			* b2Draw::e_pairBit;
        flags += 0			* b2Draw::e_centerOfMassBit;
        debugDraw.SetFlags(flags);
        _world->SetDebugDraw(&debugDraw);
        
        _lockedDeadBodies = [[NSMutableArray alloc] init];
        _lockedDeadJoints = [[NSMutableArray alloc] init];
        
        _mustDebugDraw = FALSE;
	}
	return self;
}

//Creates a box around the window preventing physics bodies from escaping
- (void) createGroundWithDimensions:(CGSize)dimensions
{
    b2Vec2 vs[4];
    vs[0].Set(0.f, 0.f);
    vs[1].Set(dimensions.width * PHYSICS_SCALE, 0.f);
    vs[2].Set(dimensions.width * PHYSICS_SCALE, dimensions.height * PHYSICS_SCALE);
    vs[3].Set(0.f, dimensions.height * PHYSICS_SCALE);
    
    b2ChainShape box;
    box.CreateLoop(vs, 4);
    
    b2BodyDef bodyDef;
    bodyDef.position.Set(0.0f, 0.0f);
    b2Body* body = _world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);;
}

//Step the b2Body. Also destroy bodies and joits that have been sent for destruction during a step
- (void) step
{
    _world->Step(timeStep, velocityIterations, positionIterations);
    _world->ClearForces();
    
    if(_mustDebugDraw)
        _world->DrawDebugData();
    
    for(NSValue *packedBody in _lockedDeadBodies)
        [self destroyBody:packedBody];
    
    for(NSValue *packedJoint in _lockedDeadJoints)
        [self destroyJoint:packedJoint];
    
    [_lockedDeadBodies removeAllObjects];
    [_lockedDeadJoints removeAllObjects];
}

//Create and return a new contact detector
- (FTContactDetector *) addContactDetector
{
	FTContactDetector *contactDetector = [[FTContactDetector alloc] init];
	_world->SetContactListener(contactDetector.box2DContactDetector);
	
	return contactDetector;
}

- (void) removeContactDetector
{
    _world->SetContactListener(NULL);
}

#pragma mark -
#pragma mark Create/Destroy Bodies

//Create a new rectangle
- (void) attachRectangleBodyWithSize:(CGSize)size
                           rotatedAt:(float)angle
                         withDensity:(float)density
                     withRestitution:(float)restitution
                            toObject:(FTInteractiveObject *)object
{
    CGPoint position = object.position;
    position.x *= PHYSICS_SCALE;
    position.y *= PHYSICS_SCALE;
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(position.x, position.y);
	b2Body* body = _world->CreateBody(&bodyDef);
    
    object.physicsSize = size;
    size.width *= PHYSICS_SCALE / 2.f;
    size.height *= PHYSICS_SCALE / 2.f;
    
	b2PolygonShape solidBox;
    solidBox.SetAsBox(size.width, size.height);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &solidBox;
	fixtureDef.density = density;
    fixtureDef.restitution = restitution;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
}

- (FTInteractiveObject*) createRectangleBodyAtPosition:(CGPoint)position
                                              withSize:(CGSize)size
                                             rotatedAt:(float)angle
                                           withDensity:(float)density
                                       withRestitution:(float)restitution
{
    
	
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
                                                                       atAngle:angle
                                                                      withSize:size
                                                               physicsBackedBy:nil
                                                                      withType:RECTANGLE];
	[self attachRectangleBodyWithSize:size
                            rotatedAt:angle
                          withDensity:density
                      withRestitution:(float)restitution
                             toObject:objBody];
	return objBody;
}
#pragma mark -
- (void) attachCircleBodyWithSize:(CGSize)size
                      withDensity:(float)density
                  withRestitution:(float)restitution
						 toObject:(FTInteractiveObject*)object
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x * PHYSICS_SCALE,
                         object.position.y * PHYSICS_SCALE);
	
	b2Body* body = _world->CreateBody(&bodyDef);
	
	b2CircleShape circle;
	circle.m_radius = (size.width * PHYSICS_SCALE) / 2.f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 10.0f;
    fixtureDef.restitution = restitution;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
}

- (FTInteractiveObject*) createCircleBodyAtPosition:(CGPoint)position
                                           withSize:(CGSize)size
                                        withDensity:(float)density
                                    withRestitution:(float)restitution
{
	size.width = size.height;
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
                                                                       atAngle:0.f
                                                                      withSize:size
                                                               physicsBackedBy:nil
                                                                      withType:CIRCLE];
	[self attachCircleBodyWithSize:size
                       withDensity:density
                   withRestitution:restitution
                          toObject:objBody];
	return objBody;
	
}
#pragma mark -

- (void) attachEllipsoidBodyWithSize:(CGSize)size
                           rotatedAt:(float)angle
                         withDensity:(float)density
                     withRestitution:(float)restitution
                            toObject:(FTInteractiveObject*)object
{
    if(size.width <= 0.f || size.height <= 0)
        return;
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x * 100, object.position.y * 100);
	b2Body* body = _world->CreateBody(&bodyDef);
    object.physicsSize = size;
    
    b2Vec2 vertices[ELLIPSOID_RESOLUTION];
    
    float angleStep = 360.f / (ELLIPSOID_RESOLUTION - 1);
    size.width *= 50.f;
    size.height *= 50.f;
    
    for(int i = 0; i < ELLIPSOID_RESOLUTION; i++)
    {
        vertices[i].Set(cos(i * angleStep * DEG2RAD)  * size.width,
                        sin(i * angleStep * DEG2RAD)  * size.height);
    }
    
    b2PolygonShape ellips;
    ellips.Set(vertices, ELLIPSOID_RESOLUTION);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &ellips;
	fixtureDef.density = LOGO_DENSITY;
    fixtureDef.restitution = LOGO_RESTITUTION;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
    object.type = ELLIPSE;
}

- (FTInteractiveObject*) createEllipsoidleBodyAtPosition:(CGPoint)position
                                                withSize:(CGSize)size
                                               rotatedAt:(float)angle
                                             withDensity:(float)density
                                         withRestitution:(float)restitution
{
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
                                                                       atAngle:0.f
                                                                      withSize:size
                                                               physicsBackedBy:nil
                                                                      withType:ELLIPSE];
	[self attachEllipsoidBodyWithSize:size
                            rotatedAt:angle
                          withDensity:density
                      withRestitution:restitution
                             toObject:objBody];
	
	return objBody;
}
#pragma mark -

- (void) destroyBody:(NSValue*)packedBody
{
    b2Body *body = (b2Body*) [packedBody pointerValue];
    if(_world->IsLocked())
    {
        [_lockedDeadBodies addObject:packedBody];
        return;
    } else
    {
        if(body != NULL)
        {
            if(body->GetWorld() != _world)
            {
                NSLog(@"Aliens");
            }
            if(body->GetUserData() != NULL)
                CFRelease(body->GetUserData());
            
            _world->DestroyBody(body);
            body = NULL;
        } else
            NSLog(@"Attempt to destroy NULL body");
    }
}
#pragma mark -

#pragma mark Create Sensors
- (void) attachRectangleSensorWithSize:(CGSize)size
                             rotatedAt:(float)angle
                              toObject:(FTInteractiveObject*)object
{
    b2Body* body;
    if((object.physicsData != nil) && ([object.physicsData pointerValue] != NULL))
    {
        body = (b2Body*) [object.physicsData pointerValue];
    } else
    {
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(object.position.x * PHYSICS_SCALE, object.position.y * PHYSICS_SCALE);
        body = _world->CreateBody(&bodyDef);
        
        body->SetUserData((__bridge_retained void *) object);
        object.physicsData = [NSValue valueWithPointer:body];
    }
	
	b2PolygonShape solidBox;
	solidBox.SetAsBox(size.width / 2.f * PHYSICS_SCALE * PHYSICS_SENSOR_FACTOR,
					  size.height / 2.f * PHYSICS_SCALE * PHYSICS_SENSOR_FACTOR);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &solidBox;
	fixtureDef.density = 1.0f;
	fixtureDef.isSensor = true;
	fixtureDef.userData = (__bridge_retained void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
}

- (FTInteractiveObject*) createRectangleSensorAtPosition:(CGPoint)position
                                                withSize:(CGSize)size
                                               rotatedAt:(float)angle
{
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
                                                                       atAngle:0.f
                                                                      withSize:size
                                                               physicsBackedBy:nil
                                                                      withType:RECTANGLE_SENSOR];
	[self attachRectangleSensorWithSize:size
                              rotatedAt:angle
                               toObject:objBody];
	
	return objBody;
}
#pragma mark -
- (void) attachCircleSensorWithSize:(CGSize)size
						   toObject:(FTInteractiveObject*)object
{
    b2Body* body;
    if((object.physicsData != nil) && ([object.physicsData pointerValue] != NULL))
    {
        body = (b2Body*) [object.physicsData pointerValue];
    } else
    {
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(object.position.x * PHYSICS_SCALE, object.position.y * PHYSICS_SCALE);
        body = _world->CreateBody(&bodyDef);
        
        body->SetUserData((__bridge_retained void *) object);
        object.physicsData = [NSValue valueWithPointer:body];
    }
	
	b2CircleShape circle;
	circle.m_radius = (size.width / 2.f) * PHYSICS_SCALE * PHYSICS_SENSOR_FACTOR;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 1.f;
	fixtureDef.isSensor = true;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
}

- (FTInteractiveObject*) createCircleSensorAtPosition:(CGPoint)position
                                             withSize:(CGSize)size
{
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
                                                                       atAngle:0.f
                                                                      withSize:size
                                                               physicsBackedBy:nil
                                                                      withType:CIRCLE_SENSOR];
	[self attachCircleSensorWithSize:size
							toObject:objBody];
	
	return objBody;
}
#pragma mark -

- (void) attachEllipsoidSensorWithSize:(CGSize)size
                             rotatedAt:(float)angle
                              toObject:(FTInteractiveObject*)object
{
    if(size.width <= 0.f || size.height <= 0)
        return;
    
    b2Body* body;
    if((object.physicsData != nil) && ([object.physicsData pointerValue] != NULL))
    {
        body = (b2Body*) [object.physicsData pointerValue];
    } else
    {
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(object.position.x * 100, object.position.y * 100);
        body = _world->CreateBody(&bodyDef);
        body->SetUserData((__bridge_retained void *) object);
        
        object.physicsSize = size;
        object.physicsData = [NSValue valueWithPointer:body];
    }
    
    b2PolygonShape ellips;
    b2Vec2 vertices[ELLIPSOID_RESOLUTION];
    
    object.physicsSize = size;
    
    float angleStep = 360.f / (ELLIPSOID_RESOLUTION - 1);
    size.width *= 50.f * PHYSICS_SENSOR_FACTOR;
    size.height *= 50.f * PHYSICS_SENSOR_FACTOR;
    
    for(int i = 0; i < ELLIPSOID_RESOLUTION; i++)
    {
        vertices[i].Set(cos(i * angleStep * DEG2RAD)  * size.width,
                        sin(i * angleStep * DEG2RAD)  * size.height);
    }
    
    ellips.Set(vertices, ELLIPSOID_RESOLUTION);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &ellips;
	fixtureDef.density = 1.f;
    fixtureDef.restitution = 1.f;
    fixtureDef.isSensor = TRUE;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
}

#pragma mark -

#pragma mark Create Joints
- (NSValue*) distanceJointBody:(NSValue*)packedBody1
                      withBody:(NSValue*)packedBody2
                      withFreq:(float)freq
                      withDamp:(float)damp
{
    b2Body *body1 = (b2Body*) [packedBody1 pointerValue];
    b2Body *body2 = (b2Body*) [packedBody2 pointerValue];
    
    b2DistanceJointDef jointDef;
    
    jointDef.Initialize(body1, body2, body1->GetWorldCenter(), body2->GetWorldCenter());
    jointDef.collideConnected = true;
    jointDef.frequencyHz = freq;
    jointDef.dampingRatio = damp;
    
    
    if(!_world->IsLocked())
        return [NSValue valueWithPointer:_world->CreateJoint(&jointDef)];
    else
        return nil;
}

- (void) destroyJoint:(NSValue*)packedJoint
{
    if(_world->IsLocked())
    {
        [_lockedDeadJoints addObject:packedJoint];
        return;
    } else
    {
        b2Joint *joint = (b2Joint*)[packedJoint pointerValue];
        if(joint != NULL)
            _world->DestroyJoint(joint);
        else
            NSLog(@"Attempt to destroy NULL body");
    }
}
#pragma mark -

#pragma mark Create/Destroy Mouse Joints
- (void) attachMouseJointToBody:(NSValue*)packedBody withId:(NSNumber*)uid
{
    if(packedBody != nil)
    {
        b2Body* body = (b2Body*) [packedBody pointerValue];
        if(body != NULL)
        {
            b2MouseJointDef mouseDef;
            mouseDef.bodyA = _groundBody;
            mouseDef.bodyB = body;
            mouseDef.target = body->GetWorldCenter();
            mouseDef.maxForce = PHYSICS_DRAG_ELASTICITY * 10.f * body->GetMass();
            
            [mouseJoints setObject:[NSValue valueWithPointer:_world->CreateJoint(&mouseDef)] forKey:uid];
        }
    }
}

- (void) detachMouseJointWithId:(NSNumber*)uid
{
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		_world->DestroyJoint(joint);
		[mouseJoints removeObjectForKey:uid];
	}
}

- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position
{
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		joint->SetTarget(b2Vec2(position.x * 100, position.y * 100));
	}
}
#pragma mark -


@end
