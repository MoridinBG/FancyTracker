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
    
    _text = [CATextLayer layer];
    _currentEffect = nil;
    
    _renderTimer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(sendToSyphon:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSRunLoopCommonModes];
    
    [self loadEffects];
    [self createSyphonContext];
}

- (void) loadEffects
{
    NSArray *imagePaths = [NSArray arrayWithObjects:@"ASUSLogo_1.png", @"ASUSLogo_2.png", @"N550_1.png", @"N550_2.png", nil];
    _logos12 = [FTInteractiveLogos layer];
    _logos12.mustGLClear = TRUE;
    _logos12.connectionDrawer = [FTLightningConnectionDrawer class];
    _logos12.mustCollisionDetect = FALSE;
    _logos12.mustDrawConnections = FALSE;
    _logos12.mustRunPhysics = FALSE;
    _logos12.mustDistanceJointNeihgbours = FALSE;
    [_logos12 setupSensors];
    _logos12.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_logos12 loadImagesFrom:imagePaths
               withNumOfEach:1
                    withSize:CGSizeMake(0.2f * self.frame.size.width,
                                        0.2f * self.frame.size.width)];
    
    imagePaths = [NSArray arrayWithObjects:@"ASUSLogo_1.png", @"ASUSLogo_2.png", @"T100_1.png", @"T100_2.png",
                                            @"T100_3.png", @"T100_4.png", @"T100_5.png", @"T100_6.png", nil];
    _logos34 = [FTInteractiveLogos layer];
    _logos34.mustGLClear = TRUE;
    _logos34.connectionDrawer = [FTLineConnectionDrawer class];
    _logos34.mustCollisionDetect = FALSE;
    _logos34.mustDrawConnections = FALSE;
    _logos34.mustRunPhysics = FALSE;
    _logos34.mustDistanceJointNeihgbours = TRUE;
    _logos34.mustAttachToBlob = TRUE;
    [_logos34 setupSensors];
    _logos34.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [(FTInteractiveLogos*) _logos34 loadImagesFrom:imagePaths
                                     withNumOfEach:1
                                          withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                              0.1f * self.frame.size.width)];
    
//    imagePaths = [NSArray arrayWithObjects:@"Humira.png", @"H1.png", @"H2.png", @"H3.png", nil];
    _logos56 = [FTInteractiveLogos layer];
    _logos56.mustGLClear = TRUE;
    _logos56.connectionDrawer = [FTLineConnectionDrawer class];
    _logos56.mustCollisionDetect = FALSE;
    _logos56.mustDrawConnections = TRUE;
    _logos56.mustRunPhysics = FALSE;
    _logos56.mustDistanceJointNeihgbours = TRUE;
    _logos56.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_logos56 setupSensors];
    [(FTInteractiveLogos*) _logos56 loadImagesFrom:imagePaths
                                     withNumOfEach:1
                                          withSize:CGSizeMake(0.1f * self.frame.size.width,
                                                              0.1f * self.frame.size.width)];
    
    _colorTracks = [FTPictureReveal layer];
    _colorTracks.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    _sparkleEmitter = [FTSparkleEmitter layer];
    _sparkleEmitter.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    

    _currentEffect = _sparkleEmitter;
//    _logos13.mustRunPhysics = TRUE;
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
    
//    _syphonRenderer = [CARenderer rendererWithCGLContext:_syphonContext options:nil];
//    _syphonRenderer.layer = self.layer;
//    _syphonRenderer.bounds = NSRectToCGRect(self.frame);
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
//        [_syphonRenderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
//        [_syphonRenderer addUpdateRect:_syphonRenderer.bounds];
//        [_syphonRenderer render];
//        [_syphonRenderer endFrame];
        
        [_syphon publishFrameTexture:_syphoneTextureId
                       textureTarget:GL_TEXTURE_2D
                         imageRegion:NSMakeRect(0, 0, _currentEffect.frame.size.width, _currentEffect.frame.size.height)
                   textureDimensions:_currentEffect.frame.size
                             flipped:NO];
    }
}
#pragma marka -

