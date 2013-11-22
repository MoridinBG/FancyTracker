//
//  FTLightningConnectionDrawer.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/21/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTConnection.h"
#import "FTUtilityFunctions.h"


#define LINE_SEGMENT_FACTOR 0.42f
#define LIGHTNING_SEGMENTS  60.f
#define LIGHTNING_SPIKE 0.0083f
#define LIGHTNING_SPIKE_MAX LIGHTNING_SPIKE * 3.f
#define LIGHTNING_SPIKE_MIN LIGHTNING_SPIKE / -3.f

#define SEGMENT_COUNT_MIN 1
#define SEGMENT_COUNT_MAX 3

@interface FTLightningConnectionDrawer : FTConnection
{
    float *_lightningSegmentPoints;     //Array of distances creating spiky line
    float *_segmentDelta;               //Change per step
    int   *_segmentCount;               //Steps to change
    
    int _lightCount;
}
- (id) initWithendA:(FTInteractiveObject*) endA
			   endB:(FTInteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending
             within:(CGSize) dimensions;

- (void) render;
- (void) render2;

@end
