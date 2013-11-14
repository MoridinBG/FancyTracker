//
//  FTEffectContainerView.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTEffectContainerView.h"

@implementation FTEffectContainerView

#pragma mark Initialization

- (void) awakeFromNib
{

//    [self enterFullScreenMode:[[NSScreen screens] objectAtIndex:0] withOptions:NULL];
    
    [self.window makeKeyAndOrderFront:self];
    _tuioClient = [[TuioClient alloc] initWithPortNumber:3333
                                  andDelegateDimensions:self.frame.size
                                     relativeCoordinates:true];
    _tuioClient.isCalibrating = TRUE;
    
    _background = [FTBackgroundLayer layer];
    _background.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    _text = [CATextLayer layer];
    _currentEffect = nil;
    
    _renderTimer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(sendToSyphon:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSRunLoopCommonModes];
    
    [self loadEffects];
    [self createSyphonContext];
}

- (void) loadEffects
{
    NSArray *imagePaths = [NSArray arrayWithObjects:@"C1.png", @"C2.png", @"C3.png", nil];
    _logos1 = [FTInteractiveLogos layer];
    _logos1.mustGLClear = TRUE;
    _logos1.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [(FTInteractiveLogos*) _logos1 loadImagesFrom:imagePaths
                                    withNumOfEach:2
                                         withSize:CGSizeMake(0.2f * self.frame.size.width,
                                                             0.2f * self.frame.size.width)];
    
    _logos2 = [FTInteractiveLogos layer];
    _logos2.mustGLClear = TRUE;
    _logos2.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [(FTInteractiveLogos*) _logos2 loadImagesFrom:imagePaths
                                    withNumOfEach:4
                                         withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                             0.1f * self.frame.size.width)];

    _logos3 = [FTInteractiveLogos layer];
    _logos3.mustGLClear = TRUE;
    _logos3.mustCreateSensors = TRUE;
    _logos3.connectionDrawer = [FTLineConnectionDrawer class];
    _logos3.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_logos3 setupSensors];
    [(FTInteractiveLogos*) _logos3 loadImagesFrom:imagePaths
                                    withNumOfEach:2
                                         withSize:CGSizeMake(0.2f * self.frame.size.width,
                                                             0.2f * self.frame.size.width)];
    
    _logos4 = [FTInteractiveLogos layer];
    _logos4.mustGLClear = TRUE;
    _logos4.mustCreateSensors = TRUE;
    _logos4.connectionDrawer = [FTLineConnectionDrawer class];
    _logos4.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_logos4 setupSensors];
    [(FTInteractiveLogos*) _logos4 loadImagesFrom:imagePaths
                                    withNumOfEach:4
                                         withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                             0.1f * self.frame.size.width)];
    
    _logos5 = [FTInteractiveLogos layer];
    _logos5.mustGLClear = TRUE;
    _logos5.mustCreateSensors = TRUE;
    _logos5.mustDistanceJointNeihgbours = TRUE;
    _logos5.connectionDrawer = [FTLineConnectionDrawer class];
    _logos5.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_logos5 setupSensors];
    [(FTInteractiveLogos*) _logos5 loadImagesFrom:imagePaths
                                    withNumOfEach:4
                                         withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                             0.1f * self.frame.size.width)];
    
    _currentEffect = _logos5;
    [self.layer addSublayer:_currentEffect];
    [_tuioClient addObjectToDelegates:_currentEffect];
}

- (void) createSyphonContext
{
    CGLPixelFormatAttribute attribs[] =
	{
		kCGLPFAAccelerated,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
        NSOpenGLPFANoRecovery,
		0
	};
	
	CGLPixelFormatObj pixelFormatObj = NULL;
	GLint numPixelFormats = 0;
	
	CGLChoosePixelFormat(attribs, &pixelFormatObj, &numPixelFormats);
    
    CGLCreateContext(pixelFormatObj, NULL, &_syphonContext);
    CGLSetCurrentContext(_syphonContext);
    
    glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable (GL_LINE_SMOOTH);
    //glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	//X:  0 to WIDTH
	//Y:  0 to HEIGHT
	//Z:  0 to 1
	glOrtho(0, self.bounds.size.width, 0, self.bounds.size.height, -10, 10);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    float width = self.frame.size.width;
	float height = self.frame.size.height;
	
	glGenTextures(1, &_syphoneTextureId);
	glBindTexture(GL_TEXTURE_2D, _syphoneTextureId);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0,
				 GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
	glEnable(GL_TEXTURE_2D);
	
	// create a framebuffer object
	glGenFramebuffersEXT(1, &_syphonFboId);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _syphonFboId);
    
	// attach the texture to FBO color attachment point
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
							  GL_COLOR_ATTACHMENT0_EXT,
							  GL_TEXTURE_2D,
							  _syphoneTextureId,
							  0);
	
	glClearColor(BACKGROUND, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT)
	{
		NSLog(@"Bad Framebuffer status");
	}
    
    _syphonRenderer = [CARenderer rendererWithCGLContext:_syphonContext options:nil];
    _syphonRenderer.layer = self.layer;
    _syphonRenderer.bounds = NSRectToCGRect(self.frame);
}

