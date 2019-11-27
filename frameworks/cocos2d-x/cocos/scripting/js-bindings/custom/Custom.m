//
//  Custom.m
//  libjscocos2d Mac
//
//  Created by 朱嘉灵 on 2019/11/26.
//

#include "Custom.h"
#import <Foundation/Foundation.h>
#import "LoggerClient.h"

void log_to_nslogger(const int& level, const char* format, const char* prefix, const char* content)
{
    NSString* message = [NSString stringWithFormat:[NSString stringWithUTF8String:format], [NSString stringWithUTF8String:prefix], [NSString stringWithUTF8String:content]];
    LogMessage(nil, level, @"%@", message);
}
