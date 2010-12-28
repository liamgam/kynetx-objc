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
@property (retain) SBJsonParser* parser;

// constructors
-(id) init;
-(id) initWithAppId:(id) input;

// destructor
-(void) dealloc;


@end
