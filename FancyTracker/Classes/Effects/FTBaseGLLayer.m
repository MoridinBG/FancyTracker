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
        NSLog(@"Base GL Layer");
		self.asynchronous = YES;
		_blobs = [[NSMutableDictionary alloc] init];
		
		_clearBitfield =	GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT;
		
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
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	//X:  0 to WIDTH
	//Y:  0 to HEIGHT
	//Z:  0 to 1
	glOrtho(0, self.bounds.size.width / self.bounds.size.height, 0, 1.0, -10, 10);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
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
	glClearColor(0.f, 0.f, 0.f, 0.0f);
	glClear(_clearBitfield);
	[self drawGL];
}

- (void) drawGL
{
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
}

- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds
{
	[_blobs removeObjectForKey:[deadBounds getKey]];
}

- (void) tuioFrameFinished
{
}
#pragma mark -

@end
