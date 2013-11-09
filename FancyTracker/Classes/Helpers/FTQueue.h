//
//  FTQueue.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTQueue : NSObject
{
    NSMutableArray *_array;
    Class _acceptedClass;
}

- (id) init;
- (id) initWithSingleClass:(Class) class;

- (id) peek;
- (id) dequeue;
- (BOOL) enqueue:(id) element;

- (void) enqueueElementsFromArray:(NSArray*) arr;
- (void) enqueueElementsFromQueue:(FTQueue*) queue;
- (void) clear;

- (BOOL) isEmpty;
- (NSInteger) size;

@end
