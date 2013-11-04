//
//  Subtitles.h
//  Subtle Subtitle
//
//  Created by Tony Wang on 10/22/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject {
  double _time;
  NSString *_text;
}

@property NSString *text;

- (double)getTime;

@end

@interface Subtitles : NSObject

+ (instancetype)sharedInstance;
- (BOOL)isReady;
- (void)clear;
- (void)beginLines;
- (void)appendLineAt:(double)time withText:(NSString *)text;
- (NSUInteger)getLineIndexAt:(double)time;
- (Line *)getLineAtIndex:(NSUInteger)index;

@end
