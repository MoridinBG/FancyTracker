//
//  FTInteractiveObject.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTInteractiveObject.h"

@implementation FTInteractiveObject

#pragma mark Initialization
+ (id) interactiveFrom:(TuioBounds*)bounds
{
	FTInteractiveObject *interactive = [FTInteractiveObject alloc];
	if((interactive = [interactive initAtPosition:bounds.position
                                          atAngle:bounds.angle * RAD2DEG
                                         withSize:bounds.dimensions]))
	{
		interactive.uid = [bounds getKey];
		if(bounds.contour)
			interactive.contour =  bounds.contour;
		if(bounds.contourHistory)
			interactive.contourHistory = bounds.contourHistory;
		
		if((bounds.dimensions.width == 0.f) && (bounds.dimensions.height == 0.f))
			interactive.size = CGSizeMake(0.15f, 0.15f);
	}
	return interactive;
}

- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size
{
	if(self = [super init])
	{
		_position = position;
		_angle = angle;
		_size = size;
		
		_contour = [[NSMutableArray alloc] init];
        _contourHistory = [[NSMutableArray alloc] init];
        
		_neighbours = [[NSMutableArray alloc] init];
		_connectedNeighbours = [[NSMutableDictionary alloc] init];
		
		_type = CIRCLE;
        
        _physicsData = NULL;
        
//        _uid = [FTUtilityFunctions buildUUID];
	}
	
	return self;
}

- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size
	  physicsBackedBy:(b2Body*)physicsBody
			 withType:(Type)type;
{
	if(self = [self initAtPosition:position
						   atAngle:angle
						  withSize:size])
	{
		_physicsData = physicsBody;
		_type = type;
	}
	return self;
}

#pragma mark -

#pragma mark Accessors

- (CGPoint) position
{
    if(_isPhysicsControlled && (_physicsData != NULL))
    {
        _position = CGPointMake(_physicsData->GetPosition().x / PHYSICS_SCALE,
                                _physicsData->GetPosition().y / PHYSICS_SCALE);
        return _position;
    } else
        return _position;
}

- (void) setPosition:(CGPoint)position
{
    _position = position;
}

- (float) angle
{
    if(_isPhysicsControlled && (_physicsData != NULL))
    {
        _angle = _physicsData->GetAngle();
        return _angle;
    } else
        return _angle;
}

- (void) setAngle:(float)angle
{
    if(_isPhysicsControlled && (_physicsData != NULL))
        NSLog(@"Ignoring setting angle on physics backed body");
    else
        _angle = angle;
}

- (CGSize) size
{
    return _size;
}

