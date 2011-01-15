//
//  AppController.m
//  kynetx-desktop
//
//  Created by Alex  on 12/27/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "MainWindowController.h"


@implementation MainWindowController

@synthesize app = app_;

- (IBAction) sendTestKynetx:(id) sender {
	NSDictionary* apps = [NSDictionary dictionaryWithObjectsAndKeys:@"dev", @"a369x126", nil];
	
	[self setApp:[[[Kynetx alloc] initWithApps:apps eventDomain:@"mobile" delegate:self] autorelease]];
	NSDictionary* urlParams = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", @"whiz", @"cheese", nil];
	[self.app signal:@"jump_for_joy" params:urlParams];
}

- (IBAction) appIDVal:(id) sender {
	NSLog(@"%@",[appIDField stringValue]);
}

// kynetx delegate method
- (void) didReceiveKNSDirectives:(NSArray*)KNSDirectives {
	// do stuff with directives
	// for now we'll just log them
	NSLog(@"Directives: %@", KNSDirectives);
}

// another kynetx delegate method
// this one gets called whe the KNS request fails 
- (void) KNSRequestDidFailWithError:(NSError*)error {
	// do stuff
	// in this case, we'll just log the error's localized description
	// of course you can access any valid NSError properties like localizedRecoveryOptions, domain etc.
	NSLog(@"SOMETHING HORRIBLY SAD AND BAD AND NOT LEGIT JUST HAPPEND!!!! GAH!!! %@", [error localizedDescription]);
}
- (void) dealloc {
	[super dealloc];
}

@end
