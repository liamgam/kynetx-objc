//
//  AppController.m
//  kynetx-desktop
//
//  Created by Alex  on 12/27/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "AppController.h"


@implementation AppController

-(IBAction) sendTestKynetx:(id) sender {
	NSLog(@"yay!");
}

-(IBAction) getAppIDVal:(id) sender {
	NSLog(@"%@",[appIDField stringValue]);
}

-(void) dealloc {
	[app release];
	[super dealloc];
}

@end
