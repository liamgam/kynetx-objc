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
	[self setApp:[[Kynetx alloc] initWithAppID:[appIDField stringValue]]];
	NSArray* ok = [app raiseEvent:@"jump_for_joy" params:[NSDictionary dictionaryWithObjectsAndKeys:@"yay", @"nay", @"ok", @"false", nil]];
}

-(IBAction) appIDVal:(id) sender {
	NSLog(@"%@",[appIDField stringValue]);
}

-(void) dealloc {
	[app release];
	[super dealloc];
}

@end
