//
//  FTConnection.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/13/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FTConnectionProtocol.h"
#import "FTInteractiveObject.h"
#import "FTUtilityFunctions.h"

@interface FTConnection : NSObject <FTConnectionProtocol>
{
	FTInteractiveObject *_endA;
	FTInteractiveObject *_endB;
    CGSize _dimensions;
    NSValue *_joint;
    
    float _begin;
    float _end; 
	
}
@property FTInteractiveObject *endA;
@property FTInteractiveObject *endB;
@property NSValue *joint;

@property(readonly) float length;
@property(readonly) float connectionAngle;

@property float begin;
@property float end;

@property bool isReadyToDie;

- (id) initWithendA:(FTInteractiveObject*) endA
               endB:(FTInteractiveObject*) endB
        beginningAt:(float) beginnning
           endingAt:(float)ending
             within:(CGSize) dimensions;

- (float) length;
- (float) connectionAngle;

@end
