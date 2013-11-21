//
//  FTConnection.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/13/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTConnection.h"

@implementation FTConnection

- (id) initWithendA:(FTInteractiveObject*) endA
			   endB:(FTInteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending
{
    if(self = [super init])
    {
		if(endA.position.x <= endB.position.x)
		{
			_endA = endA;
			_endB = endB;
		} else
		{
			_endA = endB;
			_endB = endA;
		}
        
        _begin = beginnning;
        _end = ending;
    }
    
    return self;
}

#pragma mark Property Accessors
- (float) length
{
	return [FTUtilityFunctions distanceBetweenPoint:_endA.position andPoint:_endB.position];
}

- (float) connectionAngle
{
	return [FTUtilityFunctions angleBetweenPoint:_endA.position andPoint:_endB.position];
}
#pragma mark -

@end
