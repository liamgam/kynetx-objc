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
@synthesize appID = appID_, 
			appVersion = appVersion_,
			sessionID = sessionID_,
			issueNewSession = issueNewSession_,
			eventDomain = eventDomain_, 
			delegate = delegate_;

- (id) init	{
	// just pass nil to designated initializer
	return [self initWithAppID:nil appVersion:nil eventDomain:nil delegate:nil];
}

// this is the designated initializer
- (id) initWithAppID:(id)input appVersion:(id)version eventDomain:(id)domain delegate:(id)del {
	if (self = [super init]) {
		NSURL* baseKNSURL = [NSURL URLWithString:@"https://cs.kobj.net/"];
		NSArray* KNSCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseKNSURL];
		if ([KNSCookies count]) {
			[self setSessionID:[[KNSCookies objectAtIndex:0] value]];
		} else {
			[self setSessionID:@"Not Set"];
		}
		[self setAppID:input];
		[self setAppVersion:version];
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
	
	NSMutableString* appIDs = [NSMutableString string];
	if ([self.appID isKindOfClass:[NSString class]]) {
		// if its a string
		[appIDs appendFormat:@"%@", [self appID]];
	} else if ([self.appID isKindOfClass:[NSArray class]]) {
		// if its an array
		int i = 0;
		for (NSString* app in [self appID]) {
			if (i < [[self	appID] count] - 1) {
				[appIDs appendFormat:@"%@,", app];
			} else {
				[appIDs appendFormat:@"%@", app];
			}
			i++;
		}
	}
	NSMutableString* baseURLstring = [NSMutableString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@/", [self eventDomain], name, appIDs];
	
	// check for dev version of ruleset
	if ([[self appVersion] isEqualToString: @"development"] || [[self appVersion] isEqualToString:@"dev"]) {
		[baseURLstring appendFormat:@"?%@:kynetx_app_version=%@&",[self appID], [self appVersion]];
	}
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
	
	// make a range to check for a question mark in URLString 
	NSRange questionMarkRange = [URLstring rangeOfString:@"?"];
	
	// make a range to check if we are specifiying a particular ruleset version
	NSRange devVersionRange = [URLstring rangeOfString:@"kynetx_app_version"];
	if ((questionMarkRange.location == NSNotFound || questionMarkRange.location != URLstring.length - 1) && devVersionRange.location == NSNotFound) {
		// if the base url string does not have a question mark at the end, and we are not specifying a ruleset version, we need to add it
		[buildString appendFormat:@"%@%@", URLstring, @"?"];
	} else {
		// no question mark needed
		[buildString appendString:URLstring];
	}
	
	// loop over the params dictionary
	// appending each key-value pair as we go
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
	[self.appID release];
	[self.appVersion release];
	[self.sessionID release];
	[self.eventDomain release];
	[self.delegate release];
	[super dealloc];
}

@end
