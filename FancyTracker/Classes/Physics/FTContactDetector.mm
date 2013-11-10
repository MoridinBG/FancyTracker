//
//  FTContactDetector.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTContactDetector.h"

@implementation FTContactDetector

- (id) init
{
	if(self = [super init])
	{
		_box2DContactDetector = new FTContactDetectorCpp(self);
	}
	return self;
}

- (void) contactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj
{
	[_effect contactBetween:firstObj And:secondObj];
}

- (void) removedContactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj
{
	[_effect removedContactBetween:firstObj And:secondObj];
}

@end