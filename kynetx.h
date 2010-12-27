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
	NSString *event_url; // for event url
}

// getters
- (NSString*) app_id;
- (NSString*) event_url;

// setters
- (void) setAppId: (NSString*) app_id;
- (void) setEventUrl: (NSString*) event_url;

@end
