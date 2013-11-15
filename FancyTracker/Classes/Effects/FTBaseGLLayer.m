//
//  FTBaseGLLayer.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/6/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTBaseGLLayer.h"

@implementation FTBaseGLLayer

#pragma mark Tesselation Callbacks
void tessEndCB()
{
    glEnd();
}

void tessBeginCB(GLenum which)
{
    glBegin(which);
}

void tessErrorCB(GLenum errorCode)
{
    const GLubyte *errorStr;
	
    errorStr = gluErrorString(errorCode);
	printf("Error: %s\n", errorStr);
}

void tessVertexCB(const GLvoid *data)
{
    const GLdouble *ptr = (const GLdouble*)data;
    glVertex3dv(ptr);
}

void tessCombineCB(GLdouble coords[3],
				   GLdouble *vertex_data[4],
				   GLfloat weight[4], GLdouble **dataOut )
{
	GLdouble *vertex;
	
	vertex = (GLdouble *) malloc(3 * sizeof(GLdouble));
	vertex[0] = coords[0];
	vertex[1] = coords[1];
	vertex[2] = coords[2];
    
	*dataOut = vertex;
}

#pragma mark -


#pragma mark Initialization
- (id) init
{
	if(self = [super init])
	{
		self.asynchronous = YES;
		_blobs = [[NSMutableDictionary alloc] init];
		
		_clearBitfield =	GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT;
        _mustGLClear = TRUE;
		
		_tess = gluNewTess();
		gluTessCallback(_tess, GLU_TESS_BEGIN, (void (CALLBACK *)())tessBeginCB);
		gluTessCallback(_tess, GLU_TESS_END, (void (CALLBACK *)())tessEndCB);
		gluTessCallback(_tess, GLU_TESS_ERROR, (void (CALLBACK *)())tessErrorCB);
		gluTessCallback(_tess, GLU_TESS_VERTEX, (void (CALLBACK *)())tessVertexCB);
		gluTessCallback(_tess, GLU_TESS_COMBINE, (void (CALLBACK *)())tessCombineCB);
        
        _text = [CATextLayer layer];
        isGLInit = FALSE;
	}
	return self;
}

- (void) setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	_aspect = bounds.size.width / bounds.size.height;
}

- (CGLContextObj) copyCGLContextForPixelFormat:(CGLPixelFormatObj) pixelFormat
{
	_glContext = NULL;
	CGLCreateContext(pixelFormat, NULL, &_glContext);
	if(_glContext == NULL)
		NSLog(@"Error: Could not create context!");
/*
	// Enable OpenGL multi-threading
	CGLError err = 0;
	err =  CGLEnable( contextObj, kCGLCEMPEngine);
	if (err != kCGLNoError )
	{
		NSLog(@"Error switching to Multi Threaded OpenGL!");
	}
//*/
    isGLInit = TRUE;
    
	CGLSetCurrentContext(_glContext);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable (GL_LINE_SMOOTH);
    //glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	//X:  0 to WIDTH
	//Y:  0 to HEIGHT
	//Z:  0 to 1
	glOrtho(0, self.bounds.size.width / self.bounds.size.height, 0, 1.0, -10, 10);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    float width = self.frame.size.width;
	float height = self.frame.size.height;
	
	glGenTextures(1, &_textureId);
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0,
				 GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
	glEnable(GL_TEXTURE_2D);
	
	// create a framebuffer object
	glGenFramebuffersEXT(1, &_fboId);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _fboId);

	// attach the texture to FBO color attachment point
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
							  GL_COLOR_ATTACHMENT0_EXT,
							  GL_TEXTURE_2D,
							  _textureId,
							  0);
	
	glClearColor(BACKGROUND, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);

    GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT)
	{
		NSLog(@"Bad Framebuffer status");
	}
    
	return _glContext;
}

- (CGLPixelFormatObj) copyCGLPixelFormatForDisplayMask:(uint32_t) mask
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
	return pixelFormatObj;
}

- (void) releaseCGLPixelFormat:(CGLPixelFormatObj) pixelFormat
{
	CGLDestroyPixelFormat(pixelFormat);
}
#pragma mark -

#pragma mark Drawing
- (void) drawInCGLContext:(CGLContextObj) glContext
             pixelFormat:(CGLPixelFormatObj) pixelFormat
            forLayerTime:(CFTimeInterval) interval
             displayTime:(const CVTimeStamp *) timeStamp
{
    CGLSetCurrentContext(glContext);
    
    GLint previousFBO, previousReadFBO, previousDrawFBO;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &previousFBO);
	glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING_EXT, &previousReadFBO);
	glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING_EXT, &previousDrawFBO);
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _fboId);
    
    if(_mustGLClear)
    {
        glClearColor(BACKGROUND, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    
    [self drawGL];
    glColor4f(1.f, 1.f, 1.f, 1.f);
    
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, previousFBO);
	glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, previousReadFBO);
	glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, previousDrawFBO);
    
    glClearColor(BACKGROUND, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
    
	glBindTexture(GL_TEXTURE_2D, _textureId);
	
	float aspect = self.frame.size.width / self.frame.size.height;
	
	glBegin(GL_QUADS);
	glTexCoord2f(0.f, 0.f);
	glVertex2f(0.f, 0.f);
	glTexCoord2f(1.0f, 0.f);
	glVertex2f(aspect, 0.f);
	glTexCoord2f(1.0f, 1.0f);
	glVertex2f(aspect, 1.f);
	glTexCoord2f(0.0f, 1.0f);
	glVertex2f(0.f, 1.f);
	glEnd();
	
	glBindTexture(GL_TEXTURE_2D, 0);
    
    [super drawInCGLContext:glContext pixelFormat:pixelFormat forLayerTime:interval displayTime:timeStamp];
}

