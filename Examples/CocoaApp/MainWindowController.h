//
//  AppController.h
//  kynetx-desktop
//
//  Created by Alex  on 12/27/10.
//  Copyright 2010 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Kynetx.h"


@interface MainWindowController : NSWindowController {
	
	@private
	Kynetx* app_;
	
	IBOutlet NSButton *testKynetx;
	IBOutlet NSTextField *appIDField;
}
@property (nonatomic, retain) Kynetx* app;
- (IBAction) sendTestKynetx:(id) sender;
- (IBAction) appIDVal:(id) sender; 
- (void) dealloc;


@end
