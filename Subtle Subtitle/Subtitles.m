//
//  Subtitles.m
//  Subtle Subtitle
//
//  Created by Tony Wang on 10/22/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import "Subtitles.h"

@implementation Line

@synthesize text=_text;

- (id)initWithTime:(double)time withText:(NSString *)text {
  if ((self = [super init])) {
    self->_time = time;
    [self setText:text];
  }
  return self;
}

- (double)getTime {
  return _time;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"[%f] %@", _time, _text];
}

@end

@interface Subtitles () {
  NSMutableArray *lines;
}

@end

@implementation Subtitles

+ (instancetype)sharedInstance {
  static Subtitles *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void)clear {
  lines = nil;
}

- (void)beginLines {
  lines = [[NSMutableArray alloc] init];
}

- (BOOL)isReady {
  return lines != nil;
}

- (void)appendLineAt:(double)time withText:(NSString *)text {
  Line *line = [[Line alloc] initWithTime:time withText:text];
  [lines addObject:line];
}

- (NSUInteger)getLineIndexAt:(double)time {
  NSUInteger low = 0;
  NSUInteger high = [lines count] - 1;
  NSUInteger mid;
  while (low < high) {
    mid = low + (high - low) / 2;
    if ([lines[mid] getTime] < time) {
      low = mid + 1;
    } else if ([lines[mid] getTime] > time) {
      high = mid - 1;
    } else {
      return mid;
    }
  }
  if ([lines[high] getTime] < time) {
    return high;
  } else {
    return high - 1;
  }
}

- (Line *)getLineAtIndex:(NSUInteger)index {
  if (index > [lines count]) {
    return nil;
  }
  return lines[index];
}

@end
