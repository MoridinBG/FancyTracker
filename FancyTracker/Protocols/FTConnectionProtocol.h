//
//  FTConnectionProtocol.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/13/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTInteractiveObject.h"

@protocol FTConnectionProtocol <NSObject>

- (id) initWithendA:(FTInteractiveObject*) endA
			   endB:(FTInteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float)ending
             within:(CGSize) dimensions;
@optional
-(void) render;

@end
