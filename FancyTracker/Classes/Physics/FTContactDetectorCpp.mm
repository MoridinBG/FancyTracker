//
//  File.h
//  FancyTracker
//
//  Created by Ivan Dilchovski on 11/10/13.
//  Copyright (c) 2013 Ivan Dilchovski. All rights reserved.
//

#import "FTContactDetectorCpp.h"

FTContactDetectorCpp::FTContactDetectorCpp(id objectiveBridge)
{
	_objectiveBridge = objectiveBridge;
}

void FTContactDetectorCpp::BeginContact(b2Contact *contact)
{
	if ((contact->GetFixtureA()->IsSensor()) && (contact->GetFixtureB()->IsSensor()))
	{
		FTInteractiveObject *firstObject = (__bridge FTInteractiveObject*) contact->GetFixtureA()->GetUserData();
		FTInteractiveObject *secondObject = (__bridge FTInteractiveObject*) contact->GetFixtureB()->GetUserData();
		
		[_objectiveBridge contactBetween:firstObject And:secondObject];
	}
}

void FTContactDetectorCpp::EndContact(b2Contact *contact)
{
	if ((contact->GetFixtureA()->IsSensor()) && (contact->GetFixtureB()->IsSensor()))
	{
		FTInteractiveObject *firstObject = (__bridge FTInteractiveObject*) contact->GetFixtureA()->GetUserData();
		FTInteractiveObject *secondObject = (__bridge FTInteractiveObject*) contact->GetFixtureB()->GetUserData();
		
		[_objectiveBridge removedContactBetween:firstObject And:secondObject];
	}
}