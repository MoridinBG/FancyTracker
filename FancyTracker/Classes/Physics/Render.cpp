//
//  Render.cpp
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#include "Render.h"

#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include "freeglut/freeglut.h"
#endif

#include <cstdio>
#include <cstdarg>
#include <cstring>
using namespace std;

void DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glColor3f(color.r, color.g, color.b);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < vertexCount; ++i)
	{
		glVertex2f(vertices[i].x / PHYSICS_SCALE, vertices[i].y / PHYSICS_SCALE);
	}
	glEnd();
}

void DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(0.5f * color.r, 0.5f * color.g, 0.5f * color.b, 0.5f);
	glBegin(GL_TRIANGLE_FAN);
	for (int32 i = 0; i < vertexCount; ++i)
	{
		glVertex2f(vertices[i].x / PHYSICS_SCALE, vertices[i].y / PHYSICS_SCALE);
	}
	glEnd();
	glDisable(GL_BLEND);
    
	glColor4f(color.r, color.g, color.b, 1.0f);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < vertexCount; ++i)
	{
		glVertex2f(vertices[i].x / PHYSICS_SCALE, vertices[i].y / PHYSICS_SCALE);
	}
	glEnd();
}

void DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	glColor3f(color.r, color.g, color.b);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertex2f(v.x / PHYSICS_SCALE, v.y / PHYSICS_SCALE);
		theta += k_increment;
	}
	glEnd();
}

void DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(0.5f * color.r, 0.5f * color.g, 0.5f * color.b, 0.5f);
	glBegin(GL_TRIANGLE_FAN);
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertex2f(v.x / PHYSICS_SCALE, v.y / PHYSICS_SCALE);
		theta += k_increment;
	}
	glEnd();
	glDisable(GL_BLEND);
    
	theta = 0.0f;
	glColor4f(color.r, color.g, color.b, 1.0f);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertex2f(v.x / PHYSICS_SCALE, v.y / PHYSICS_SCALE);
		theta += k_increment;
	}
	glEnd();
    
	b2Vec2 p = center + radius * axis;
	glBegin(GL_LINES);
	glVertex2f(center.x / PHYSICS_SCALE, center.y / PHYSICS_SCALE);
	glVertex2f(p.x / PHYSICS_SCALE, p.y / PHYSICS_SCALE);
	glEnd();
}

void DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	glColor3f(color.r, color.g, color.b);
	glBegin(GL_LINES);
	glVertex2f(p1.x / PHYSICS_SCALE, p1.y / PHYSICS_SCALE);
	glVertex2f(p2.x / PHYSICS_SCALE, p2.y / PHYSICS_SCALE);
	glEnd();
}

void DebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.p, p2;
	const float32 k_axisScale = 0.4f;
	glBegin(GL_LINES);
	
	glColor3f(1.0f, 0.0f, 0.0f);
	glVertex2f(p1.x / PHYSICS_SCALE, p1.y / PHYSICS_SCALE);
	p2 = p1 + k_axisScale * xf.q.GetXAxis();
	glVertex2f(p2.x / PHYSICS_SCALE, p2.y / PHYSICS_SCALE);
    
	glColor3f(0.0f, 1.0f, 0.0f);
	glVertex2f(p1.x / PHYSICS_SCALE, p1.y / PHYSICS_SCALE);
	p2 = p1 + k_axisScale * xf.q.GetYAxis();
	glVertex2f(p2.x / PHYSICS_SCALE, p2.y / PHYSICS_SCALE);
    
	glEnd();
}

void DebugDraw::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
	glPointSize(size);
	glBegin(GL_POINTS);
	glColor3f(color.r, color.g, color.b);
	glVertex2f(p.x / PHYSICS_SCALE, p.y / PHYSICS_SCALE);
	glEnd();
	glPointSize(1.0f);
}

void DebugDraw::DrawString(int x, int y, const char *string, ...)
{
	char buffer[128];
    
	va_list arg;
	va_start(arg, string);
	vsprintf(buffer, string, arg);
	va_end(arg);
    
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	int w = glutGet(GLUT_WINDOW_WIDTH);
	int h = glutGet(GLUT_WINDOW_HEIGHT);
	gluOrtho2D(0, w, h, 0);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
    
	glColor3f(0.9f, 0.6f, 0.6f);
	glRasterPos2i(x / PHYSICS_SCALE, y / PHYSICS_SCALE);
	int32 length = (int32)strlen(buffer);
	for (int32 i = 0; i < length; ++i)
	{
		glutBitmapCharacter(GLUT_BITMAP_8_BY_13, buffer[i]);
	}
    
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
}

void DebugDraw::DrawAABB(b2AABB* aabb, const b2Color& c)
{
	glColor3f(c.r, c.g, c.b);
	glBegin(GL_LINE_LOOP);
	glVertex2f(aabb->lowerBound.x / PHYSICS_SCALE, aabb->lowerBound.y / PHYSICS_SCALE);
	glVertex2f(aabb->upperBound.x / PHYSICS_SCALE, aabb->lowerBound.y / PHYSICS_SCALE);
	glVertex2f(aabb->upperBound.x / PHYSICS_SCALE, aabb->upperBound.y / PHYSICS_SCALE);
	glVertex2f(aabb->lowerBound.x / PHYSICS_SCALE, aabb->upperBound.y / PHYSICS_SCALE);
	glEnd();
}
