//
//  BuglySdk.cpp
//  Smart_Pi-mobile
//
//  Created by YUXIAO on 2018/7/16.
//

#include "BuglySdk.h"
#include "CocosPlugin/bugly/CrashReport.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
void BuglySdk::applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary)
{
    init("edd98a8f02");
}
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void BuglySdk::activityOnCreate()
{
    init("ffe1df8a81");
}
#endif

void BuglySdk::init(const std::string &appid)
{
    CrashReport::initCrashReport(appid.c_str());
}

