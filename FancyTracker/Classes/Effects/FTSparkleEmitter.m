//
//  FTSparkleEmitter.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/19/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTSparkleEmitter.h"

@interface FTSparkleEmitter ()

- (void) createEmitterforObject:(FTInteractiveObject*)object withParticleImgs:(NSArray*)names;
- (void) updateEmitterForObject:(FTInteractiveObject*)object;

@end

@implementation FTSparkleEmitter

#pragma mark Initialization
- (id) init
{
    if(self = [super init])
    {
        _hostingLayer = [CALayer layer];
        _emitters = [[NSMutableDictionary alloc] init];
        _paths = [NSArray arrayWithObject:@"Spark2.png"];
    }
    
    return self;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _hostingLayer.bounds = bounds;
    [self.superlayer addSublayer:_hostingLayer];
}

#pragma mark -

- (void) drawGL
{
    for(FTInteractiveObject *blob in [_blobs allValues])
    {
        [self renderContourOfObject:blob];
    }
}

#pragma mark TUIO
- (void) tuioBoundsAdded:(TuioBounds *)newBounds
{
    [super tuioBoundsAdded:newBounds];
    [self createEmitterforObject:[_blobs objectForKey:newBounds.sessionID]
                withParticleImgs:_paths];
}

- (void) tuioBoundsUpdated:(TuioBounds *)updatedBounds
{
    [super tuioBoundsUpdated:updatedBounds];
    [self updateEmitterForObject:[_blobs objectForKey:updatedBounds.sessionID]];
}

- (void) tuioBoundsRemoved:(TuioBounds *)deadBounds
{
    [(CALayer*)[_emitters objectForKey:deadBounds.sessionID] removeFromSuperlayer];
    [_emitters removeObjectForKey:deadBounds.sessionID];
    
    [super tuioBoundsRemoved:deadBounds];
}
#pragma mark -

#pragma mark Emitter handling
- (void) updateEmitterForObject:(FTInteractiveObject*)object
{
    if(object == nil)
    {
        NSLog(@"Empty FTInteractiveObject in FTSparkleEmitter updateEmitterForObject:");
        return;
    }
    CAEmitterLayer *emitter = [_emitters objectForKey:object.uid];
    if(emitter == nil)
    {
        NSLog(@"Creating emitter for lonely object!");
        [self createEmitterforObject:object withParticleImgs:_paths];
        
        return;
    }
    
    CGPoint pointSize = CGPointMake(object.size.width, object.size.height);
    pointSize = [self convertGLPointToCAPoint:pointSize];
    
    emitter.emitterSize = CGSizeMake(pointSize.x, pointSize.y);
    emitter.emitterPosition = [self convertGLPointToCAPoint:object.position];
    return;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2f];
    
    float angle = object.velocityAngle;
    if(angle == 0.f)
    {
        [emitter setValue:[NSNumber numberWithFloat:M_PI]
               forKeyPath:@"emitterCells.spark1.emissionRange"];
    } else
    {
        [emitter setValue:[NSNumber numberWithFloat:M_PI / 3.f]
               forKeyPath:@"emitterCells.spark1.emissionRange"];
        [emitter setValue:[NSNumber numberWithFloat:(object.velocityAngle - 180) * DEG2RAD]
               forKeyPath:@"emitterCells.spark1.emissionLongitude"];
    }
    
    [CATransaction commit];
    
}

- (void) createEmitterforObject:(FTInteractiveObject*)object withParticleImgs:(NSArray*)names
{
    CAEmitterLayer *emitterLayer;
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:names.count];
    emitterLayer = [CAEmitterLayer layer];
    
    CGPoint pointSize = CGPointMake(object.size.width, object.size.height);
    pointSize = [self convertGLPointToCAPoint:pointSize];
    
    emitterLayer.emitterSize = CGSizeMake(pointSize.x, pointSize.y);
    emitterLayer.emitterPosition = [self convertGLPointToCAPoint:object.position];
    
    emitterLayer.emitterMode = kCAEmitterLayerOutline;
    emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    //    emitterLayer.backgroundColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
    
    for(NSString *name in names)
    {
        CAEmitterCell *cell = [CAEmitterCell emitterCell];
        cell = [CAEmitterCell emitterCell];
        cell.birthRate = 499.f;
        cell.velocity = 200.f;
        cell.lifetime = 0.6f;
        cell.scale = 0.6f;
//        cell.alphaSpeed = -0.2;
//        cell.yAcceleration = -80;
//        cell.beginTime = 4.5;
//        cell.duration = 0.9;
        
//        cell.emissionLongitude = object.velocityAngle * DEG2RAD;
        cell.emissionRange = M_PI / 2;
        
        cell.scaleSpeed = -0.1f;
        cell.spin = 2.f;
        
        CGColorRef color = CGColorCreateGenericRGB(0.5f, 0.5f, 0.5f, 0.8);
        cell.color = color;
        CGColorRelease(color);
        cell.redRange = 0.5f;
        cell.greenRange = 0.5f;
        cell.blueRange = 0.5f;
        
        cell.contents = (id) [FTUtilityFunctions cgImageNamed:name];
        [cell setName:@"spark1"];
        
        [cells addObject:cell];
    }
    
    emitterLayer.emitterCells = cells;
    
    [self addSublayer:emitterLayer];
    
    [_emitters setObject:emitterLayer forKey:object.uid];
}
#pragma mark -

@end
