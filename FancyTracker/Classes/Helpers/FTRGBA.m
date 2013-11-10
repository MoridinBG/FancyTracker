//
//  FTRGBA.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTRGBA.h"

@implementation FTRGBA

- (id) initWithR:(float) r
		   withG:(float) g
		   withB:(float) b
		   withA:(float) a
{
	if(self = [super init])
	{
		_r = r;
		_g = g;
		_b = b;
		_a = a;
        
        _newR = b;
        _newG = r;
        _newB = b;
        _newA = a;
        
        _colorChangeSteps = 45;
        
        [self calcColorChangeInSteps:_colorChangeSteps];
	}
	
	return self;
}

+ (id) randomColorWithMinimumValue:(int)minColor
{
	return [[FTRGBA alloc] initWithR:(((float)(minColor + (arc4random() % 215)) / 255.f))
                             withG:(((float)(minColor + (arc4random() % 215)) / 255.f))
                             withB:(((float)(minColor + (arc4random() % 215)) / 255.f))
                             withA:1.f];
}

- (unsigned int) colorChangeSteps
{
    return _colorChangeSteps;
}

- (void) setColorChangeSteps:(unsigned int)colorChangeSteps
{
    _colorChangeSteps = colorChangeSteps;
    [self calcColorChangeInSteps:_colorChangeSteps];
}

- (void) randomizeColor
{
	if(_r != _newR)
	{
		if((_r > _newR) && (_stepR > 0))
		{
			_newR = (((float)(arc4random() % 255)) / 255.f);
			_stepR = (_newR - _r) / (_colorChangeSteps * 2.f);
		}
		if((_r < _newR) && (_stepR < 0))
		{
			_newR = (((float)(arc4random() % 255)) / 255.f);
			_stepR = (_newR - _r) / (_colorChangeSteps * 2.f);
		}
		_stepR *= _colorSpeed;
		_r += _stepR;
	}
	else
	{
		_newR = (((float)(arc4random() % 255)) / 255.f);
		_stepR = (_newR - _r) / (_colorChangeSteps * 2.f);
	}
	
	if(_g != _newG)
	{
		if((_g > _newG) && (_stepG > 0))
		{
			_newG = (((float)(arc4random() % 255)) / 255.f);
			_stepG = (_newG - _g) / (_colorChangeSteps * 2.f);
		}
		if((_g < _newG) && (_stepG < 0))
		{
			_newG = (((float)(arc4random() % 255)) / 255.f);
			_stepG = (_newG - _g) / (_colorChangeSteps * 2.f);
		}
		_stepG *= _colorSpeed;
		_g += _stepG;
	}
	else
	{
		_newG = (((float)(arc4random() % 255)) / 255.f);
		_stepG = (_newG - _g) / (_colorChangeSteps * 2.f);
	}
	
	if(_b != _newB)
	{
		if((_b > _newB) && (_stepB > 0))
		{
			_newB = (((float)(arc4random() % 255)) / 255.f);
			_stepB = (_newB - _b) / (_colorChangeSteps * 2.f);
		}
		if((_b < _newB) && (_stepB < 0))
		{
			_newB = (((float)(arc4random() % 255)) / 255.f);
			_stepB = (_newB - _b) / (_colorChangeSteps * 2.f);
		}
		_stepB *= _colorSpeed;
		_b += _stepB;
	}
	else
	{
		_newB = (((float)(arc4random() % 255)) / 255.f);
		_stepB = (_newB - _b) / (_colorChangeSteps * 2);
	}
}

- (void) stepColors
{
    BOOL endRed = FALSE;
    BOOL endGreen = FALSE;
    BOOL endBlue = FALSE;
    
    if(fabs(_newR - _r) > fabs(_stepR))
        //	if((_r + _stepR) != _newR)
		_r += _stepR;
    else
        endRed = TRUE;
    
	if(fabs(_newG - _g) > fabs(_stepG))
        //	if((_g + _stepG) != _newG)
		_g += _stepG;
    else
        endGreen = TRUE;
	
    if(fabs(_newB - _b) > fabs(_stepB))
        //	if((_b + _stepB) != _newB)
		_b += _stepB;
    else
        endBlue = TRUE;
    
    if(fabs(_newA - _a) > fabs(_stepA))
        //	if((_a + _stepA) != _newA)
		_a += _stepA;
    
    if(endRed && endGreen && endBlue)
        [self setRandomNewColor];
}

- (void) setRandomColor
{
	_r = (((float)(arc4random() % 255)) / 255.f);
	_g = (((float)(arc4random() % 255)) / 255.f);
	_b = (((float)(arc4random() % 255)) / 255.f);
	
	_newR = _r;
    _newG = _g;
    _newB = _b;
    
}

- (void) setRandomNewColor
{
	_newR = (((float)(arc4random() % 255)) / 255.f);
	_newG = (((float)(arc4random() % 255)) / 255.f);
	_newB = (((float)(arc4random() % 255)) / 255.f);
    [self calcColorChangeInSteps:_colorChangeSteps];
    
}

- (void) calcColorChangeInSteps:(float)steps
{
	_stepR = (_newR - _r) / steps;
	_stepG = (_newG - _g) / steps;
	_stepB = (_newB - _b) / steps;
	_stepA = (_newA - _a) / steps;
}

@end