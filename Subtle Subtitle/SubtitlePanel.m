//
//  SubtitlePanel.m
//  Subtle Subtitle
//
//  Created by Tony Wang on 11/3/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import "SubtitlePanel.h"

@implementation SubtitlePanel

- (void)mouseDragged:(NSEvent *)event {
  NSRect frame = [self frame];
  frame.origin.x += [event deltaX];
  frame.origin.y -= [event deltaY];
  [self setFrameOrigin:frame.origin];
}

- (BOOL)canBecomeKeyWindow {
  return YES;
}

@end
