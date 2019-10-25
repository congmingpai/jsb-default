#ifndef __SdkManager__
#define __SdkManager__

#include "cocos2d.h"
#include "Sdk.h"

class SdkManager
{
public:
#ifndef SKIP_BY_AUTO_BINDINGS
    static void addSdk(Sdk *sdk);
    static void removeSdk(Sdk *sdk);
    static Sdk *getSdk(const std::string &name);
#endif
    
    static void call(const std::string &clazz, const std::string &method, const std::string &params, const Sdk::SdkCallback &callback);
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
public:
    static void *appController;
    static void *viewController;
    static void *window;
    
    static void applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary);
    static void applicationWillResignActive(void *iosUIApplication);
    static void applicationDidBecomeActive(void *iosUIApplication);
    static void applicationDidEnterBackground(void *iosUIApplication);
    static void applicationWillEnterForeground(void *iosUIApplication);
    static void applicationWillTerminate(void *iosUIApplication);
    static bool applicationOpenURL(void *iosUIApplication, void *iosNSURL, void *iosNSDictionary);
    static void applicationdidRegisterForRemoteNotificationsWithDeviceToken(void *iosUIApplication, void *iosNSData);
    static void applicationDidReceiveRemoteNotification(void *iosUIApplication, void *iosNSDictionary);
    static void applicationDidReceiveLocalNotification(void *iosUIApplication, void *iosUILocalNotification);
    static void applicationDidRegisterUserNotificationSettings(void *iosUIApplication, void *iosUIUserNotificationSettings);
    static void applicationHandleActionWithIdentifierForRemoteNotification(void *iosUIApplication, void *iosNSString, void *iosNSDictionary, void *completionHandler);
    static void applicationDidFailToRegisterForRemoteNotificationsWithError(void *iosUIApplication, void *iosNSError);
    static int applicationSupportedInterfaceOrientationsForWindow(void *iosUIApplication, void *iosUIWindow);
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) && !defined(SKIP_BY_AUTO_BINDINGS)
public:
    static void *appActivity;
    static void *glSurfaceView;
    
    static void activityOnCreate();
    static void activityOnPause();
    static void activityOnResume();
    static void activityOnDestroy();
    static void activityOnStart();
    static void activityOnRestart();
    static void activityOnStop();
    static void activityOnNewIntent(void *intent);
    static void activityOnActivityResult(int request, int result, void *intent);
    static void activityOnBackPressed();
    static void activityOnSaveInstanceState(void *bundle);
    static void activityOnRestoreInstanceState(void *bundle);
    static void activityOnConfigurationChanged(void *configuration);
#endif
};

#endif /* defined(__SdkManager__) */
