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

@end

@implementation FTSparkleEmitter

- (id) init
{
    if(self = [super init])
    {
        _hostingLayer = [CALayer layer];
        _emitters = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _hostingLayer.bounds = bounds;
    [self.superlayer addSublayer:_hostingLayer];
}

- (void) drawGL
{
    return;
}

- (void) tuioBoundsAdded:(TuioBounds *)newBounds
{
    [super tuioBoundsAdded:newBounds];
    NSArray *paths = [NSArray arrayWithObject:@"Spark1.png"];
    [self createEmitterforObject:[_blobs objectForKey:newBounds.sessionID]
                withParticleImgs:paths];
}

- (void) tuioBoundsUpdated:(TuioBounds *)updatedBounds
{
    [super tuioBoundsUpdated:updatedBounds];
    CAEmitterLayer *layer = [_emitters objectForKey:updatedBounds.sessionID];
    if(layer != nil)
    {
        layer.emitterPosition = [self convertGLPointToCAPoint:updatedBounds.position];
    }
}

- (void) tuioBoundsRemoved:(TuioBounds *)deadBounds
{
    [(CALayer*)[_emitters objectForKey:deadBounds.sessionID] removeFromSuperlayer];
    [_emitters removeObjectForKey:deadBounds.sessionID];
    
    [super tuioBoundsRemoved:deadBounds];
}

- (void) createEmitterforObject:(FTInteractiveObject*)object withParticleImgs:(NSArray*)names
{
    CAEmitterLayer *emitterLayer;
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:names.count];
    emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterSize = CGSizeMake(10.f, 10.f);
    emitterLayer.emitterPosition = [self convertGLPointToCAPoint:object.position];
    
    emitterLayer.emitterMode = kCAEmitterLayerOutline;
    emitterLayer.emitterShape = kCAEmitterLayerLine;
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    //    emitterLayer.backgroundColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
    
    for(NSString *name in names)
    {
        CAEmitterCell *cell = [CAEmitterCell emitterCell];
        cell = [CAEmitterCell emitterCell];
        cell.birthRate = 11;
        cell.emissionLongitude = M_PI / 2;
        cell.lifetime = 10;
        cell.velocity = 4;
        cell.velocityRange = 2;
        cell.emissionRange = M_PI / 4;
        cell.spin = 1;
        cell.spinRange = 6;
        cell.yAcceleration = 160;
        cell.scale = 0.1;
        cell.alphaSpeed = -0.12;
        cell.scaleSpeed = 0.7;
        
        cell.contents = (id) [FTUtilityFunctions cgImageNamed:name];
        [cell setName:@"spark1"];
        
        [cells addObject:cell];
    }
    
    emitterLayer.emitterCells = cells;
    
    [self addSublayer:emitterLayer];
    
    [_emitters setObject:emitterLayer forKey:object.uid];
}

@end
