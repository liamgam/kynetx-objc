//
//  kynetx.h
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSON/JSON.h"

/**
 @mainpage %Kynetx Objective-C Library
 This is a library for interacting with <a href = "http://www.kynetx.com" target="_blank">Kynetx</a>.
 @author Alex Olson
 */

/** 
 @brief An object that handles raising events to kynetx and parsing returned directives
 @author Alex Olson
 */
@interface Kynetx : NSObject {
	// silence is golden. Actually properties are golden. Hence this emptiness.
}

/** 
 @brief The event domain for the raised events.
 
 This is built-in and cannot be changed
 */
@property (nonatomic, retain) NSString* eventDomain;

/**
 @brief The appid to raise the specified events too
 
 This is the ruleset that will recieve the events raised.
 */
@property (nonatomic, retain) NSString* appid;

/** 
 @brief Basic init method.
 @return self 
 */
- (id) init;

<<<<<<< HEAD
/**
 @brief method to initialize with an App ID.
 
 This is the preferred initialization method. 
 @param input the appid to initialize the object with. 
 @param eventDomain the domain that all events will be raised under
 @return self
 */
- (id) initWithAppID:(id) input eventDomain: (id) domain;

/**
 @brief method to raise event to kynetx servers
 
 This method raises events to the kynetx servers.
 See the
 <a href = "http://docs.kynetx.com/docs/Kynetx_Network_Service_API" target="_blank">kynetx documentation</a>
 for more information regarding events.
 @param name name of the event to raise
 @param params a dictionary of key-value pairs to send to kynetx ruleset
 @param error an NSError reference to be populated on error
 @return void
 */
- (void) signal:(NSString*) name params:(NSDictionary*) params;
=======
- (id) initWithAppID:(id) input {
	if (self = [super init]) {
		[self setAppid:input];
		// need to see if there's a better way to do this. 
		// the purpose of this check is to see what event domain to set. 
		// if NSapp exists, then we are most likely in a Cocoa app
		if (NSApp) {
			[self setEventDomain:@"desktop"];
		} else {
			[self setEventDomain:@"mobile"];
		}
	}
	return self;
}

- (NSArray*) raiseEvent:(NSString *) name params:(NSDictionary*) params {
	NSString* urlString = [NSString stringWithFormat:@"https://cs.kobj.net/blue/event/%@/%@/%@", [self eventDomain], name, [self appid]];
	NSURL* url = [self URLFromDict:params withBaseURL:urlString];
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	NSLog(@"Request: %@", request);
	NSData* knsResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	return [self parseDirectives:knsResponse];
}
>>>>>>> parent of de44750... Cookie handling.

/**
 @brief parse directives returned by KNS for a raised event
 @param response NSData* object returned by a GET request
 @return NSArray* of NSDictionary* directives
*/
- (NSArray*) parseDirectives:(NSData*) response;

/**
 @brief build a NSURL* from a NSDictionary and a NSString
 @param params url paramaters to add to url string
 @param URLString URL string to add params to
 @return NSURL* 
 */
- (NSURL*) URLFromDict:(NSDictionary*) params withBaseURL:(NSString*) URLString;

/** 
 @brief releases object alloced memory
 @return void
 */
- (void) dealloc;

@end
