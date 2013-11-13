//
//  FTPictureReveal.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/12/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTPictureReveal.h"

@implementation FTPictureReveal

- (id) init
{
    if(self = [super init])
    {
    }
    
    return self;
}

- (void) drawGL
{
    for(FTInteractiveObject *blob in [_blobs allValues])
	{
        [[blob color] stepColors];
        [self renderContourOfObject:blob];
	}
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	[super tuioBoundsAdded:newBounds];
	FTInteractiveObject * object = [_blobs objectForKey:[newBounds getKey]];
	object.color = [FTRGBA randomColorWithMinimumValue:10];
}

@end
