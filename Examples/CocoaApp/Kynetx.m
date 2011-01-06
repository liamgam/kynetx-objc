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
@synthesize appID;
@synthesize eventDomain;

- (id) init	{
	// just pass nil to designated initializer
	return [self initWithAppID:nil eventDomain:nil];
}

// this is the designated initializer
- (id) initWithAppID:(id) input eventDomain:(id) domain {
	if (self = [super init]) {
		[self setAppID:input];
		[self setEventDomain:domain];
	}
	return self;
}

- (void) signal:(NSString *) name params:(NSDictionary*) params {
	// build NSURL object
	// start with a NSString base url
	NSString* baseURLstring = [NSString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@/", [self eventDomain], name, [self appID]];
	// then construct NSURL with the dict of params and baseURLstring
	NSURL* eventURL = [self URLFromDict:params withBaseURL:baseURLstring];
	
	// construct a request object with eventURL
	NSURLRequest* KNSRequest = [[[NSURLRequest alloc] initWithURL:eventURL] autorelease];
	// then use that request to make a connection, delegate methods here 
	[[NSURLConnection alloc] initWithRequest:KNSRequest delegate:self];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// handle cookies
	// cast base response to derived http url response class
	// so we can access headers
	NSHTTPURLResponse* KNSHTTPResponse = (NSHTTPURLResponse*) response;
	// retrieve the cookies from the KNS response Set-Cookie header
	// KNS just sends one Set-Cookie header, but this method will handle any
	// number of returned Set-Cookie headers
	NSArray* KNSCookies = [[NSHTTPCookie cookiesWithResponseHeaderFields:[KNSHTTPResponse allHeaderFields] 
																  forURL:[KNSHTTPResponse URL]];
	// add the KNSCookies to the shared cookie storage of the device
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:KNSCookies 
						forURL:[KNSHTTPResponse URL] mainDocumentURL:nil];
				
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// handle JSON returned from KNS
}

- (NSArray*) parseDirectives:(NSData*) response {
	// create an instance of the json parser
	SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
	
	// get a string representation of the NSData response
	// make sure it is UTF-8 encoded
	NSString* responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
	
	// make a range that will be used to strip
	// the comment from the KNS response
	NSRange knsCommentRange = NSMakeRange(0, 32);
	// strip the comment off using the range
	NSString* jsonString = [responseString stringByReplacingCharactersInRange:knsCommentRange withString:@""];
	
	// pass json parser the jsonString, and grab the directives object on the now-parsed json
	NSArray* rawDirectives = [[parser objectWithString:jsonString] objectForKey:@"directives"];
	// setup array to hold reworked directives
	NSMutableArray* directives = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
	
	// rework each directive in the rawDirectives
	// array and add it to the directives array 
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
	// setup mutable string
	NSMutableString* buildString = [[[NSMutableString alloc] init] autorelease];
	
	// make a range to check for a question mark in URLString 
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
	
	// url is now complete
	
	return [[[NSURL alloc] initWithString:buildString] autorelease];
}

// destructor
- (void) dealloc {
	[appID release];
	[eventDomain release];
	[super dealloc];
}

@end
