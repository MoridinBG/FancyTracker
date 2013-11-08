//
//  FTRGBA.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define FRAMES 40.f

@interface FTRGBA : NSObject
{
    float _newR;
	float _newG;
	float _newB;
	float _newA;
    
    float _stepR;
	float _stepG;
	float _stepB;
	float _stepA;
    
    float _colorSpeed;
}
@property float r;
@property float g;
@property float b;
@property float a;

- (id) initWithR:(float) r
		   withG:(float) g
		   withB:(float) b
		   withA:(float) a;

+ (id) randomColorWithMinimumValue:(int)minColor;

- (void) randomizeColor;
- (void) stepColors;
- (void) setRandomColor;
- (void) calcColorChangeInSteps:(float)steps;


@end
