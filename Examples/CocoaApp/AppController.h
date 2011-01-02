//
//  AppController.h
//  kynetx-desktop
//
//  Created by Alex  on 12/27/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Kynetx.h"


@interface AppController : NSObject {

	IBOutlet NSButton *testKynetx;
	IBOutlet NSTextField *appIDField;
}
@property (retain) Kynetx* app;
- (IBAction) sendTestKynetx:(id) sender;
- (IBAction) appIDVal:(id) sender; 
- (void) dealloc;


@end