- (void) drawGL
{
    NSLog(@"Implement your own drawing!");
}

- (void) printLimits
{
    _text.string = [NSString stringWithFormat:@"Contour MinX: %f; MaxX: %f; MinY: %f; MaxY:%f\nPoint MinX: %f; Max X: %f; Min Y: %f; Max Y:%f ", _minX, _maxX, _minY, _maxY,  _minX2, _maxX2, _minY2, _maxY2];
    CGColorRef fgColor = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
	_text.foregroundColor = fgColor;
	CGColorRelease(fgColor);
    _text.fontSize = 20.f;
    [self addSublayer:_text];
    
    _text.frame = CGRectMake(0, 0, 800, 600);

}



- (void) renderContourOfObject:(FTInteractiveObject*) object
{
    if(object.contour.count <= 0)
        return;
	glColor3f(object.color.r, object.color.g, object.color.b);
	gluTessBeginPolygon(_tess, NULL);
	gluTessBeginContour(_tess);
	
	unsigned long count = [object.contour count];
	GLdouble vertices[count][3];
	for(unsigned long i = 0; i < count; i++)
	{
		ObjectPoint *point = [object.contour objectAtIndex:i];
		vertices[i][0] = point.x;
		vertices[i][1] = point.y;
		vertices[i][2] = 0.f;
		gluTessVertex(_tess, vertices[i], vertices[i]);
	}
	
	gluTessEndContour(_tess);
	gluTessEndPolygon(_tess);
}

#pragma mark -

- (CGPoint) getRandomGLPointWithinDimension
{
	CGSize dimensions;
	dimensions.width = _aspect;
	dimensions.height = 1.f;
	
	int x = (dimensions.width * 1000) - 200;
	int y = (dimensions.height * 1000) - 200;
	
    CGPoint randomPoint = CGPointMake((arc4random() % x) / 1000.f, (arc4random() % y) / 1000.f);
	return randomPoint;
}

- (CGPoint) convertGLPointToCAPoint:(CGPoint) glPoint
{
    return CGPointMake((self.bounds.size.width / _aspect) * glPoint.x,
                       self.bounds.size.height * glPoint.y);
}

- (void)keyDown:(NSEvent *)event
{
    NSLog(@"Unprocessed key press in effect!");
}

#pragma mark TUIO
- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	FTInteractiveObject *object = [FTInteractiveObject interactiveFrom:newBounds];
	object.color = [FTRGBA randomColorWithMinimumValue:MIN_RANDOM_COLOR];
    [object.color setRandomColor];
    
	[_blobs setObject:object
				forKey:[newBounds getKey]];

}

- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds
{
    for(ObjectPoint *point in updatedBounds.contour)
    {
        if(_minX > point.x)
            _minX = point.x;
        if(_maxX < point.x)
            _maxX = point.x;
        if(_minY > point.y)
            _minY = point.y;
        if(_maxY < point.y)
            _maxY = point.y;
    }
    
    if(_minX2 > updatedBounds.position.x)
        _minX2 = updatedBounds.position.x;
    if(_maxX2 < updatedBounds.position.x)
        _maxX2 = updatedBounds.position.x;
    if(_minY2 > updatedBounds.position.y)
        _minY2 = updatedBounds.position.y;
    if(_maxY2 < updatedBounds.position.y)
        _maxY2 = updatedBounds.position.y;
    
    
    
	FTInteractiveObject *object = [_blobs objectForKey:[updatedBounds getKey]];
	if(object)
	{
		[object updateWithTuioBounds:updatedBounds];
	}
    
    if(0)//updatedBounds.contour.count == 0)
    {
        if(object.contourHistory.count >= HISTORY_DEPTH)
            [object.contourHistory removeObjectAtIndex:0];
        
        object.contour = [[NSMutableArray alloc] initWithCapacity:40];
        for(int i = 0; i < 36; i++)
        {
            float angle = i * DEG2RAD * 10;
            [object.contour addObject:[[ObjectPoint alloc] initWithX:cos(angle) * updatedBounds.dimensions.width * 0.5f + object.position.x
                                                                   Y:sin(angle) * updatedBounds.dimensions.height * 0.5f + object.position.y]];
        }
        
        [object.contourHistory addObject: object.contour];
    }
}

- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds
{
	[_blobs removeObjectForKey:[deadBounds getKey]];
}

- (void) tuioFrameFinished
{
}

- (void) tuioStopListening
{
    [_blobs removeAllObjects];
}
#pragma mark -

@end
