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
	return [[[self alloc] initWithAppID:nil] autorelease]; // return allocated, autoreleased instance
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

- (NSArray*) raiseEvent:(NSString *) name params:(NSDictionary*) params {
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@", [self eventDomain], name, [self appid]]]];
	NSLog(@"Request URL: %@", request);
	NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	[self URLFromDict:[[[NSDictionary alloc] initWithObjectsAndKeys:@"yay",@"bay", nil] autorelease] withBaseURL:@"fdskljfdsjkdfsjklsdfkjldfsjklfdsjkl"];
	return [self parseDirectives:response];
}

- (NSArray*) parseDirectives:(NSData*) response {
	SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
	NSString* responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"KNS Response: %@", responseString);
	NSRange knsCommentRange = NSMakeRange(0, 32);
	NSString* jsonString = [responseString stringByReplacingCharactersInRange:knsCommentRange withString:@""];
	NSLog(@"jsonString: %@", jsonString);
	return [parser objectWithString:jsonString];
}

- (NSURL*) URLFromDict:(NSDictionary*) params withBaseURL:(NSString*) URLstring {
	NSArray* keys = [params allKeys];
	NSString* startChar;
	NSMutableString* buildString = [[[NSMutableString alloc] init] autorelease];
	int count = [keys count];
	NSPredicate* hasQuestionMark = [[[NSPredicate alloc] initWithFormat:@"SELF matches %@", @"\?$"] autorelease];
	if ([hasQuestionMark evaluateWithObject: URLstring]) {
		// base string already has query question mark at the end
	} else {
		// needs question mark
	}
	
	for (int i = 0; i < count; i++) {
		id key = [keys objectAtIndex:i];
		id value = [params objectForKey:key];
	}
}

// destructor
- (void) dealloc {
	[appid release];
	[eventDomain release];
	[super dealloc];
}

@end
