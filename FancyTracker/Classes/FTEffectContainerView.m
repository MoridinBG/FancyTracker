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
    _logos13 = [FTInteractiveLogos layer];
    _logos13.mustGLClear = TRUE;
    _logos13.connectionDrawer = [FTLineConnectionDrawer class];
    _logos13.mustCreateSensors = FALSE;
    _logos13.mustDrawConnections = FALSE;
    _logos13.mustRunPhysics = FALSE;
    _logos13.mustDistanceJointNeihgbours = FALSE;
    [_logos13 setupSensors];
    _logos13.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [(FTInteractiveLogos*) _logos13 loadImagesFrom:imagePaths
                                     withNumOfEach:2
                                          withSize:CGSizeMake(0.2f * self.frame.size.width,
                                                              0.2f * self.frame.size.width)
                                connectsAllToFirst:FALSE];
    
    _logos24 = [FTInteractiveLogos layer];
    _logos24.mustGLClear = TRUE;
    _logos24.connectionDrawer = [FTLineConnectionDrawer class];
    _logos24.mustCreateSensors = FALSE;
    _logos24.mustDrawConnections = FALSE;
    _logos24.mustRunPhysics = FALSE;
    _logos24.mustDistanceJointNeihgbours = FALSE;
    [_logos24 setupSensors];
    _logos24.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [(FTInteractiveLogos*) _logos24 loadImagesFrom:imagePaths
                                     withNumOfEach:4
                                          withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                              0.1f * self.frame.size.width)
                                connectsAllToFirst:FALSE];
    
    imagePaths = [NSArray arrayWithObjects:@"Humira.png", @"H1.png", @"H2.png", @"H3.png", nil];
    _logos56 = [FTInteractiveLogos layer];
    _logos56.mustGLClear = TRUE;
    _logos56.connectionDrawer = [FTLineConnectionDrawer class];
    _logos56.mustCreateSensors = FALSE;
    _logos56.mustDrawConnections = TRUE;
    _logos56.mustRunPhysics = FALSE;
    _logos56.mustDistanceJointNeihgbours = TRUE;
    _logos56.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_logos56 setupSensors];
    [(FTInteractiveLogos*) _logos56 loadImagesFrom:imagePaths
                                     withNumOfEach:2
                                          withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                              0.1f * self.frame.size.width)
                                connectsAllToFirst:TRUE];
    
    _currentEffect = _logos13;
    _logos13.mustRunPhysics = TRUE;
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
    _text.string = [NSString stringWithFormat:@"Cur Contour MinX: %f; MaxX: %f; MinY: %f; Max Y:%f\nCur Point MinX: %f; MaxX: %f; MinY: %f; Max Y:%f",
                    _tuioClient.contourMinX, _tuioClient.contourMaxX, _tuioClient.contourMinY, _tuioClient.contourMaxY,
                    _tuioClient.pointMinX, _tuioClient.pointMaxX, _tuioClient.pointMinY, _tuioClient.pointMaxY];
    CGColorRef fgColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
	_text.foregroundColor = fgColor;
	CGColorRelease(fgColor);
    _text.fontSize = 17.f;
    [self.layer addSublayer:_text];
    
    _text.frame = CGRectMake(0, 45, 800, 600);
    
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];

    switch(key)
    {
        case '1' :
        {
            if(_currentEffect != _logos13)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];

                _currentEffect = _logos13;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos13.mustCreateSensors = FALSE;
            _logos13.mustDrawConnections = FALSE;
            _logos13.mustRunPhysics = TRUE;
            _logos13.mustDistanceJointNeihgbours = FALSE;
        } break;
            
            
        case '2' :
        {
            if(_currentEffect != _logos24)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos24;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos24.mustCreateSensors = FALSE;
            _logos24.mustDrawConnections = FALSE;
            _logos24.mustRunPhysics = TRUE;
            _logos24.mustDistanceJointNeihgbours = FALSE;
        } break;
            
        case '3' :
        {
            if(_currentEffect != _logos13)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos13;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos13.mustCreateSensors = TRUE;
            _logos13.mustDrawConnections = TRUE;
            _logos13.mustRunPhysics = TRUE;
            _logos13.mustDistanceJointNeihgbours = FALSE;
        } break;
            
        case '4' :
        {
            if(_currentEffect != _logos24)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos24;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos24.mustCreateSensors = TRUE;
            _logos24.mustDrawConnections = TRUE;
            _logos24.mustRunPhysics = TRUE;
            _logos24.mustDistanceJointNeihgbours = FALSE;
        } break;

        case '5' :
        {
            if(_currentEffect != _logos56)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos56;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos56.mustCreateSensors = FALSE;
            _logos56.mustDrawConnections = FALSE;
            _logos56.mustRunPhysics = TRUE;
            _logos56.mustDistanceJointNeihgbours = TRUE;
        } break;
            
        case '6' :
        {
            if(_currentEffect != _logos56)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos56;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos56.mustCreateSensors = FALSE;
            _logos56.mustDrawConnections = TRUE;
            _logos56.mustRunPhysics = TRUE;
            _logos56.mustDistanceJointNeihgbours = TRUE;
        } break;
            
            
        case 'p':
        {
            [_currentEffect printLimits];
        } break;
            
        case ' ':
        {
            _calibratesContour = !_calibratesContour;
        } break;
            
        case 'i':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMaxYAdd:TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMaxYAdd:TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
        case 'k':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMaxYAdd:-TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMaxYAdd:-TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
        case 'j':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMaxXAdd:-TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMaxXAdd:-TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
        case 'l':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMaxXAdd:TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMaxXAdd:TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
            
            
        case 'w':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMinYAdd:TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMinYAdd:TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
        case 's':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMinYAdd:-TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMinYAdd:-TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
        case 'a':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMinXAdd:-TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMinXAdd:-TUIO_CALIBRATION_STEP];
            [self printLimits];
        } break;
        case 'd':
        {
            if(_calibratesContour)
                [_tuioClient calibrateContourMinXAdd:TUIO_CALIBRATION_STEP];
            else
                [_tuioClient calibratePointMinXAdd:TUIO_CALIBRATION_STEP];
            [self printLimits];
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
