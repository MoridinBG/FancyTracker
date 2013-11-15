//
//  FTLineConnectionDrawer.m
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/14/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTLineConnectionDrawer.h"

@implementation FTLineConnectionDrawer

- (id) initWithendA:(FTInteractiveObject*) endA
			   endB:(FTInteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending
{
    if(self = [super initWithendA:endA
                             endB:endB
                      beginningAt:beginnning
                         endingAt:ending])
    {
    }
    
    return self;
}

-(void) render
//TODO: Draw with begin && end factors. Shorten when one end disappears
{
	glLineWidth(3);
    
    glBegin(GL_LINES);
    glColor3f(1.f, 1.f, 1.f);
    glVertex2f(_endA.position.x,
               _endA.position.y);
    glVertex2f(_endB.position.x,
               _endB.position.y);
    glEnd();

}

@end
