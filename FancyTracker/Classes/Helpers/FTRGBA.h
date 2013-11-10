//
//  FTRGBA.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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
    
    unsigned int _colorChangeSteps;
}
@property float r;
@property float g;
@property float b;
@property float a;

@property unsigned int colorChangeSteps;

- (id) initWithR:(float) r
		   withG:(float) g
		   withB:(float) b
		   withA:(float) a;

+ (id) randomColorWithMinimumValue:(int)minColor;

- (unsigned int) colorChangeSteps;
- (void) setColorChangeSteps:(unsigned int)colorChangeSteps;

- (void) randomizeColor;
- (void) stepColors;
- (void) setRandomColor;
- (void) calcColorChangeInSteps:(float)steps;


@end
