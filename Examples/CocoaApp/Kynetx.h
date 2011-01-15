//
//  kynetx.h
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import "JSON/JSON.h"

/**
 @brief A protocol defining methods that a kynetx
 delegate class can implement
*/
@protocol KynetxDelegate <NSObject>

@optional
/**
 @brief delegate method that gets called on a succesful kynetx request
 @param KNSDirectives out parameter containing returned Kynetx directives
 @return void
*/
- (void) didReceiveKNSDirectives:(NSArray*)KNSDirectives;

/**
 @brief delegate method that gets called on a failed kynetx request
 @param error out parameter containing error information
 @return void
*/
- (void) KNSRequestDidFailWithError:(NSError*)error; 

@end


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
	// backing instance vars for properties
	@private
	NSString* eventDomain_;
	NSDictionary* apps_;
	NSString* sessionID_;
	BOOL issueNewSession_;
	id <KynetxDelegate> delegate_;
}

/** 
 @brief The event domain for the raised events.
 
 This is built-in and cannot be changed
 */
@property (nonatomic, copy) NSString* eventDomain;

/**
 @brief The apps to raise the specified events to
 
 These are the rulesets that will recieve the events raised.
 */
@property (nonatomic, retain) NSDictionary* apps;

/**
 @brief The object to act as Kynetx delegate
*/
@property (nonatomic, retain) id <KynetxDelegate> delegate;

/**
 @brief KNS session ID
*/
@property (nonatomic, copy) NSString* sessionID;

/** 
 @breif Boolean value to determine if we should issue new KNS session
 
	Default is NO.
*/
@property (nonatomic) BOOL issueNewSession;

/** 
 @brief Basic init method.
 @return self 
 */
-(id) init;

/**
 @brief method to initialize with an App ID.
 
 This is the preferred initialization method. 
 @param appsDict dictionary of apps and versions
 @param eventDomain the domain for raised events
 @param delegate an object to act as Kynetx delegate
 @return self
 */
- (id) initWithApps:(id)appsDict eventDomain:(id)domain delegate:(id)del;

/**
 @brief method to raise event to kynetx servers
 
 This method raises events to the kynetx servers.
 See the
 <a href = "http://docs.kynetx.com/docs/Kynetx_Network_Service_API" target="_blank">kynetx documentation</a>
 for more information regarding events.
 @param name name of the event to raise
 @param params a dictionary of key-value pairs to send to kynetx ruleset
 @return void
 */
- (void) signal:(NSString*)name params:(NSDictionary*)params; 

/**
 @brief parse directives returned by KNS for a raised event
 @param response NSData* object returned by a GET request
 @return NSArray* of NSDictionary* directives
*/
- (NSArray*) parseDirectives:(NSData*)response;

/**
 @brief build a NSURL* from a NSDictionary and a NSString
 @param params url paramaters to add to url string
 @param URLString URL string to add params to
 @return NSURL* 
 */
- (NSURL*) URLFromDict:(NSDictionary*)params withBaseURL:(NSString*)URLString;

/** 
 @brief releases object alloced memory
 @return void
 */
- (void) dealloc;


@end
