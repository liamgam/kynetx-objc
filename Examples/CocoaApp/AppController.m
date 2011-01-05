//
//  AppController.m
//  kynetx-desktop
//
//  Created by Alex  on 12/27/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "AppController.h"


@implementation AppController

@synthesize app;

-(IBAction) sendTestKynetx:(id) sender {
	[self setApp:[[[Kynetx alloc] initWithAppID:[appIDField stringValue] eventDomain:@"mobile"] autorelease]];
	NSDictionary* urlParams = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", @"whiz", @"cheese", nil];
	[app signal:@"jump_for_joy" params:urlParams];
}

-(IBAction) appIDVal:(id) sender {
	NSLog(@"%@",[appIDField stringValue]);
}

-(void) dealloc {
	[super dealloc];
}

@end
