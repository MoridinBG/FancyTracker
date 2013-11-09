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
	}
	return self;
}

- (CGLContextObj) copyCGLContextForPixelFormat:(CGLPixelFormatObj) pixelFormat
{
	CGLContextObj contextObj = NULL;
	CGLCreateContext(pixelFormat, NULL, &contextObj);
	if(contextObj == NULL)
		NSLog(@"Error: Could not create context!");
	_glContext = contextObj;
/*
	// Enable OpenGL multi-threading
	CGLError err = 0;
	err =  CGLEnable( contextObj, kCGLCEMPEngine);
	if (err != kCGLNoError )
	{
		NSLog(@"Error switching to Multi Threaded OpenGL!");
	}
//*/
    
	CGLSetCurrentContext(contextObj);
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
    
	return contextObj;
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
	FTInteractiveObject *object = [_blobs objectForKey:[updatedBounds getKey]];
	if(object)
	{
		[object updateWithTuioBounds:updatedBounds];
	}
    
    if(updatedBounds.contour.count == 0)
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
