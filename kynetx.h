//
//  kynetx.h
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSON/JSON.h"

// class for raising events and parsing returned directives

@interface Kynetx : NSObject {
	// silence is golden. Actually properties are golden. Hence this emptiness.
}

// properties
@property (retain) NSString* eventDomain;
@property (retain) NSString* appid;

// constructors
-(id) init;
-(id) initWithAppID:(id) input;

// raise event to cs servers
-(NSArray*) raiseEvent:(NSString*) name params:(NSDictionary*) params; 

// parse directives returned from app
-(NSArray*) parseDirectives:(NSData*) response;

// build a url from an NSDictionary
-(NSURL*) URLFromDict:(NSDictionary*) params withBaseURL:(NSString*) URLString;

// destructor
-(void) dealloc;


@end
