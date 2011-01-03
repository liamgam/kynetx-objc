//
//  main.m
//  kynetx-objc
//
//  Created by Alex  on 12/23/10.
//  Copyright 2011 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	int retVal = NSApplicationMain(argc,  (const char **) argv);
	[pool drain];
	return retVal;
}
