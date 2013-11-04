//
//  AppDelegate.m
//  Subtle Subtitle
//
//  Created by Tony Wang on 05/27/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import "AppDelegate.h"

#import "iTunes.h"
#import "SrtParser.h"
#import "SubtitlePanel.h"
#import "Subtitles.h"

#define PANEL_WIDTH 800
#define PANEL_HEIGHT 100

@interface AppDelegate () {
  SubtitlePanel *panel;
  NSUInteger subIndex;
  BOOL isTimerRunning;
  dispatch_source_t timer;
  NSText *lineText;
  iTunesApplication *iTunes;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
  [dnc addObserver:self selector:@selector(info:) name:@"com.apple.iTunes.playerInfo" object:nil];
  iTunes = (iTunesApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

  NSRect screenRect = [[NSScreen mainScreen] frame];
  CGFloat x, y;
  if (screenRect.size.width < PANEL_WIDTH) {
    x = 0;
  } else {
    x = (screenRect.size.width - PANEL_WIDTH) / 2;
  }
  if (screenRect.size.height < (PANEL_HEIGHT + 50)) {
    y = 0;
  } else {
    y = 50;
  }
  panel = [[SubtitlePanel alloc] initWithContentRect:NSMakeRect(screenRect.origin.x + x,
                                                                screenRect.origin.y + y,
                                                                PANEL_WIDTH,
                                                                PANEL_HEIGHT) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  [panel setHidesOnDeactivate:NO];
  [panel setFloatingPanel:YES];
  [panel setAlphaValue:0.9];
  [panel setBackgroundColor:[NSColor blackColor]];
  lineText = [[NSText alloc] initWithFrame:NSMakeRect(10, 10, 780, 100)];
  [lineText setTextColor:[NSColor whiteColor]];
  [lineText setBackgroundColor:[NSColor clearColor]];
  [lineText setFont:[NSFont fontWithName:@"Helvetica" size:18]];
  [lineText setAlignment:NSCenterTextAlignment];
  [lineText setSelectable:NO];
  [[panel contentView] addSubview:lineText];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
  return [self readSubtitleFile:filename];
}

- (IBAction)openFile:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setDelegate:self];
  if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
    [self readSubtitleFile:[[openPanel URLs][0] path]];
  }
}

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
  NSNumber *isDir;
  NSError *err;
  if (![url getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:&err] || err) {
    if (err) {
      NSLog(@"Error checking NSURLIsDirectoryKey: %@", [err localizedDescription]);
    }
    return NO;
  }
  if ([isDir boolValue]) {
    return YES;
  }
  if ([[url pathExtension] isEqualToString:@"srt"]) {
    return YES;
  }
  return NO;
}

- (BOOL)readSubtitleFile:(NSString *)filename {
  // guess encoding, if failed, try GBK
  NSError *err;
  NSString *content;
  content = [NSString stringWithContentsOfFile:filename usedEncoding:nil error:&err];
  if (err) {
    err = nil;
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95);
    content = [NSString stringWithContentsOfFile:filename encoding:gbkEncoding error:&err];
    if (err) {
      [NSAlert alertWithMessageText:[err localizedDescription] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
      return NO;
    }
  }
  [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
  [SrtParser parseContentOfSrtFile:content];
  [self setTimerIfNecessary];
  return YES;
}

//- (void)applicationDidBecomeActive:(NSNotification *)notification {
//  [panel setIgnoresMouseEvents:NO];
//}
//
//- (void)applicationDidResignActive:(NSNotification *)notification {
//  [panel setIgnoresMouseEvents:YES];
//}

- (void)setTimerIfNecessary {
  if ([iTunes playerState] == iTunesEPlSPlaying) {
    [self setTimer];
  }
}

- (void)setTimer {
  NSLog(@"set timer");
  timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                 0,
                                 DISPATCH_TIMER_STRICT,
                                 dispatch_get_main_queue());
  dispatch_source_set_event_handler(timer, ^{
    [self showLine];
  });
  dispatch_source_set_timer(timer,
                            dispatch_time(DISPATCH_TIME_NOW, 0),
                            100 * NSEC_PER_MSEC,
                            50 * NSEC_PER_MSEC);
  dispatch_resume(timer);
}

- (void)showLine {
  subIndex = [[Subtitles sharedInstance] getLineIndexAt:([iTunes playerPosition] + 1)];
  Line *line = [[Subtitles sharedInstance] getLineAtIndex:subIndex];
  if ([line getTime] <= ([iTunes playerPosition] + 1)) {
    if ([line text]) {
      [lineText setString:[line text]];
      [panel orderFront:nil];
    } else {
      [panel orderOut:nil];
    }
  }
}

- (void)info:(NSNotification *)notification {
  NSLog(@"%@", notification);
  if ([[notification userInfo][@"Player State"] isEqualToString:@"Playing"]) {
    if ([[Subtitles sharedInstance] isReady]) {
      [panel setFloatingPanel:YES];
      if (timer) {
        dispatch_resume(timer);
      } else {
        [self setTimer];
      }
    }
  } else {
    if (timer) {
      dispatch_suspend(timer);
      [panel setFloatingPanel:NO];
      if ([[notification userInfo][@"Player State"] isEqualToString:@"Stopped"]) {
        [panel orderOut:nil];
      }
    }
  }
}

@end