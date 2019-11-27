//
//  Custom.m
//  libjscocos2d Mac
//
//  Created by 朱嘉灵 on 2019/11/26.
//

#include "Custom.h"
#import <Foundation/Foundation.h>
#import "LoggerClient.h"

void log_to_nslogger(const int& level, const char* message)
{
    LogMessage(nil, level, @"%@", [NSString stringWithUTF8String:message]);
}
