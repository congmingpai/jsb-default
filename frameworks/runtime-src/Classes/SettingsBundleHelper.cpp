//
//  SettingsBundleHelper.cpp
//  Smart_Pi-mobile
//
//  Created by YUXIAO on 2018/12/26.
//

#include "cocos2d.h"
#include "SettingsBundleHelper.h"

USING_NS_CC;

bool SettingsBundleHelper::checkAppVersion(const std::string &version)
{
    std::string lastVersion = UserDefault::getInstance()->getStringForKey("settings.app_version");
    if(version != lastVersion) {
        UserDefault::getInstance()->setStringForKey("settings.app_version", version);
        return true;
    }
    return false;
}

bool SettingsBundleHelper::checkResetUpdate()
{
    bool reset = UserDefault::getInstance()->getBoolForKey("settings.reset_update");
    if(reset) {
        UserDefault::getInstance()->setBoolForKey("settings.reset_update", false);
        return true;
    }
    return false;
}
