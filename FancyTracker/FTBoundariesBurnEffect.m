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
//		[self addBurningFilter];
	}
	return self;
}

- (void) addBurningFilter
{
	CIFilter *bloom = [CIFilter filterWithName:@"CIBloom"];
	[bloom setDefaults];
	bloom.name = @"bloom";
	
    CIFilter *blur = [CIFilter filterWithName:@"CIDiscBlur"];
	[blur setDefaults];
	blur.name = @"blur";
	[blur setValue:[NSNumber numberWithFloat:5.f] forKey:@"inputRadius"];
	[self setFilters:[NSArray arrayWithObjects:bloom, blur, nil]];
	
	[self setValue:[NSNumber numberWithFloat:5.0f]
		forKeyPath:[NSString stringWithFormat:@"filters.bloom.%@", kCIInputIntensityKey]];
	[self setValue:[NSNumber numberWithFloat:20.0f]
		forKeyPath:[NSString stringWithFormat:@"filters.bloom.%@", kCIInputRadiusKey]];
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
