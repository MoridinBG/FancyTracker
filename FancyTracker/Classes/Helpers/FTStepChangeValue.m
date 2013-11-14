//
//  FTStepChangeValue.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/14/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTStepChangeValue.h"

@implementation FTStepChangeValue

- (id) initRandom
{
	if(self = [super init])
    {
        [self randomize];
	}
	return self;
}

- (void) randomize
{
    _value = ((arc4random() % 100) >= 50) ? 1.f : 0.f;
    _changeSign = (_value == 1.f) ? -1 : 1;
    _framesTillChange = 10 +  (arc4random() % 50);
    _changeStep = 1.f / _framesTillChange;
}

- (float) step
{
    if(_framesTillChange > 0)
        _value += _changeStep * _changeSign;
    
    return _value;
}

@end