- (void) dealloc
{
    [_syphon stop];
}
#pragma mark -

#pragma mark Implementation

- (void) setBounds:(NSRect)aRect
{
    [super setBounds:aRect];
    _currentEffect.frame = aRect;
}

-(void) sendToSyphon:(NSTimer*) aTimer
{
    if(_syphon == nil)
        _syphon = [[SyphonServer alloc] initWithName:@"MultiEffect" context:_syphonContext options:nil];
    
    if([_syphon hasClients])
    {
        [_syphonRenderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
        [_syphonRenderer addUpdateRect:_syphonRenderer.bounds];
        [_syphonRenderer render];
        [_syphonRenderer endFrame];
        
        [_syphon publishFrameTexture:_syphoneTextureId
                       textureTarget:GL_TEXTURE_2D
                         imageRegion:NSMakeRect(0, 0, _currentEffect.frame.size.width, _currentEffect.frame.size.height)
                   textureDimensions:_currentEffect.frame.size
                             flipped:NO];
    }
}
#pragma marka -

#pragma mark Keyboard Handler
- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void) printLimits
{
    _text.string = [NSString stringWithFormat:@"Current TUIO Min X: %f; Max X: %f; Min Y: %f; Max Y:%f", _tuioClient.contourMinX, _tuioClient.contourMaxX, _tuioClient.contourMinY, _tuioClient.contourMaxY];
    CGColorRef fgColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
	_text.foregroundColor = fgColor;
	CGColorRelease(fgColor);
    _text.fontSize = 20.f;
    [self.layer addSublayer:_text];
    
    _text.frame = CGRectMake(0, 0, 800, 600);
    
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];

    switch(key)
    {
        case '1' :
        {
            if(_currentEffect == _logos1)
                break;
            
            [_tuioClient removeObjectFromDelegates:_currentEffect];
            [_currentEffect removeFromSuperlayer];
            
            _logos1.mustRunPhysics = TRUE;
            _currentEffect = _logos1;
            [self.layer addSublayer:_currentEffect];
            [_tuioClient addObjectToDelegates:_currentEffect];
        } break;
            
            
        case '2' :
        {
            if(_currentEffect == _logos2)
                break;
            
            [_tuioClient removeObjectFromDelegates:_currentEffect];
            [_currentEffect removeFromSuperlayer];
            
            _logos2.mustRunPhysics = TRUE;
            _currentEffect = _logos2;
            [self.layer addSublayer:_currentEffect];
            [_tuioClient addObjectToDelegates:_currentEffect];
        } break;
            
        case '3' :
        {
            if(_currentEffect == _logos3)
                break;
            
            [_tuioClient removeObjectFromDelegates:_currentEffect];
            [_currentEffect removeFromSuperlayer];
            
            
            _logos3.mustRunPhysics = TRUE;
            _currentEffect = _logos3;
            [self.layer addSublayer:_currentEffect];
            [_tuioClient addObjectToDelegates:_currentEffect];
        } break;
            
        case '4' :
        {
            if(_currentEffect == _logos4)
                break;
            
            [_tuioClient removeObjectFromDelegates:_currentEffect];
            [_currentEffect removeFromSuperlayer];
            
            
            _logos4.mustRunPhysics = TRUE;
            _currentEffect = _logos4;
            [self.layer addSublayer:_currentEffect];
            [_tuioClient addObjectToDelegates:_currentEffect];
        } break;

        case '5' :
        {
            if(_currentEffect == _logos5)
                break;
            
            [_tuioClient removeObjectFromDelegates:_currentEffect];
            [_currentEffect removeFromSuperlayer];
            
            
            _logos5.mustRunPhysics = TRUE;
            _currentEffect = _logos4;
            [self.layer addSublayer:_currentEffect];
            [_tuioClient addObjectToDelegates:_currentEffect];
        } break;
            
            case 'p':
        {
            [self printLimits];
        } break;
            
        case 'w':
        {
            [_tuioClient calibrateContourMaxYAdd:0.025f];
        } break;
        case 's':
        {
            [_tuioClient calibrateContourMaxYAdd:-0.025f];
        } break;
        case 'a':
        {
            [_tuioClient calibrateContourMaxXAdd:-0.025f];
        } break;
        case 'd':
        {
            [_tuioClient calibrateContourMaxXAdd:0.025f];
        } break;
            
            
        case 'i':
        {
            [_tuioClient calibrateContourMinYAdd:0.025f];
        } break;
        case 'k':
        {
            [_tuioClient calibrateContourMinYAdd:-0.025f];
        } break;
        case 'j':
        {
            [_tuioClient calibrateContourMinXAdd:-0.025f];
        } break;
        case 'l':
        {
            [_tuioClient calibrateContourMinXAdd:0.025f];
        } break;
        case '-' :
        {
            [_currentEffect keyDown:event];
        } break;
        case '+' :
        {
            [_currentEffect keyDown:event];
        } break;
    }
}
#pragma mark -

@end
