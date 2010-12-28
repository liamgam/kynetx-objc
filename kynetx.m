//
//  kynetx.m
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "Kynetx.h"


@implementation Kynetx

// property synthesis
@synthesize appid;
@synthesize eventDomain;

- (id) init	{
	// if init is called directly, just pass nil to preferred constructor
	return [self initWithAppID:nil];
}

- (id) initWithAppID:(id) input {
	if (self = [super init]) {
		if (input == nil) {
			input = @"a369x123";
		}
		[self setAppid:input];
		[self setEventDomain:@"desktop"];
	}
	return self;
}

// destructor
- (void) dealloc {
	[appid release];
	[eventDomain release];
	[super dealloc];
}

@end
