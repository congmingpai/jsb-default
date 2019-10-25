#include <set>
#include "cocos2d.h"
#include "SdkManager.h"

//#include "json/document.h"
//#include "json/rapidjson.h"
//#include "json/filestream.h"
//#include "json/prettywriter.h"
//#include "json/stringbuffer.h"

static std::set<Sdk*> _sdks;

#include "utils/UtilsSdk.h"
UtilsSdk utilssdk;

#include "hash/HashSdk.h"
HashSdk hashsdk;

#ifdef SDK_WECHAT
#include "wechat/WechatSdk.h"
WechatSdk wechatsdk;
#endif

#ifdef SDK_REACHABILITY
#include "reachability/ReachabilitySdk.h"
ReachabilitySdk reachabilitysdk;
#endif

#ifdef SDK_BUGLY
#include "Bugly/BuglySdk.h"
BuglySdk buglysdk;
#endif


USING_NS_CC;

void SdkManager::addSdk(Sdk *sdk)
{
    _sdks.insert(sdk);
}

void SdkManager::removeSdk(Sdk *sdk)
{
    _sdks.erase(sdk);
}

Sdk* SdkManager::getSdk(const std::string &name)
{
    for(Sdk *sdk : _sdks) {
        if(sdk->_name == name) {
            return sdk;
        }
    }
    return nullptr;
}

void SdkManager::call(const std::string &clazz, const std::string &method, const std::string &params, const Sdk::SdkCallback &callback)
{
    Sdk *sdk = getSdk(clazz);
    if(sdk) {
        sdk->call(method, params, callback);
    }
}


#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
void *SdkManager::appController = nullptr;
void *SdkManager::viewController = nullptr;
void *SdkManager::window = nullptr;

void SdkManager::applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary)
{
    for(Sdk *sdk : _sdks) {
       sdk->applicationDidFinishLaunching(iosUIApplication, iosNSDictionary);
    }
}

void SdkManager::applicationWillResignActive(void *iosUIApplication)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationWillResignActive(iosUIApplication);
    }
}

void SdkManager::applicationDidBecomeActive(void *iosUIApplication)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationDidBecomeActive(iosUIApplication);
    }
}

void SdkManager::applicationDidEnterBackground(void *iosUIApplication)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationDidEnterBackground(iosUIApplication);
    }
}

void SdkManager::applicationWillEnterForeground(void *iosUIApplication)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationWillEnterForeground(iosUIApplication);
    }
}

void SdkManager::applicationWillTerminate(void *iosUIApplication)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationWillTerminate(iosUIApplication);
    }
}

bool SdkManager::applicationOpenURL(void *iosUIApplication, void *iosNSURL, void *iosNSDictionary)
{
    bool ret = false;
    
    for(Sdk *sdk : _sdks) {
        ret = ret || sdk->applicationOpenURL(iosUIApplication, iosNSURL, iosNSDictionary);
    }
    
    return ret;
}

void SdkManager::applicationDidReceiveLocalNotification(void *iosUIApplication, void *iosUILocalNotification)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationDidReceiveLocalNotification(iosUIApplication, iosUILocalNotification);
    }
}

void SdkManager::applicationDidRegisterUserNotificationSettings(void *iosUIApplication, void *iosUIUserNotificationSettings)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationDidRegisterUserNotificationSettings(iosUIApplication, iosUIUserNotificationSettings);
    }
}

void SdkManager::applicationHandleActionWithIdentifierForRemoteNotification(void *iosUIApplication, void *iosNSString, void *iosNSDictionary, void *completionHandler)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationHandleActionWithIdentifierForRemoteNotification(iosUIApplication, iosNSString, iosNSDictionary, completionHandler);
    }
}

void SdkManager::applicationdidRegisterForRemoteNotificationsWithDeviceToken(void *iosUIApplication, void *iosNSData)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationdidRegisterForRemoteNotificationsWithDeviceToken(iosUIApplication, iosNSData);
    }
}

void SdkManager::applicationDidFailToRegisterForRemoteNotificationsWithError(void *iosUIApplication, void *iosNSError)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationDidFailToRegisterForRemoteNotificationsWithError(iosUIApplication, iosNSError);
    }
}

