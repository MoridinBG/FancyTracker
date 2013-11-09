//
//  FTPainterEffect.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/8/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTPainterEffect.h"

@implementation FTPainterEffect

- (void) drawGL
{
    for(FTInteractiveObject *blob in [_blobs allValues])
	{
        FTRGBA *color = blob.color;
        [color stepColors];
        
        glPushMatrix();
        glColor3f(color.r, color.g, color.b);
        
        gluTessBeginPolygon(_tess, NULL);
		gluTessBeginContour(_tess);
        
		NSArray *contour = blob.contour;
		unsigned long count = [contour count];
		GLdouble vertices[count][3];
		for(unsigned long i = 0; i < count; i++)
		{
			ObjectPoint *point = [contour objectAtIndex:i];
			vertices[i][0] = point.x;
			vertices[i][1] = point.y;
			vertices[i][2] = 0.f;
			gluTessVertex(_tess, vertices[i], vertices[i]);
		}
        
		gluTessEndContour(_tess);
		gluTessEndPolygon(_tess);
        glPopMatrix();
	}
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	[super tuioBoundsAdded:newBounds];
	FTInteractiveObject * object = [_blobs objectForKey:[newBounds getKey]];
	object.color = [FTRGBA randomColorWithMinimumValue:10];
}

@end
