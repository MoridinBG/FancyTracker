//
//  FTLineConnectionDrawer.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/14/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTInteractiveObject.h"
#import "FTConnection.h"

@interface FTLineConnectionDrawer : FTConnection

- (id) initWithendA:(FTInteractiveObject*) endA
			   endB:(FTInteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending
             within:(CGSize) dimensions;

-(void) render;

@end
