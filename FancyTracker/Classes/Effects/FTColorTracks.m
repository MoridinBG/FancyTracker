//
//  FTColorTracks.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTColorTracks.h"

@implementation FTColorTracks

- (id) init
{
	if(self = [super init])
	{
//		[self addBlurFilter];
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
        int index = (int) blob.contourHistory.count - 1;
        int contoursBack = CONTOURS_BACK_COLOR_TRACKS;

        if((blob.contourHistory.count - 1) < contoursBack)
            contoursBack = (int) blob.contourHistory.count - 1;
        
        float alpha = 1.f;
        float alphaStep = 1.f / contoursBack;
        
		while((index >= 0) && (index > ([blob.contourHistory count] - contoursBack)))
		{
			NSArray *contour = [blob.contourHistory objectAtIndex:index];
			int count = (int) [contour count];
            int vertexIndex = 0;
			GLdouble vertices[count][3];
			
			glColor4f(color.r,
					  color.g,
					  color.b,
					  alpha);
            
			gluTessBeginPolygon(_tess, NULL);
			gluTessBeginContour(_tess);
			

            
            for(ObjectPoint *point in contour)
			{
				vertices[vertexIndex][0] = point.x;
				vertices[vertexIndex][1] = point.y;
				vertices[vertexIndex][2] = 0.f;
				gluTessVertex(_tess, vertices[vertexIndex], vertices[vertexIndex]);
                vertexIndex++;
			}
            
			gluTessEndContour(_tess);
			gluTessEndPolygon(_tess);
			
			index -= 5;
            alpha -= alphaStep * 5;
		}
        //*/
	}
}

@end
