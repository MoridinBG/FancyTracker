//  FTColorTrails.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTColorTrails.h"


@implementation FTColorTrails

- (id) init
{
	if(self = [super init])
	{
		[self addBlurFilter];
	}
	return self;
}

- (void) addBlurFilter
{
	CIFilter *blur = [CIFilter filterWithName:@"CIDiscBlur"];
	[blur setDefaults];
	blur.name = @"blur";
	[blur setValue:[NSNumber numberWithFloat:5.f] forKey:@"inputRadius"];
	[self setFilters:[NSArray arrayWithObjects:blur, nil]];
}

- (void) drawGL
{

	FTRGBA *color;
	for(FTInteractiveObject *blob in [_blobs allValues])
	{
		color = blob.color;
        
		if(color.a == 1.f)
        {
			if((arc4random() % 100) > 50)
				color.a = 0.f;
			else
				color.a = 3.f;
        }
        //*
		FTRGBA *colors[6];
		colors[0] = [[FTRGBA alloc] initWithR:1.f
									  withG:0.f
									  withB:0.f
									  withA:0.65f];
		
		colors[1] = [[FTRGBA alloc] initWithR:0.f
									  withG:1.f
									  withB:0.f
									  withA:0.65f];
		
		colors[2] = [[FTRGBA alloc] initWithR:0.f
									  withG:0.f
									  withB:1.f
									  withA:0.65f];
		
		colors[3] = [[FTRGBA alloc] initWithR:1.f
									  withG:1.f
									  withB:0.f
									  withA:0.65f];
		
		colors[4] = [[FTRGBA alloc] initWithR:1.f
									  withG:0.f
									  withB:1.f
									  withA:0.65f];
		
		colors[5] = [[FTRGBA alloc] initWithR:0.f
									  withG:1.f
									  withB:1.f
									  withA:0.65f];
		
		int index = (int) [blob.contourHistory count] - CONTOURS_BACK * 3;
		int colorIndex = color.a;
		
		while((index > 0) && (index <= ([blob.contourHistory count] - CONTOURS_BACK)))
		{
			NSArray *contour = [blob.contourHistory objectAtIndex:index];
			int count = (int) [contour count];
			GLdouble vertices[count][3];
			
			glColor4f(colors[colorIndex].r,
					  colors[colorIndex].g,
					  colors[colorIndex].b,
					  1.f);//colors[colorIndex].a);
			
			gluTessBeginPolygon(_tess, NULL);
			gluTessBeginContour(_tess);
			
			for(int i = 0; i < count; i++)
			{
				ObjectPoint *point = [contour objectAtIndex:i];
				vertices[i][0] = point.x;
				vertices[i][1] = point.y;
				vertices[i][2] = 0.f;
				gluTessVertex(_tess, vertices[i], vertices[i]);
			}
			gluTessEndContour(_tess);
			gluTessEndPolygon(_tess);
			
			colorIndex++;
			index += CONTOURS_BACK;
		}
        //*/
	}
}

@end
