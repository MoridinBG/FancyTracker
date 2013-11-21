//
//  FTUtilityFunctions.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/13/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <mach/mach_time.h>

#import "consts.h"

@interface FTUtilityFunctions : NSObject
{
}

#pragma mark Geometry
+ (CGPoint) endPointForStart:(CGPoint)start withLength:(float)length atAngle:(float)angle;
+ (float) distanceBetweenPoint:(CGPoint)start  andPoint:(CGPoint)end;
+ (float) angleBetweenPoint:(CGPoint) start andPoint:(CGPoint)end;

+ (char) isPoint:(CGPoint)point toTheLeftOfLineBetween:(CGPoint)point1 andPoint:(CGPoint)point2;

+ (CGPoint) midPointBetweenPoint:(CGPoint)pointA andPoint:(CGPoint)pointB;
#pragma mark -

#pragma mark Sizes
+ (CGSize) fittingSizeForSize:(CGSize)givenSize toFitIn:(CGSize)boundingSize;
#pragma mark -

#pragma mark Time
+ (double) secondsBetweenStartTime:(uint64_t)startTime andEndTime:(uint64_t)endTime;
#pragma mark -

#pragma mark Strings
+ (NSString *)buildUUID;
#pragma mark end

#pragma mark Graphics
+ (GLuint) getTextureFromImage:(CGImageRef)image;
+ (CGImageRef) cgImageNamed:(NSString*)name;
#pragma mark -
@end
