#include "AppDelegate.h"

#include "cocos2d.h"
#include "storage/local-storage/LocalStorage.h"

#include "cocos/scripting/js-bindings/manual/ScriptingCore.h"
#include "cocos/scripting/js-bindings/manual/jsb_module_register.hpp"
#include "cocos/scripting/js-bindings/manual/jsb_global.h"
#include "cocos/scripting/js-bindings/jswrapper/SeApi.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && PACKAGE_AS
#include "SDKManager.h"
#include "jsb_anysdk_protocols_auto.hpp"
#include "manualanysdkbindings.hpp"
using namespace anysdk::framework;
#endif

#include "SettingsBundleHelper.h"

#ifdef SDK_BUGLY
#include "Bugly/CocosPlugin/bugly/CrashReport.h"
#endif

#include "utils/UtilsSdk.h"

USING_NS_CC;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    ScriptEngineManager::destroyInstance();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && PACKAGE_AS
    SDKManager::getInstance()->purge();
#endif
}

void AppDelegate::initGLContextAttrs()
{
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // 将启动逻辑移至其他生命周期中调用applicationOnLoad，防止启动超过20秒被iOS系统自动杀死
    // iOS移至APPController::applicationDidBecomeActive中
    // Android移至
    return true;
}

void AppDelegate::applicationOnLoad()
{    
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS && PACKAGE_AS
    SDKManager::getInstance()->loadAllPlugins();
#endif
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
#if(CC_TARGET_PLATFORM == CC_PLATFORM_WP8) || (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
        glview = GLViewImpl::create("Smart_Pi");
#else
        glview = GLViewImpl::createWithRect("Smart_Pi", cocos2d::Rect(0,0,900,640));
#endif
        director->setOpenGLView(glview);
    }

    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);

    ScriptingCore* sc = ScriptingCore::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(sc);

    se::ScriptEngine* se = se::ScriptEngine::getInstance();

    jsb_set_xxtea_key("2fa0980b-3f32-4b");
    jsb_init_file_operation_delegate();

#if defined(COCOS2D_DEBUG) && (COCOS2D_DEBUG > 0)
    // Enable debugger here
    jsb_enable_debugger("0.0.0.0", 5086);
#endif

    se->setExceptionCallback([](const char* location, const char* message, const char* stack){
        // Send exception information to server like Tencent Bugly.
#ifdef SDK_BUGLY
        CrashReport::reportException(6, "SmartPiJsError", message, stack);
#endif
    });

    jsb_register_all_modules();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && PACKAGE_AS
    se->addRegisterCallback(register_all_anysdk_framework);
    se->addRegisterCallback(register_all_anysdk_manual);
#endif

    se->start();

    // Android AntiCrack
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    if(UtilsSdk::isReleaseMode()) {
        // check signature code
        int code = UtilsSdk::getSignatureCode();
        int checks[] = {
            2042613917, //smartpi.keystore
        };

        bool isLegalCopy = false;
        for(int check : checks) {
            isLegalCopy = isLegalCopy || (check == code);
        }
        if(isLegalCopy == false) {
            //cocos2d::log("check signature code %d", code);
            assert(0);
            Director::getInstance()->end();
        }
    }
#endif

    // Clear hot update
    bool check1 = SettingsBundleHelper::checkAppVersion(this->getVersion());
    bool check2 = SettingsBundleHelper::checkResetUpdate();
    if(check1 || check2) {
        clearAllUpdateResources();
    }

    jsb_run_script("main.js");

    mIsApplicationLoaded = true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    auto director = Director::getInstance();
    director->stopAnimation();
    director->getEventDispatcher()->dispatchCustomEvent("game_on_hide");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    auto director = Director::getInstance();
    director->startAnimation();
    director->getEventDispatcher()->dispatchCustomEvent("game_on_show");
}

void AppDelegate::clearAllUpdateResources()
{
    auto fileUtils = FileUtils::getInstance();
    auto cacheDirectory = fileUtils->getWritablePath() + "/congmingpai";
    if (fileUtils->isDirectoryExist(cacheDirectory)){
        fileUtils->removeDirectory(cacheDirectory);
    }
}
