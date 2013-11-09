//
//  FTStack.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/9/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTStack : NSObject
{
    NSMutableArray* _array;
    Class _acceptedClass;
}

- (id) init;
- (id) initWithSingleClass:(Class) class;

- (id) peek;
- (id) pop;
- (BOOL) push:(id) element;

- (void) pushElementsFromArray:(NSArray*) arr;
- (void) clear;

- (NSInteger) size;
- (BOOL) isEmpty;

@end
