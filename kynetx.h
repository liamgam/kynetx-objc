//
//  kynetx.h
//  kynetx-desktop
//
//  Created by Alex  on 12/23/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// class for raising events and parsing returned directives

@interface kynetx : NSObject {
	
	SBJsonParser *parser; // json parser 
	NSString *app_id; // will default to an a369 app
	NSString *event_domain; // for event domainb
}

-(id) init;
-(id) initWithAppId:(id) input;
-(id) initWithEventDomain:(id) input;

// getters
- (NSString*) app_id;
- (NSString*) event_domain;

// setters
- (void) setAppId: (NSString*) input;
- (void) setEventDomain: (NSString*) input;

@end
