//
//  SrtParser.h
//  Subtle Subtitle
//
//  Created by Tony Wang on 10/22/13.
//  Copyright (c) 2013 Tony Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SrtParser : NSObject

+ (void)parseContentOfSrtFile:(NSString *)content;

@end
