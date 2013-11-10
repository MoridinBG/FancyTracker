//
//  File.cpp
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "Box2D/Box2D.h"
#import "FTProximitySensorListener.h"

class FTContactDetectorCpp : public b2ContactListener
{
public:
	FTContactDetectorCpp(id objectiveBridge);
	void BeginContact(b2Contact *contact);
	void EndContact(b2Contact *contact);
	
	id<FTProximitySensorListener> _objectiveBridge;
};