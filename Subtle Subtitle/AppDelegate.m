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
#import "Subtitles.h"

@interface AppDelegate () {
  NSPanel *panel;
  NSUInteger subIndex;
  NSTimer *_timer;
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
  panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(screenRect.origin.x + 100,
                                                          screenRect.origin.y + 100,
                                                          800,
                                                          100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  [panel setIgnoresMouseEvents:YES];
  [panel setHidesOnDeactivate:NO];
  [panel setFloatingPanel:YES];
  [panel setAlphaValue:0.9];
  [panel setBackgroundColor:[NSColor blackColor]];
  lineText = [[NSText alloc] initWithFrame:NSMakeRect(10, 10, 780, 100)];
  [lineText setTextColor:[NSColor whiteColor]];
  [lineText setBackgroundColor:[NSColor clearColor]];
  [lineText setFont:[NSFont fontWithName:@"Helvetica" size:18]];
  [lineText setAlignment:NSCenterTextAlignment];
  [[panel contentView] addSubview:lineText];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
  NSError *err;
  NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95);
  NSString *content = [NSString stringWithContentsOfFile:filename encoding:gbkEncoding error:&err];
  if (err) {
    NSLog(@"Error reading srt file: %@", [err localizedDescription]);
    return NO;
  }
  [SrtParser parseContentOfSrtFile:content];
  [self setTimerIfNecessary];
  return YES;
}

- (void)setTimerIfNecessary {
  if ([iTunes playerState] == iTunesEPlSPlaying) {
    [self setTimer];
  }
}

- (void)setTimer {
  _timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(showLine:) userInfo:nil repeats:YES];
}

- (void)showLine:(NSTimer *)timer {
  subIndex = [[Subtitles sharedInstance] getLineIndexAt:[iTunes playerPosition]];
  Line *line = [[Subtitles sharedInstance] getLineAtIndex:subIndex];
  if ([line getTime] <= [iTunes playerPosition]) {
    if ([line text]) {
      [lineText setString:[line text]];
      [panel orderFront:nil];
    } else {
      [panel orderOut:nil];
    }
  }
}

- (void)info:(NSNotification *)notification {
  if ([[notification userInfo][@"Player State"] isEqualToString:@"Playing"]) {
    if (!_timer) {
      [self setTimer];
    }
  } else {
    [_timer invalidate];
    _timer = nil;
    if ([[notification userInfo][@"Player State"] isEqualToString:@"Stopped"]) {
      [panel orderOut:nil];
    }
  }
}

@end