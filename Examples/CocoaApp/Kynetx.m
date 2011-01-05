//
//  kynetx.m
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "Kynetx.h"


// secret 
@interface Kynetx ()
// overwrite property
@property (nonatomic, retain) NSString* eventDomain;

@end


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
		[self setAppid:input];
		[self setEventDomain:@"mobile"];
	}
	return self;
}

- (NSArray*) raiseEvent:(NSString *) name params:(NSDictionary*) params {
	NSString* urlString = [NSString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@", [self eventDomain], name, [self appid]];
	NSURL* url = [self URLFromDict:params withBaseURL:urlString];
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	NSURLResponse* response;
	NSLog(@"Request: %@", request);
	NSData* knsResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil]; // REST call.
	NSArray* knsCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:url];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:knsCookies forURL:url mainDocumentURL:nil];
	NSLog(@"COOKIES!!!!!!!!!!!!!!!!!");
	for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]) {
		NSLog(@"NAME: %@, EXPIRATION DATE: %@ VALUE: %@", [cookie name], [cookie expiresDate], [cookie value]);
	}
	return [self parseDirectives:knsResponse];
}

- (NSArray*) parseDirectives:(NSData*) response {
	SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
	NSString* responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
	NSRange knsCommentRange = NSMakeRange(0, 32);
	NSString* jsonString = [responseString stringByReplacingCharactersInRange:knsCommentRange withString:@""];
	NSArray* rawDirectives = [[parser objectWithString:jsonString] objectForKey:@"directives"];
	NSMutableArray* directives = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
	for (NSDictionary *rawDirective in rawDirectives) {
		NSDictionary* meta = [rawDirective objectForKey:@"meta"];
		NSDictionary* directive = [NSDictionary dictionaryWithObjectsAndKeys:
								   [meta objectForKey:@"rid"], @"rid",
								   [meta objectForKey:@"rule_name"], @"rule_name",
								   [meta objectForKey:@"txn_id"], @"txn_id",
								   [rawDirective objectForKey:@"name"], @"action",
								   [rawDirective objectForKey:@"options"], @"options",
								   nil];
		[directives addObject:directive];
	}
	return directives;
}

- (NSURL*) URLFromDict:(NSDictionary*) params withBaseURL:(NSString*) URLstring {
	NSMutableString* buildString = [[[NSMutableString alloc] init] autorelease];
	NSRange questionMarkRange = [URLstring rangeOfString:@"?"];
	if (questionMarkRange.location == NSNotFound || questionMarkRange.location != URLstring.length - 1) {
		// if the base url string does not have a question mark at the end, we need to add it
		[buildString appendFormat:@"%@%@", URLstring, @"?"];
	} else {
		// no question mark needed
		[buildString appendString:URLstring];
	}
	
	// loop over params dictionary, appending each key-value pair to url string
	NSArray* keys = [params allKeys];
	int count = [keys count];
	for (int i = 0; i < count; i++) {
		id key = [keys objectAtIndex:i];
		id value = [params objectForKey:key];
		if (i != count - 1) {
			[buildString appendFormat:@"%@=%@&",key,value];
		} else {
			[buildString appendFormat:@"%@=%@",key,value];
		}
	}
	
	return [[[NSURL alloc] initWithString:buildString] autorelease];
}

// destructor
- (void) dealloc {
	[appid release];
	[eventDomain release];
	[super dealloc];
}

@end
