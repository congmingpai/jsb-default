//
//  BuglySdk.hpp
//  Smart_Pi-mobile
//
//  Created by YUXIAO on 2018/7/16.
//

#ifndef BuglySdk_hpp
#define BuglySdk_hpp

#include "Sdk.h"

class BuglySdk : public Sdk
{
public:
    BuglySdk() : Sdk("BuglySdk") {}
    
    void init(const std::string &appid);
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
public:
    virtual void applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary) override;
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
public:
    virtual void activityOnCreate() override;
#endif
};


#endif /* BuglySdk_hpp */
