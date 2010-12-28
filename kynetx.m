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
	// just pass nil to preferred constructor
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

- (BOOL) raiseEvent:(NSString *) name {
	// TODO: seperate this method into two functions. One to raise event and one to parse directives.
	SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease]; // just send to autorelease pool;
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@", [self eventDomain], name, [self appid]]]];
	NSLog(@"Request URL: %@", request);
	NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString* responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease]; // send to autorelease pool
	NSLog(@"KNS Response: %@", responseString);
	NSRange knsCommentRange = NSMakeRange(0, 32);
	NSString* jsonString = [responseString stringByReplacingCharactersInRange:knsCommentRange withString:@""];
	NSLog(@"jsonString: %@", jsonString);
	NSArray* directives = [[parser objectWithString:jsonString] objectForKey:@"directives"];
	NSLog(@"Directives: %@", directives);
	for (NSDictionary* directive in directives) {
		NSLog(@"%@", [directive objectForKey:@"name"]);
	}
	
	return YES;
}

// destructor
- (void) dealloc {
	[appid release];
	[eventDomain release];
	[super dealloc];
}

@end
