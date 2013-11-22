//
//  FTLightningConnectionDrawer.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/21/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTLightningConnectionDrawer.h"

@implementation FTLightningConnectionDrawer


- (id) initWithendA:(FTInteractiveObject*) endA
			   endB:(FTInteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending
             within:(CGSize) dimensions
{
    if(self = [super initWithendA:endA
                             endB:endB
                      beginningAt:beginnning
                         endingAt:ending
                           within:dimensions])
    {
        _lightningSegmentPoints = NULL;
        _lightCount = 0.f;
    }
    
    return self;
}

- (void) render
{
    glLineWidth(2);
	
	CGPoint endPoint = (_endA.position.x >= _endB.position.x) ? _endA.position : _endB.position;
	CGPoint prevPoint = (_endA.position.x >= _endB.position.x) ? _endB.position : _endA.position;
    
    if(_lightningSegmentPoints == NULL)
    {
        _lightningSegmentPoints = (float*) malloc(LIGHTNING_SEGMENTS * sizeof(float));
        _segmentCount = (int*) malloc(LIGHTNING_SEGMENTS * sizeof(int));
        _segmentDelta = (float*) malloc(LIGHTNING_SEGMENTS * sizeof(float));
        
        for(int i = 0; i < LIGHTNING_SEGMENTS; i++)
        {
            int sign = ((arc4random() % 10) > 5) ? -1 : 1;
            float distance = (arc4random() % 25) / 3000.f * sign;
            float change = (arc4random() % 25) / 1500.f;
            
            _lightningSegmentPoints[i] = distance;
            _segmentCount[i] = SEGMENT_COUNT_MIN + arc4random() % SEGMENT_COUNT_MAX;
            _segmentDelta[i] = change / _segmentCount[i];
        }
    } else
    {
        float distance = [FTUtilityFunctions distanceBetweenPoint:endPoint andPoint:prevPoint];
        
        float angle = [FTUtilityFunctions angleBetweenPoint:prevPoint andPoint:endPoint];
        angle -= 180.f; //TODO: endPointForStart redacts the angle returned from angleBetweenPoint
        
        
        glLineWidth(3);
        glColor3f(1.f, 1.f, 1.f);
        glBegin(GL_LINES);
        
//        glVertex2f(prevPoint.x, prevPoint.y);
//        glVertex2f(endPoint.x, endPoint.y);

        int firstStep = LIGHTNING_SEGMENTS * _begin;
        int endStep = LIGHTNING_SEGMENTS * _end;
        distance /= LIGHTNING_SEGMENTS;
        
        endPoint = [FTUtilityFunctions endPointForStart:prevPoint withLength:endStep * distance atAngle:angle];
        prevPoint = [FTUtilityFunctions endPointForStart:prevPoint withLength:firstStep * distance atAngle:angle];
        CGPoint prevSidePoint = prevPoint;
        
        int steps = LIGHTNING_SEGMENTS - ((LIGHTNING_SEGMENTS * _begin) + (LIGHTNING_SEGMENTS * (1 - _end)));
        distance = [FTUtilityFunctions distanceBetweenPoint:prevPoint andPoint:endPoint];
        distance /= steps;
        
        for(int i = firstStep ; i < endStep; i ++)
        {
            _lightningSegmentPoints[i] += _segmentDelta[i];
            _segmentCount[i]--;
            
            if(_segmentCount[i] < 0)
            {
                int sign = ((arc4random() % 10) > 5) ? -1 : 1;
                float change = (arc4random() % 25) / 1500.f;
                change *= sign;
                
                _segmentCount[i] = SEGMENT_COUNT_MIN + arc4random() % SEGMENT_COUNT_MAX;
                _segmentDelta[i] = change / _segmentCount[i];
            }
            
            if(_lightningSegmentPoints[i] > LIGHTNING_SPIKE_MAX)
            {
                _lightningSegmentPoints[i] = LIGHTNING_SPIKE_MAX;
                _segmentDelta[i] *= -1;
            }
            
            if(_lightningSegmentPoints[i] < LIGHTNING_SPIKE_MAX * -1)
            {
                _segmentDelta[i] *= -1;
                _lightningSegmentPoints[i] = LIGHTNING_SPIKE_MAX * -1;
            }
            
            
            CGPoint nextPoint = [FTUtilityFunctions endPointForStart:prevPoint withLength:distance atAngle:angle];
            
            float sideAngle = angle + 90.f;
            if(_lightningSegmentPoints[i] < 0)
            {
                sideAngle = angle + 270.f;
            }
            
            CGPoint sidePoint = [FTUtilityFunctions endPointForStart:nextPoint withLength:fabs(_lightningSegmentPoints[i]) atAngle:sideAngle];
            
            glVertex2f(prevSidePoint.x, prevSidePoint.y);
            glVertex2f(sidePoint.x, sidePoint.y);
            
            prevSidePoint = sidePoint;
            prevPoint = nextPoint;
        }
        glEnd();
        
        _lightCount += 1;
        if(_lightCount >= 1000)
        {
            return;
            _lightCount = 0;
            free(_lightningSegmentPoints);
            _lightningSegmentPoints = NULL;
        }
    }
}

- (void) render2
{
	glLineWidth(2);
	
	CGPoint endPoint = (_endA.position.x >= _endB.position.x) ? _endA.position : _endB.position;
	CGPoint prevPoint = (_endA.position.x >= _endB.position.x) ? _endB.position : _endA.position;
	
	glBegin(GL_LINES);
	glColor3f(0.49f, 0.976f, 1.f);
    float temp = 0.f;
	do
	{
		//Point with random distance at random angle
		float distance = LINE_SEGMENT_FACTOR / 60.f * (1 + arc4random() % 3);
		int sign = ((arc4random() % 10) > 5) ? -1 : 1;
		int angle = (arc4random() % 180) * sign;
        
		CGPoint nextPoint = [FTUtilityFunctions endPointForStart:prevPoint
                                                      withLength:distance
                                                         atAngle:angle];
		glVertex2f(prevPoint.x, prevPoint.y);
		glVertex2f(nextPoint.x, nextPoint.y);
		
		prevPoint = nextPoint;
		
		//Point with random distance towards the end point
		distance = LINE_SEGMENT_FACTOR / 70.f * (1 + arc4random() % 3);
		angle = [FTUtilityFunctions angleBetweenPoint:endPoint
                                             andPoint:prevPoint];
		
		nextPoint = [FTUtilityFunctions endPointForStart:prevPoint
                                              withLength:distance
                                                 atAngle:angle];
		
		glVertex2f(prevPoint.x, prevPoint.y);
		glVertex2f(nextPoint.x, nextPoint.y);
		
		prevPoint = nextPoint;
        temp = [FTUtilityFunctions distanceBetweenPoint:prevPoint andPoint:endPoint];
        
	} while(temp > 0.05f);
	glEnd();
}

@end
