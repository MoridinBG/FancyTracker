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
		
		bool sleep = true;
		b2Vec2 gravity(0.0f, 0.0f);
		
		world =  new b2World(gravity);
		b2BodyDef frameBodyDef;
		_groundBody = world->CreateBody(&frameBodyDef);
		
		mouseJoints = [[NSMutableDictionary alloc] init];
        
        /*
         uint32 flags = 0;
         flags += 1			* b2DebugDraw::e_shapeBit;
         flags += 1			* b2DebugDraw::e_jointBit;
         flags += 1			* b2DebugDraw::e_aabbBit;
         flags += 1			* b2DebugDraw::e_pairBit;
         flags += 1			* b2DebugDraw::e_centerOfMassBit;
         debugDraw.SetFlags(flags);
         world->SetDebugDraw(&debugDraw);
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
	float aspect = dimensions.width / dimensions.height;
	
	b2BodyDef frameBodyDef;
	
	frameBodyDef.position.Set(aspect / 2.f, 0.5f);
	
	b2Body* frameBody = world->CreateBody(&frameBodyDef);
	
	b2FixtureDef fixtureDef;
	fixtureDef.filter.categoryBits = 0x0002;
	fixtureDef.filter.maskBits = 0x0004;
	b2PolygonShape groundBox;
	
	groundBox.SetAsBox(aspect / 2.f, 0.05f, b2Vec2(0.f, 0.5f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
	
	groundBox.SetAsBox(0.05f, 0.5f, b2Vec2(aspect / 2.f, 0.f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
	
	groundBox.SetAsBox(aspect / 2.f, 0.05f, b2Vec2(0.f, -0.5f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
	
	groundBox.SetAsBox(0.05f, 0.5f, b2Vec2(-aspect / 2.f, 0.f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
}

- (void) step
{
    //	while(1)
	{
        //		uint64_t start = mach_absolute_time();
		world->Step(timeStep, velocityIterations, positionIterations);
		world->ClearForces();
        /*
         uint64_t end = mach_absolute_time();
         uint64_t diff = end - start;
         
         Nanoseconds nanoSeconds = AbsoluteToNanoseconds( *(AbsoluteTime *) &diff );
         uint64_t microSeconds = *(uint64_t *) &nanoSeconds / 1000;
         int sleepTime = 16667 - microSeconds;
         
         if(sleepTime > 0)
         usleep(16667 - microSeconds);
         //*/
	}
}

- (FTContactDetector *) addContactDetector
{
	FTContactDetector *contactDetector = [[FTContactDetector alloc] init];
	world->SetContactListener(contactDetector.box2DContactDetector);
	
	return contactDetector;
}
#pragma mark -
#pragma mark Create/Destroy Bodies

- (void) attachRectangleBodyWithSize:(CGSize)size
                           rotatedAt:(float)angle
                            toObject:(FTInteractiveObject*)object
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x, object.position.y);
	b2Body* body = world->CreateBody(&bodyDef);
	
	b2PolygonShape solidBox;
	solidBox.SetAsBox(size.width / 2.f,
					  size.height / 2.f);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &solidBox;
	fixtureDef.density = 1.0f;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
}

- (FTInteractiveObject*) createRectangleBodyAtPosition:(CGPoint)position
                                            withSize:(CGSize)size
                                           rotatedAt:(float)angle
{
    
	
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
																   atAngle:angle
																  withSize:size
														   physicsBackedBy:nil
																  withType:RECTANGLE];
	[self attachRectangleBodyWithSize:size
                            rotatedAt:angle
                             toObject:objBody];
	return objBody;
}
#pragma mark -
- (void) attachCircleBodyWithSize:(CGSize)size
						 toObject:(FTInteractiveObject*)object
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(object.position.x, object.position.y);
	
	b2Body* body = world->CreateBody(&bodyDef);
	
	b2CircleShape circle;
	circle.m_radius = size.width / 2.f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 10.0f;
	fixtureDef.userData = (__bridge void *) object;
	
	body->CreateFixture(&fixtureDef);
	body->SetUserData((__bridge_retained void *) object);
	
	object.physicsData = [NSValue valueWithPointer:body];
}

- (FTInteractiveObject*) createCircleBodyAtPosition:(CGPoint)position
										 withSize:(CGSize)size
{
	size.width = size.height;
	FTInteractiveObject *objBody = [[FTInteractiveObject alloc] initAtPosition:position
																   atAngle:0.f
																  withSize:size
														   physicsBackedBy:nil
																  withType:CIRCLE];
	[self attachCircleSensorWithSize:size
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
	b2Body* body = world->CreateBody(&bodyDef);
	if(!body)
	{
		NSLog(@"Fail");
		world->Step(timeStep, 1, 1);
		body = world->CreateBody(&bodyDef);
		
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
	b2Body* body = world->CreateBody(&bodyDef);
	
	b2CircleShape circle;
	circle.m_radius = size.width / 2.f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 1.0f;
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
     
     world->CreateJoint(&springsDef);
     
     return objBodies;
     //*/
    return nil;
}

- (void) destroyBody:(NSValue*)packedBody
{
    b2Body *body = (b2Body*)[packedBody pointerValue];
    CFRelease(body->GetUserData());
	world->DestroyBody(body);
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
	mouseDef.maxForce = PHYSICS_DRAG_ELASTICITY * body->GetMass();
    
	[mouseJoints setObject:[NSValue valueWithPointer:world->CreateJoint(&mouseDef)] forKey:uid];
}

- (void) detachMouseJointWithId:(NSNumber*)uid
{
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		world->DestroyJoint(joint);
		[mouseJoints removeObjectForKey:uid];
	}
}

- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position
{
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		joint->SetTarget(b2Vec2(position.x, position.y));
	}
}
#pragma mark -


@end