- (void) setSize:(CGSize)size
{
    _size = size;
    if(_shouldResizePhysics && _physicsData != NULL && self.size.height > 0.f && self.size.width > 0.f)
    {
        if(fabs(1 - ((self.size.width * self.size.height) / (self.physicsSize.width * self.physicsSize.height))) > PHYS_AREA_DIFF)
        {
            _physicsSize = self.size;
            switch(_type)
            {
                case ELLIPSE:
                {
                    b2Fixture *fixtures = _physicsData->GetFixtureList();
                    for(b2Fixture* f = fixtures; f; f = f->GetNext())
                    {
                        _physicsData->DestroyFixture(f);
                    }
                    
                    b2Vec2 vertices[ELLIPSOID_RESOLUTION];
                    
                    float angleStep = 360.f / ELLIPSOID_RESOLUTION;
                    
                    for(int i = 0; i < ELLIPSOID_RESOLUTION; i++)
                    {
                        vertices[i].Set(cos(i * angleStep * DEG2RAD)  * self.size.width * 50.f,
                                        sin(i * angleStep * DEG2RAD)  * self.size.height * 50.f);
                    }
                    
                    b2PolygonShape ellips;
                    ellips.Set(vertices, ELLIPSOID_RESOLUTION);
                    
                    b2FixtureDef fixtureDef;
                    fixtureDef.shape = &ellips;
                    fixtureDef.density = 1.0f;
                    fixtureDef.userData = (__bridge void *) self;
                    
                    _physicsData->CreateFixture(&fixtureDef);
                } break;
                    
                case CIRCLE:
                {
                    BOOL bodyFixture = FALSE;
                    BOOL sensorFixture = FALSE;
                    
                    b2CircleShape circleBody;
                    circleBody.m_radius = (_physicsSize.width * PHYSICS_SCALE) / 2.f;
                    
                    b2FixtureDef fixtureDefBody;
                    fixtureDefBody.shape = &circleBody;
                    fixtureDefBody.userData = (__bridge void *) self;

                    b2CircleShape circleSensor;
                    circleSensor.m_radius = ((_physicsSize.width * PHYSICS_SCALE) / 2.f) * PHYSICS_SENSOR_FACTOR;
                    
                    b2FixtureDef fixtureDefSensor;
                    fixtureDefSensor.shape = &circleSensor;
                    fixtureDefSensor.userData = (__bridge void *) self;
                    
                    b2Fixture *fixtures = _physicsData->GetFixtureList();
                    while(fixtures)
                    {
                        b2Fixture *copy = fixtures;
                        fixtures = fixtures->GetNext();
                        
                        if(!copy->IsSensor())
                        {
                            bodyFixture = TRUE;
                            fixtureDefBody.density = copy->GetDensity();
                            fixtureDefBody.restitution = copy->GetRestitution();
                        } else
                        {
                            sensorFixture = TRUE;
                            fixtureDefSensor.isSensor = true;
                        }
                        
                        _physicsData->DestroyFixture(copy);
                    }
                    
                    if(bodyFixture)
                        _physicsData->CreateFixture(&fixtureDefBody);
                    if(sensorFixture)
                        _physicsData->CreateFixture(&fixtureDefSensor);
                    
                } break;
                    
                default:
                {
                } break;
            }
        }
    }
}

#pragma mark -

#pragma mark TUIO
- (void) updateWithTuioBounds:(TuioBounds*)bounds
{
	self.position = bounds.position;
	self.positionHistory = bounds.movementHistory; //TODO: Check if assigment is neccessery
	self.angle = bounds.angle * RAD2DEG;
	self.size = bounds.dimensions;
	self.velocity = bounds.movementVelocity;
	self.contour = bounds.contour;
    
}
#pragma mark -

#pragma mark Physics packing

- (void) setPhysicsData:(NSValue *)data
{
	if(_physicsData && data != nil)
		_physicsData->GetWorld()->DestroyBody(_physicsData);
	_physicsData = (b2Body*) [data pointerValue];
}

- (NSValue*) physicsData
{
	if(_physicsData)
		return [NSValue valueWithPointer:_physicsData];
	else
		return nil;
	
}

- (void) setFixedPhysicsRotation:(BOOL) rotation
{
    _physicsData->SetFixedRotation(rotation);
}

- (void) destroyPhysicsData
{
	if (_physicsData)
		_physicsData->GetWorld()->DestroyBody(_physicsData);
}

#pragma mark -


#pragma mark Manage Neighbours
- (void) addNeighbour:(FTInteractiveObject*)neighbour
{
	[_neighbours addObject:neighbour];
}

- (void) removeNeighbour:(FTInteractiveObject*)neigbour
{
	[_neighbours removeObject:neigbour];
}

- (void) connectTo:(FTInteractiveObject*)neighbour withConnection:(FTConnection*)connection;
{
	[_connectedNeighbours setObject:connection forKey:neighbour.uid];
}

- (FTConnection*) disconnectFrom:(FTInteractiveObject*)neighbour
{
	FTConnection *connection = [_connectedNeighbours objectForKey:neighbour.uid];
	[_connectedNeighbours removeObjectForKey:neighbour.uid];
    
	return connection;
}

- (bool) isConnectedToNeighbour:(FTInteractiveObject *)neighbour
{
	NSArray *connecteds = [_connectedNeighbours allKeys];
	return [connecteds containsObject:neighbour.uid];
}

- (unsigned long) neighboursCount
{
	return [_neighbours count];
}

- (unsigned long) connectedNeighboursCount
{
	return [_connectedNeighbours count];
}
#pragma mark -

@end
