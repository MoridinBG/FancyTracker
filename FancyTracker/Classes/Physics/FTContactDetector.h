//
//  FTContactDetector.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FTProximitySensorListener.h"
#import "FTInteractiveObject.h"

#ifdef __cplusplus
#import "FTContactDetectorCpp.h"
#endif

@interface FTContactDetector : NSObject <FTProximitySensorListener>
{
	id<FTProximitySensorListener> _effect;
	
#ifdef __cplusplus
	FTContactDetectorCpp *_box2DContactDetector;
#endif
}
@property id effect;
#ifdef __cplusplus
@property(readonly) FTContactDetectorCpp *box2DContactDetector;
#endif

- (id) init;

- (void) contactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj;
- (void) removedContactBetween:(FTInteractiveObject*)firstObj And:(FTInteractiveObject*)secondObj;
@end