void SdkManager::applicationDidReceiveRemoteNotification(void *iosUIApplication, void *iosNSDictionary)
{
    for(Sdk *sdk : _sdks) {
        sdk->applicationDidReceiveRemoteNotification(iosUIApplication, iosNSDictionary);
    }
}

int SdkManager::applicationSupportedInterfaceOrientationsForWindow(void *iosUIApplication, void *iosUIWindow)
{
    int orientations = 0;
    for(Sdk *sdk : _sdks) {
        orientations |= sdk->applicationSupportedInterfaceOrientationsForWindow(iosUIApplication, iosUIWindow);
    }
    return orientations;
}
#endif


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void *SdkManager::appActivity = nullptr;
void *SdkManager::glSurfaceView = nullptr;

void SdkManager::activityOnCreate()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnCreate();
    }
}

void SdkManager::activityOnPause()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnPause();
    }
}

void SdkManager::activityOnResume()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnResume();
    }
}

void SdkManager::activityOnDestroy()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnDestroy();
    }
}

void SdkManager::activityOnStart()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnStart();
    }
}

void SdkManager::activityOnRestart()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnRestart();
    }
}

void SdkManager::activityOnStop()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnStop();
    }
}

void SdkManager::activityOnNewIntent(void *intent)
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnNewIntent(intent);
    }
}

void SdkManager::activityOnActivityResult(int request, int result, void *intent)
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnActivityResult(request, result, intent);
    }
}

void SdkManager::activityOnBackPressed()
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnBackPressed();
    }
}

void SdkManager::activityOnSaveInstanceState(void *bundle)
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnSaveInstanceState(bundle);
    }
}

void SdkManager::activityOnRestoreInstanceState(void *bundle)
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnRestoreInstanceState(bundle);
    }
}

void SdkManager::activityOnConfigurationChanged(void *configuration)
{
    for(Sdk *sdk : _sdks) {
        sdk->activityOnConfigurationChanged(configuration);
    }
}

extern "C" {
    void Java_org_cocos2dx_javascript_SdkManager_setAppActivity(JNIEnv *env, jobject thiz, jobject activity)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_setAppActivity");
        SdkManager::appActivity = (void*)env->NewGlobalRef(activity);
    }
    void Java_org_cocos2dx_javascript_SdkManager_setGLSurfaceView(JNIEnv *env, jobject thiz, jobject view)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_setGLSurfaceView");
        SdkManager::glSurfaceView = (void*)env->NewGlobalRef(view);
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnCreate(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnCreate");
        SdkManager::activityOnCreate();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnPause(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnPause");
        SdkManager::activityOnPause();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnResume(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnResume");
        SdkManager::activityOnResume();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnDestroy(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnDestroy");
        SdkManager::activityOnDestroy();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnStart(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnStart");
        SdkManager::activityOnStart();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnRestart(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnRestart");
        SdkManager::activityOnRestart();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnStop(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnStop");
        SdkManager::activityOnStop();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnNewIntent(JNIEnv *env, jobject thiz, jobject jintent)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnNewIntent");
        void *intent = (void*)env->NewLocalRef(jintent);
        SdkManager::activityOnNewIntent(intent);
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnActivityResult(JNIEnv *env, jobject thiz, int request, int result, jobject jintent)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnActivityResult");
        void *intent = (void*)env->NewLocalRef(jintent);
        SdkManager::activityOnActivityResult(request, result, intent);
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnBackPressed(JNIEnv *env, jobject thiz)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnBackPressed");
        SdkManager::activityOnBackPressed();
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnSaveInstanceState(JNIEnv *env, jobject thiz, jobject jbundle)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnSaveInstanceState");
        void *bundle = (void*)env->NewLocalRef(jbundle);
        SdkManager::activityOnSaveInstanceState(bundle);
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnRestoreInstanceState(JNIEnv *env, jobject thiz, jobject jbundle)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnRestoreInstanceState");
        void *bundle = (void*)env->NewLocalRef(jbundle);
        SdkManager::activityOnRestoreInstanceState(bundle);
    }
    void Java_org_cocos2dx_javascript_SdkManager_activityOnConfigurationChanged(JNIEnv *env, jobject thiz, jobject jconfiguration)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_SdkManager_activityOnConfigurationChanged");
        void *configuration = (void*)env->NewLocalRef(jconfiguration);
        SdkManager::activityOnConfigurationChanged(configuration);
    }
}
#endif
