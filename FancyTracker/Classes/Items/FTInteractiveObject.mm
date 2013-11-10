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
	if(_physicsData)
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
