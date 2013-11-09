//
//  FTStack.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTStack.h"

@implementation FTStack

- (id) init
{
    if(self = [super init])
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
    return [_array lastObject];
}

- (id) pop
{
    id object = [self peek];
    [_array removeLastObject];
    return object;
}

- (BOOL) push:(id) element
{
    if(_acceptedClass && (![element isKindOfClass:_acceptedClass]))
        return FALSE;
    else
        [_array addObject:element];
    
    return TRUE;
}

- (void) pushElementsFromArray:(NSArray*) arr
{
    [_array addObjectsFromArray:arr];
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
