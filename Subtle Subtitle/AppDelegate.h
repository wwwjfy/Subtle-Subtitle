//
//  AppDelegate.h
//  Subtle Subtitle
//
//  Created by Tony Wang on 05/27/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSOpenSavePanelDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction)openFile:(id)sender;

@end