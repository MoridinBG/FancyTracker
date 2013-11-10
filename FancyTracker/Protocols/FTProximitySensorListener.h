//
//  FTProximitySensorListener.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTInteractiveObject.h"

@protocol FTProximitySensorListener

- (void) contactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj;
- (void) removedContactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj;

@end
