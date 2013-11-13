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
        
        debugDraw.SetFlags(b2Draw::e_shapeBit);
        _world->SetDebugDraw(&debugDraw);
        
        /*
         uint32 flags = 0;
         flags += 1			* b2DebugDraw::e_shapeBit;
         flags += 1			* b2DebugDraw::e_jointBit;
         flags += 1			* b2DebugDraw::e_aabbBit;
         flags += 1			* b2DebugDraw::e_pairBit;
         flags += 1			* b2DebugDraw::e_centerOfMassBit;
         debugDraw.SetFlags(flags);
         _world->SetDebugDraw(&debugDraw);
         //*/
        /*
         NSInvocationOperation* evolution = [[NSInvocationOperation alloc] initWithTarget:self
         selector:@selector(step)
         object:nil];
         
         operationQueue = [[NSOperationQueue alloc] init];
         [operationQueue addOperation:evolution];
         //*/
	}
	return self;
}

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

- (void) step
{
    //	while(1)
	{
        //		uint64_t start = mach_absolute_time();
		_world->Step(timeStep, velocityIterations, positionIterations);
		_world->ClearForces();
        /*
         uint64_t end = mach_absolute_time();
         uint64_t diff = end - start;
         
         Nanoseconds nanoSeconds = AbsoluteToNanoseconds( *(AbsoluteTime *) &diff );
         uint64_t microSeconds = *(uint64_t *) &nanoSeconds / 1000;
         int sleepTime = 16667 - microSeconds;
         
         if(sleepTime > 0)
         usleep(16667 - microSeconds);
         //*/
        _world->DrawDebugData();
	}
}

- (FTContactDetector *) addContactDetector
{
	FTContactDetector *contactDetector = [[FTContactDetector alloc] init];
	_world->SetContactListener(contactDetector.box2DContactDetector);
	
	return contactDetector;
}

#pragma mark -
#pragma mark Create/Destroy Bodies

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
	
    
    b2Vec2 vertices[4];
    
    object.physicsSize = size;
    size.width *= PHYSICS_SCALE / 2.f;
    size.height *= PHYSICS_SCALE / 2.f;
    
    vertices[0].Set(- size.width, - size.height);
    vertices[1].Set(- size.width, size.height);
    vertices[2].Set(size.width, - size.height);
    vertices[3].Set(size.width, size.height);
    
	b2PolygonShape solidBox;
	solidBox.Set(vertices, 4);
	
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
                            toObject:(FTInteractiveObject*)object
{
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x * 100, object.position.y * 100);
	b2Body* body = _world->CreateBody(&bodyDef);
	
    b2Vec2 vertices[ELLIPSOID_RESOLUTION];
    
    object.physicsSize = size;
    
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
	fixtureDef.density = 1.0f;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
}

- (FTInteractiveObject*) createEllipsoidleBodyAtPosition:(CGPoint)position
                                                withSize:(CGSize)size
                                               rotatedAt:(float)angle
{
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
                                                                       atAngle:0.f
                                                                      withSize:size
                                                               physicsBackedBy:nil
                                                                      withType:RECTANGLE_SENSOR];
	[self attachEllipsoidBodyWithSize:size
                            rotatedAt:angle
                             toObject:objBody];
	
	return objBody;
}
#pragma mark -

- (void) attachRectangleSensorWithSize:(CGSize)size
                             rotatedAt:(float)angle
                              toObject:(FTInteractiveObject*)object
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x, object.position.y);
	b2Body* body = _world->CreateBody(&bodyDef);
	if(!body)
	{
		NSLog(@"Fail");
		_world->Step(timeStep, 1, 1);
		body = _world->CreateBody(&bodyDef);
		
		if(!body)
			NSLog(@"Fail not prevented");
	}
	
	b2PolygonShape solidBox;
	solidBox.SetAsBox(size.width / 2.f,
					  size.height / 2.f);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &solidBox;
	fixtureDef.density = 1.0f;
	fixtureDef.isSensor = true;
	fixtureDef.userData = (__bridge_retained void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
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
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x, object.position.y);
	b2Body* body = _world->CreateBody(&bodyDef);
	
	b2CircleShape circle;
	circle.m_radius = size.width / 2.f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 0.1f;
	fixtureDef.isSensor = true;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
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

//TODO: Need implementation of ConstantAreBlob
- (NSMutableArray *) createBlobAt:(CGPoint)position
					   withRadius:(float) blobRadius
{
    
    /*
     int nodes = 30;
     NSMutableArray *objBodies = [[NSMutableArray alloc] initWithCapacity:nodes];
     float pointRadius = 0.025f;
     
     float twoPi = 2.0f * 3.14159f;
     
     ConstantVolumeJointDef springsDef;
     springsDef.frequencyHz = 10.f;
     springsDef.dampingRatio = 0.5f;
     
     b2BodyDef bd;
     
     
     for(int i = 0; i <= nodes - 1; i++)
     {
     CGPoint pointPosition = CGPointMake(position.x + blobRadius * cos(i * twoPi / nodes),
     position.y + blobRadius * sin(i * twoPi / nodes));
     InteractiveObject *objBody = [self createCircleBodyAtPosition:pointPosition
     withSize:CGSizeMake(pointRadius, pointRadius)];
     //		objBody.categoryBits = 0x0004;
     //		objBody.maskBits = 0x0002;
     
     springsDef.addBody((b2Body*)[objBody.physicsData pointerValue]);
     [objBodies addObject:objBody];
     }
     
     _world->CreateJoint(&springsDef);
     
     return objBodies;
     //*/
    return nil;
}

- (void) destroyBody:(NSValue*)packedBody
{
    b2Body *body = (b2Body*)[packedBody pointerValue];
    CFRelease(body->GetUserData());
	_world->DestroyBody(body);
}
#pragma mark -

#pragma mark Create/Destroy Mouse Joints
- (void) attachMouseJointToBody:(NSValue*)packedBody withId:(NSNumber*)uid
{
	b2Body* body = (b2Body*) [packedBody pointerValue];
	b2MouseJointDef mouseDef;
	mouseDef.bodyA = _groundBody;
	mouseDef.bodyB = body;
	mouseDef.target = body->GetWorldCenter();
	mouseDef.maxForce = PHYSICS_DRAG_ELASTICITY * 10.f * body->GetMass();
    
	[mouseJoints setObject:[NSValue valueWithPointer:_world->CreateJoint(&mouseDef)] forKey:uid];
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