- (void) printLimits
{
    NSString *msg = [NSString stringWithFormat:@"CContour MinX: %f; MaxX: %f; MinY: %f; Max Y:%f\nCPoint MinX: %f; MaxX: %f; MinY: %f; Max Y:%f",
                    _tuioClient.contourMinX, _tuioClient.contourMaxX, _tuioClient.contourMinY, _tuioClient.contourMaxY,
                    _tuioClient.pointMinX, _tuioClient.pointMaxX, _tuioClient.pointMinY, _tuioClient.pointMaxY];
    
    if(!_tuioClient.isCalibrating)
        msg = [NSString stringWithFormat:@"%@\nAdjusting calibration", msg];
    else
        msg = [NSString stringWithFormat:@"%@\nInternal calibration", msg];
    
    _text.string = msg;
    CGColorRef fgColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
	_text.foregroundColor = fgColor;
	CGColorRelease(fgColor);
    _text.fontSize = 17.f;
    [self.layer addSublayer:_text];
    
    _text.frame = CGRectMake(0, 0, 600, 500);
    
}

#pragma mark Keyboard Handler
- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    
    switch(key)
    {
        case '1' :
        {
            if(_currentEffect != _logos12)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos12;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos12.mustCollisionDetect = FALSE;
            _logos12.mustDrawConnections = FALSE;
            _logos12.mustRunPhysics = TRUE;
            _logos12.mustDistanceJointNeihgbours = FALSE;
        } break;
            
            
        case '2' :
        {
            if(_currentEffect != _logos12)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos12;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos12.mustCollisionDetect = TRUE;
            _logos12.mustDrawConnections = TRUE;
            _logos12.mustRunPhysics = TRUE;
            _logos12.mustDistanceJointNeihgbours = FALSE;
        } break;
            
        case '3' :
        {
            if(_currentEffect != _logos34)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos34;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos34.mustCollisionDetect = FALSE;
            _logos34.mustDrawConnections = FALSE;
            _logos34.mustRunPhysics = TRUE;
            _logos34.mustDistanceJointNeihgbours = TRUE;
        } break;
            
        case '4' :
        {
            if(_currentEffect != _logos34)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _logos34;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _logos34.mustCollisionDetect = TRUE;
            _logos34.mustDrawConnections = TRUE;
            _logos34.mustRunPhysics = TRUE;
            _logos34.mustDistanceJointNeihgbours = TRUE;
        } break;
//
//        case '5' :
//        {
//            if(_currentEffect != _logos56)
//            {
//                [_tuioClient removeObjectFromDelegates:_currentEffect];
//                [_currentEffect removeFromSuperlayer];
//                
//                _currentEffect = _logos56;
//                [self.layer addSublayer:_currentEffect];
//                [_tuioClient addObjectToDelegates:_currentEffect];
//            }
//            _logos56.mustCollisionDetect = FALSE;
//            _logos56.mustDrawConnections = FALSE;
//            _logos56.mustRunPhysics = TRUE;
//            _logos56.mustDistanceJointNeihgbours = TRUE;
//        } break;
//            
//        case '6' :
//        {
//            if(_currentEffect != _logos56)
//            {
//                [_tuioClient removeObjectFromDelegates:_currentEffect];
//                [_currentEffect removeFromSuperlayer];
//                
//                _currentEffect = _logos56;
//                [self.layer addSublayer:_currentEffect];
//                [_tuioClient addObjectToDelegates:_currentEffect];
//            }
//            _logos56.mustCollisionDetect = FALSE;
//            _logos56.mustDrawConnections = TRUE;
//            _logos56.mustRunPhysics = TRUE;
//            _logos56.mustDistanceJointNeihgbours = TRUE;
//        } break;

        case '8' :
        {
            if(_currentEffect != _sparkleEmitter)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _sparkleEmitter;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _sparkleEmitter.paths = [NSArray arrayWithObjects:@"cuad_1.png", @"cuad_2.png", @"cuad_3.png", nil];
        } break;
            
        case '9' :
        {
            if(_currentEffect != _sparkleEmitter)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _sparkleEmitter;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            _sparkleEmitter.paths = [NSArray arrayWithObjects:@"X_1.png", @"X_2.png", @"X_3.png", nil];
        } break;
            
        case '0' :
        {
            if(_currentEffect != _sparkleEmitter)
            {
                [_tuioClient removeObjectFromDelegates:_currentEffect];
                [_currentEffect removeFromSuperlayer];
                
                _currentEffect = _sparkleEmitter;
                [self.layer addSublayer:_currentEffect];
                [_tuioClient addObjectToDelegates:_currentEffect];
            }
            
            _sparkleEmitter.paths = [NSArray arrayWithObjects:@"circl_1.png", @"circl_2.png", @"circl_3.png", nil];
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
            
        case 'z' :
        {
            _tuioClient.isCalibrating = !_tuioClient.isCalibrating;
            [self printLimits];
        } break;
            
        case 'x' :
        {
            [_currentEffect keyDown:event];
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
