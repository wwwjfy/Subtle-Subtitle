//
//  SrtParser.m
//  Subtle Subtitle
//
//  Created by Tony Wang on 10/22/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import "SrtParser.h"

#import "Subtitles.h"

typedef enum SRTSTAT {
  COUNTER,
  TIME,
  TEXT
} SRTSTAT;

double getTimeFrom(NSString *timeStr) {
  double result = 0;
  NSArray *t = [timeStr componentsSeparatedByString:@":"];
  result += [t[0] doubleValue] * 3600;
  result += [t[1] doubleValue] * 60;
  result += [[t[2] stringByReplacingOccurrencesOfString:@","
                                             withString:@"."] doubleValue];
  return result;
}

@implementation SrtParser

+ (void)parseContentOfSrtFile:(NSString *)content {
  unsigned i = 0;
  NSArray *components = [content componentsSeparatedByString:@"\r\n"];
  NSUInteger count = [components count];
  SRTSTAT stat = COUNTER;
  double begin, end;
  NSString *text = @"";
  [[Subtitles sharedInstance] beginLines];
  [[Subtitles sharedInstance] appendLineAt:0 withText:nil];
  while (i < count) {
    switch (stat) {
      case COUNTER:
      {
        if (![components[i] isEqualToString:@""]) {
          stat = TIME;
        }
        break;
      }

      case TIME:
      {
        NSArray *t = [(NSString *)components[i] componentsSeparatedByString:@" --> "];
        begin = getTimeFrom(t[0]);
        end = getTimeFrom(t[1]);
        stat = TEXT;
        break;
      }

      case TEXT:
      {
        if ([components[i] isEqualToString:@""]) {
          [[Subtitles sharedInstance] appendLineAt:begin withText:text];
          [[Subtitles sharedInstance] appendLineAt:end withText:nil];
          text = @"";
          stat = COUNTER;
        } else {
          text = [[text stringByAppendingString:@"\n"] stringByAppendingString:components[i]];
        }
        break;
      }
    }
    i++;
  }
}

@end
