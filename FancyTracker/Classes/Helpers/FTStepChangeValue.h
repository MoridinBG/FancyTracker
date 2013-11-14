//
//  FTStepChangeValue.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/14/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTStepChangeValue : NSObject
{
}

@property float value;
@property float changeStep;
@property int changeSign;
@property int framesTillChange;

- (id) initRandom;
- (void) randomize;

- (float) step;

@end
