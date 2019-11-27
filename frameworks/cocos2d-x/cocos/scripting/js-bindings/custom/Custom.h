//
//  Custom.h
//  cocos2d_js_bindings
//
//  Created by 朱嘉灵 on 2019/11/26.
//

#pragma once

#ifndef CUSTOM_LOG_LEVEL_INFO
#define CUSTOM_LOG_LEVEL_INFO 2
#endif

#ifndef CUSTOM_LOG_LEVEL_WARN
#define CUSTOM_LOG_LEVEL_WARN 1
#endif

#ifndef CUSTOM_LOG_LEVEL_ERROR
#define CUSTOM_LOG_LEVEL_ERROR 0
#endif

// 以下说明摘自NSLogger.h
// Level 0: errors only!
// Level 1: important informations, app states…
// Level 2: less important logs, network requests…
// Level 3: network responses, datas and images…
// Level 4: really not important stuff.

void log_to_nslogger(const int& level, const char* message);
