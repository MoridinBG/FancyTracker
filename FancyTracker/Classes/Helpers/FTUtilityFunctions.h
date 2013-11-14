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
+ (CGPoint) findEndPointForStart:(CGPoint)start withLength:(float)length atAngle:(float)angle;
+ (float) lengthBetweenPoint:(CGPoint)start  andPoint:(CGPoint)end;
+ (float) findAngleBetweenPoint:(CGPoint) start andPoint:(CGPoint)end;

+ (char) isPoint:(CGPoint)point toTheLeftOfLineBetween:(CGPoint)point1 andPoint:(CGPoint)point2;

+ (CGPoint) findPointBetweenPoint:(CGPoint)pointA andPoint:(CGPoint)pointB;
#pragma mark -

#pragma mark Time
+ (double) secondsBetweenStartTime:(uint64_t)startTime andEndTime:(uint64_t)endTime;
#pragma mark -

#pragma mark Strings
+ (NSString *)buildUUID;
#pragma mark end

#pragma mark Graphics
+ (GLuint) getTextureFromImage:(CGImageRef)image;
+ (CGImageRef) getCGImageAtPath:(NSString*)filePath;
#pragma mark -
@end
