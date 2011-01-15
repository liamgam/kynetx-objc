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
@synthesize apps = apps_, 
			sessionID = sessionID_,
			issueNewSession = issueNewSession_,
			eventDomain = eventDomain_, 
			delegate = delegate_;

- (id) init	{
	// just pass nil to designated initializer
	return [self initWithApps:nil eventDomain:nil delegate:nil];
}

// this is the designated initializer
- (id) initWithApps:(id)appsDict eventDomain:(id)domain delegate:(id)del {
	if (self = [super init]) {
		NSURL* baseKNSURL = [NSURL URLWithString:@"https://cs.kobj.net/"];
		NSArray* KNSCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseKNSURL];
		if ([KNSCookies count]) {
			[self setSessionID:[[KNSCookies objectAtIndex:0] value]];
		} else {
			[self setSessionID:@"Not Set"];
		}
		[self setApps:appsDict];
		[self setEventDomain:domain];
		[self setDelegate:del];
		[self setIssueNewSession:NO];
	}
	return self;
}

- (void) signal:(NSString *)name params:(NSDictionary*)params {
	// raise events to KNS
	
	// build the request URL
	// start with a NSString base URL
	
	NSArray* appIDs = [self.apps allKeys];
	NSLog(@"All Keys: %@", appIDs);
	int keyCount = [[self.apps allKeys] count];
	NSMutableString* urlAppIDs = [NSMutableString string]; 
	for (int i = 0; i < keyCount; i++) {
		NSString* toAppend = [[appIDs objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (i < [appIDs count] - 1) {
			[urlAppIDs appendFormat:@"%@;", toAppend];
		} else {
			[urlAppIDs appendFormat:@"%@", toAppend];
		}
	}
			
	NSMutableString* baseURLstring = [NSMutableString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@/?", [self eventDomain], name, urlAppIDs];
	
	[self.apps enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		// append it
		key = [[NSString stringWithFormat:@"%@:kynetx_app_version", key]
			   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString* toAppend = [NSString stringWithFormat:@"%@=%@&", key, value];
		[baseURLstring appendString:toAppend];
	}];
		
	// then construct NSURL with the dict of params and baseURLstring
	NSURL* eventURL = [self URLFromDict:params withBaseURL:baseURLstring];
	// construct a request object with eventURL
	NSURLRequest* KNSRequest = [[[NSURLRequest alloc] initWithURL:eventURL] autorelease];
	// grab KNS cookies
	NSArray* KNSCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:eventURL];
	// set our session ID
	if ([KNSCookies count]) {
		self.sessionID = [[KNSCookies objectAtIndex:0] value];
	}
	// use request to make a connection
	// specifying that the current object should act as its delegate
	NSLog(@" ----- KNS Request Details ----- ");
	NSLog(@"URL: %@", [KNSRequest URL]);
	NSLog(@"HTTP Method: %@", [KNSRequest HTTPMethod]);
	NSLog(@"Session ID: %@", [self sessionID]);
	NSLog(@" ----- End KNS Request Details ----- ");
	// if we are asked to issue new session and there is 
	// currently a stored session
	if ([self issueNewSession] && [KNSCookies count]) {
		NSLog(@"Asked to destroy current Session ID cookie.");
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[KNSCookies objectAtIndex:0]];
		NSLog(@"Session ID cookie destroyed.");
	} else if ([self issueNewSession] && ![KNSCookies count]) { 
		// if we are asked to issue a new session
		// but there is no session cookie stored
		NSLog(@"Asked to destroy current Session ID cookie, but there is no Session ID cookie currently stored. Skipping.");
	}
	[[[NSURLConnection alloc] initWithRequest:KNSRequest delegate:self] autorelease];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// handle different sessionID's
	
	// cast base response to derived HTTP url response class
	// so we can access HTTP data about the response
	NSHTTPURLResponse* KNSHTTPResponse = (NSHTTPURLResponse*) response;
	// retrieve the cookies from the KNS response Set-Cookie header
	// KNS just sends one Set-Cookie header, but this method will handle any
	// number of returned Set-Cookie headers
	NSArray* KNSCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[KNSHTTPResponse allHeaderFields] 
																 forURL:[KNSHTTPResponse URL]];
	NSHTTPCookie* sessionIDCookie = [KNSCookies objectAtIndex:0];
	NSString* returnedSessionID = [sessionIDCookie value];
	NSString* oldSessionID = [self sessionID];
	
	if (![self issueNewSession] && !oldSessionID && returnedSessionID) {
		// if there was no sessionID cookie stored, just set it to the cookie
		// value returned from KNS
		NSLog(@"There was no Session ID cookie stored.");
		NSLog(@"Storing new Session ID cookie.");
		self.sessionID = returnedSessionID;
		NSLog(@"Session ID cookie stored.");
	} else if ([self issueNewSession]) {
		self.sessionID = returnedSessionID;
		NSLog(@"New Session ID cookie issued successfully.");
	} else if (![self issueNewSession] && oldSessionID && ![returnedSessionID isEqualToString:oldSessionID]) {
		// if we were not asked to issue new session and KNS responds with new session
		// TODO: send error to errorstack for this case
		NSLog(@"Error: KNS Returned a different Session ID cookie than was sent with original request.");
		NSLog(@"Session ID sent with request: %@", oldSessionID);
		NSLog(@"Session ID returned from KNS: %@", returnedSessionID);
		NSLog(@"Setting new SessionID.");
		self.sessionID = returnedSessionID;
	} else {
		NSLog(@"New Session ID cookie was not issued.");
	}
	NSLog(@"Session ID: %@", [self sessionID]);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// take returned data and parse it
	// Then call KynetxDelegate method, passing it the
	// dictionary of directives
	// This is where we exit the current Kynetx
	// object if everything goes well
	
	NSArray* KNSDirectives = [self parseDirectives:data];
	
	// call delegate 
	[[self delegate] didReceiveKNSDirectives:KNSDirectives];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError*)error {
	// something went wrong
	// call appropriate delegate method
	[[self delegate] KNSRequestDidFailWithError:error];
}

- (NSArray*) parseDirectives:(NSData*)response {
	// parse json string of directives returned from KNS
	
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

- (NSURL*) URLFromDict:(NSDictionary*)params withBaseURL:(NSString*)URLstring {
	// construct a NSURL from a dictionary of paramaters and a base URL string
	
	// setup mutable string
	NSMutableString* buildString = [[[NSMutableString alloc] init] autorelease];
	[buildString appendString:URLstring];
	
	// loop over the params dictionary
	// appending each key-value pair as we go
	// not using block method here because 
	// of the way we are appending parameters
	NSArray* keys = [params allKeys];
	int count = [keys count];
	for (int i = 0; i < count; i++) {
		id key = [[keys objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		id value = [[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (i != count - 1) {
			[buildString appendFormat:@"%@=%@&",key,value];
		} else {
			[buildString appendFormat:@"%@=%@",key,value];
		}
	}
	
	// at this point, URL is now constructed and ready to be returned
	
	return [[[NSURL alloc] initWithString:buildString] autorelease];
}

// destructor
- (void) dealloc {
	[self.apps release];
	[self.sessionID release];
	[self.eventDomain release];
	[self.delegate release];
	[super dealloc];
}

@end
