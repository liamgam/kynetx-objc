//
//  kynetx_desktopAppDelegate.m
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "AppDelegate.h"

// my delegate

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// have to do this because first menu item's title is ignored and defaults to appname. 
	// I want it human readable.
	[[[[NSApp mainMenu] itemAtIndex:0] submenu] setTitle:@""];
	[[[[NSApp mainMenu] itemAtIndex:0] submenu] setTitle:@"Kynetx Desktop"];
}

-(void) dealloc {
	[super dealloc];
}

@end