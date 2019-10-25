#ifndef __Sdk__
#define __Sdk__

#include "cocos2d.h"
#include "json/document.h"
#include "json/rapidjson.h"
#include "json/prettywriter.h"
#include "json/stringbuffer.h"

class SdkManager;

class Sdk
{
    friend SdkManager;
    
public:
    CC_SYNTHESIZE(std::string, _name, Name);
    
    Sdk(const std::string &name);
    virtual ~Sdk();
    
    typedef std::function<void(const std::string &result)> SdkCallback;
    
    virtual void call(const std::string &method, const std::string &params, const SdkCallback &callback) {}
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
public:
    virtual void applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary) {}
    virtual void applicationWillResignActive(void *iosUIApplication) {}
    virtual void applicationDidBecomeActive(void *iosUIApplication) {}
    virtual void applicationDidEnterBackground(void *iosUIApplication) {}
    virtual void applicationWillEnterForeground(void *iosUIApplication) {}
    virtual void applicationWillTerminate(void *iosUIApplication) {}
    virtual bool applicationOpenURL(void *iosUIApplication, void *iosNSURL, void *iosNSDictionary) { return false; }
    virtual void applicationdidRegisterForRemoteNotificationsWithDeviceToken(void *iosUIApplication, void *iosNSData) {}
    virtual void applicationDidReceiveRemoteNotification(void *iosUIApplication, void *iosNSDictionary) {}
    virtual void applicationDidReceiveLocalNotification(void *iosUIApplication, void *iosUILocalNotification) {}
    virtual void applicationDidRegisterUserNotificationSettings(void *iosUIApplication, void *iosUIUserNotificationSettings) {}
    virtual void applicationHandleActionWithIdentifierForRemoteNotification(void *iosUIApplication, void *iosNSString, void *iosNSDictionary, void *completionHandler) {}
    virtual void applicationDidFailToRegisterForRemoteNotificationsWithError(void *iosUIApplication, void *iosNSError) {}
    virtual int  applicationSupportedInterfaceOrientationsForWindow(void *iosUIApplication, void *iosUIWindow) { return /*UIInterfaceOrientationMaskPortrait*/0x02; }
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
public:
    virtual void activityOnCreate() {}
    virtual void activityOnPause() {}
    virtual void activityOnResume() {}
    virtual void activityOnDestroy() {}
    virtual void activityOnStart() {}
    virtual void activityOnRestart() {}
    virtual void activityOnStop() {}
    virtual void activityOnNewIntent(void *intent) {}
    virtual void activityOnActivityResult(int request, int result, void *intent) {}
    virtual void activityOnBackPressed() {}
    virtual void activityOnSaveInstanceState(void *bundle) {}
    virtual void activityOnRestoreInstanceState(void *bundle) {}
    virtual void activityOnConfigurationChanged(void *configuration) {}
#endif
    
protected:
    class Parameters
    {
    public:
        Parameters();
        Parameters(const std::string &params);
        
        void parse(const std::string &params);
        std::string stringify(bool pretty = false);
        
        // getter
        bool getBoolean(const std::string &key);
        int getInt(const std::string &key);
        double getDouble(const std::string &key);
        std::string getString(const std::string &key);
        
        // setter
        void setBoolean(const std::string &key, bool value);
        void setInt(const std::string &key, int value);
        void setDouble(const std::string &key, double value);
        void setString(const std::string &key, const std::string &value);
        
    private:
        rapidjson::Document _json;
        rapidjson::Document::AllocatorType &_allocator;
        rapidjson::StringBuffer _buffer;
    };
};

#endif /* defined(__Sdk__) */

