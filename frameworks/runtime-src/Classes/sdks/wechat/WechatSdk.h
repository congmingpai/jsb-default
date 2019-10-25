//
//  WechatSdk.h
//  Smart_Pi
//
//  Created by YUXIAO on 2018/6/12.
//

#ifndef WechatSdk_h
#define WechatSdk_h

#include "Sdk.h"

class WechatSdk : public Sdk
{
public:
    WechatSdk();
    
    virtual void call(const std::string &method, const std::string &params, const Sdk::SdkCallback &callback) override;
    
    void login(const Sdk::SdkCallback &callback);
    void loginWithQrcode(const Sdk::SdkCallback &callback);
    
    // weixin api
    bool isWXAppInstalled();
    std::string getWXAppInstallUrl();

private:
    void getWxAccessToken();
    void getWxTicket(const std::string &token);
    void doWxQrcodeAuth(const std::string &ticket);
    
    std::string genWxSignature(const std::string &ticket, const std::string &noncestr, const std::time_t &timestamp);
    
    std::string _appID;
    std::string _appSecret;
    
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
public:
    void *_wechatAuthSDK;
    virtual void applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary) override;
    virtual bool applicationOpenURL(void *iosUIApplication, void *iosNSURL, void *iosNSDictionary) override;
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
public:
    virtual void activityOnCreate() override;
#endif
};

#endif /* WechatSdk_h */
