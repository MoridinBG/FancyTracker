//
//  FTQueue.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTQueue.h"

@implementation FTQueue

- (id) init
{
    if ( (self = [super init]) )
    {
        _array = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id) initWithSingleClass:(Class) class
{
    if(self = [self init])
    {
        _acceptedClass = class;
    }
    
    return self;
}

- (id) peek
{
    if ([_array count] > 0)
        return [_array objectAtIndex:0];
    
    return nil;
}

- (id) dequeue
{
    if ([_array count] > 0)
    {
        id object = [self peek];
        [_array removeObjectAtIndex:0];
        return object;
    }
    
    return nil;
}

- (BOOL) enqueue:(id) element
{
    if(_acceptedClass && (![element isKindOfClass:_acceptedClass]))
        return FALSE;
    else
        [_array addObject:element];
    
    return TRUE;
}

- (void) enqueueElementsFromArray:(NSArray*) arr
{
    [_array addObjectsFromArray:arr];
}

- (void) enqueueElementsFromQueue:(FTQueue*) queue
{
    while (![queue isEmpty])
    {
        [self enqueue:[queue dequeue]];
    }
}

- (NSInteger) size
{
    return [_array count];
}

- (BOOL) isEmpty
{
    return [_array count] == 0;
}

- (void) clear
{
    [_array removeAllObjects];
}

@end
