//
//  AppDelegate.m
//  kynetx-objc
//  Created by Alex on 12/23/10.
//  Copyright 2011 Kynetx. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
@implementation AppDelegate

@synthesize windowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self setWindowController:[[[MainWindowController alloc] initWithWindowNibName:@"MainWindow"] autorelease]];
	[[[self windowController] window] makeKeyAndOrderFront:self];
}

- (void) applicationWillTerminate:(NSNotification *)notification {
	[[[self windowController] window] close];
}

@end
