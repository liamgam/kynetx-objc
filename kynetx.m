//
//  kynetx.m
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "kynetx.h"
#import "JSON.h"


@implementation kynetx

- (id) init	{
	if (self = [super init]) {
		// call other constructers here
	}
	
	return self;
}

- (id) initWithAppid:


// getters
- (NSString*) app_id {
	return [self app_id];
}

- (NSString*) event_domain {
	return [self event_domain];
}

// setters

- (void) setAppId:(NSString *)input {
	[self app_id] = input;
}

- (void) setEventDomain:(NSString *)input {
	[self event_domain] = input;
}

@end
