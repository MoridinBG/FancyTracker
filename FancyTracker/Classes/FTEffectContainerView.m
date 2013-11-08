//
//  FTEffectContainerView.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTEffectContainerView.h"

@implementation FTEffectContainerView

#pragma mark Initialization

- (void) awakeFromNib
{
    NSLog(@"Alive");
    [self.window makeKeyAndOrderFront:self];
    _tuioClient = [[TuioClient alloc] initWithPortNumber:3333
                                  andDelegateDimensions:self.frame.size
                                     relativeCoordinates:true];
    _dumbLayer = [FTBoundariesBurnEffect layer];
    [_tuioClient addObjectToDelegates:_dumbLayer];
    
    _dumbLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	[self.layer addSublayer:_dumbLayer];
}
#pragma mark -

#pragma mark Implementation

- (void) drawRect:(NSRect) dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}
#pragma marka -


@end
