//
//  AppDelegate.h
//  kynetx-objc
//
//  Created by Alex  on 12/23/10.
//  Copyright 2011 Kynetx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainWindowController* windowController;
}

@property (nonatomic, retain) IBOutlet MainWindowController *windowController;

@end
