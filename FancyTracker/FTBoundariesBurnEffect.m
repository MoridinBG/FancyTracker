//
//  FTBoundariesBurnEffect.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBoundariesBurnEffect.h"

@implementation FTBoundariesBurnEffect

- (id) init
{
	if(self = [super init])
	{
		NSLog(@"Boundaries Burn");
//		[self addBurningFilter];
	}
	return self;
}

- (void) drawGL
{
    for(NSNumber *key in [_blobs allKeys])
	{
        [(FTRGBA*)[[_blobs objectForKey:key] color] stepColors];
        
        [self renderContourOfObject:[_blobs objectForKey:key]];
        
	}
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	[super tuioBoundsAdded:newBounds];
	FTInteractiveObject * object = [_blobs objectForKey:[newBounds getKey]];
	object.color = [FTRGBA randomColorWithMinimumValue:10];
}

@end
