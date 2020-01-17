//
//  UtilsSdk.cpp
//  Smart_Pi
//
//  Created by YUXIAO on 2018/7/17.
//

#include "UtilsSdk.h"
#include "SdkManager.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#include <sys/time.h>
#define CLASS_NAME "org/cocos2dx/javascript/UtilsSdk"
#endif

#ifdef SDK_BUGLY
#include "Bugly/CocosPlugin/bugly/CrashReport.h"
#endif

#include "utils/photos/PhotoPicker.h"

USING_NS_CC;

static std::string size2string(size_t size){
    char buf[32];
    snprintf(buf, sizeof(buf), "%zu", size);
    return buf;
}
static std::string int64tostring(long long num) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%lld", num);
    return buf;
}
static std::string uint64tostring(unsigned long long num) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%llu", num);
    return buf;
}
static std::string int32tostring(int num) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", num);
    return buf;
}
static std::string uint32tostring(unsigned int num) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%u", num);
    return buf;
}


void UtilsSdk::call(const std::string &method, const std::string &params, const SdkCallback &callback)
{
    if(method == "isDebugMode") {
        callback(isDebugMode() ? "true" : "false");
    }
    else if(method == "isReleaseMode") {
        callback(isReleaseMode() ? "true" : "false");
    }
    else if(method == "getTotalMemorySize"){
        unsigned long long total =  getTotalMemorySize();
        callback(uint64tostring(total));
    }
    else if(method == "getAvailableMemorySize"){
        unsigned long long available = getAvailableMemorySize();
        callback(uint64tostring(available));
    }
    else if(method == "getFileSystemTotalSize") {
        unsigned long long size = getFileSystemTotalSize();
        callback(uint64tostring(size));
    }
    else if(method == "getFileSystemFreeSize") {
        unsigned long long size = getFileSystemFreeSize();
        callback(uint64tostring(size));
    }
    else if(method == "getNetworkType") {
        NetworkType type = getNetworkType();
        callback(int32tostring(type));
    }
#ifdef SDK_BUGLY
    else if(method == "setBuglyUserID") {
        setBuglyUserID(params);
        callback("");
    }
    else if(method == "setBuglyUserData") {
        setBuglyUserData(params);
        callback("");
    }
#endif
    else if ("takePhoto" == method || "pickPhoto" == method || "takeOrPickPhoto" == method){
        this->takeOrPickPhoto(method, params, callback);
    }
    else {
        callback("");
    }
}

bool UtilsSdk::isDebugMode()
{
#if COCOS2D_DEBUG > 0
    return true;
#else
    return false;
#endif
}

bool UtilsSdk::isReleaseMode()
{
    return !isDebugMode();
}

unsigned long long UtilsSdk::getTotalMemorySize()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    unsigned long long free = [NSProcessInfo processInfo].physicalMemory;
    return free;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "getTolalMemory", "()J")) {
        unsigned long long memory = minfo.env->CallStaticLongMethod(minfo.classID, minfo.methodID);
        return memory;
    }
#endif
    return 0;
}

unsigned long long UtilsSdk::getAvailableMemorySize()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount =HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vmStats,&infoCount);
    unsigned long  available =  kernReturn == KERN_SUCCESS ? ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count)) : 0;
    return available;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "getAvailMemory", "()J")) {
        unsigned long long memory = minfo.env->CallStaticLongMethod(minfo.classID, minfo.methodID);
        return memory;
    }
#endif
    return 0;
}

unsigned long long UtilsSdk::getFileSystemTotalSize()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *total = [dictionary objectForKey:NSFileSystemSize];
        return [total unsignedLongLongValue];
    }
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "getTotalInternalFileSystemSize", "()J")) {
        unsigned long long size = minfo.env->CallStaticLongMethod(minfo.classID, minfo.methodID);
        return size;
    }
#endif
    return 0;
}

unsigned long long UtilsSdk::getFileSystemFreeSize()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *free = [dictionary objectForKey:NSFileSystemFreeSize];
        return [free unsignedLongLongValue];
    }
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "getAvailableInternalFileSystemSize", "()J")) {
        unsigned long long size = minfo.env->CallStaticLongMethod(minfo.classID, minfo.methodID);
        return size;
    }
#endif
    return 0;
}

std::string UtilsSdk::getUUID()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
    NSString *uuidString = [(__bridge NSString*)strRef stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(strRef);
    CFRelease(uuidRef);
    return [uuidString UTF8String];
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    do {
        JniMethodInfo minfo;
        JNIEnv *env = JniHelper::getEnv();

        jobject juuid = nullptr;
        if(JniHelper::getStaticMethodInfo(minfo,
                                          "java/util/UUID",
                                          "randomUUID",
                                          "()Ljava/util/UUID;")) {
            juuid = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
        }
        if(juuid == nullptr) {
            break;
        }

        jstring juuidstr = nullptr;
        if(JniHelper::getMethodInfo(minfo,
                                    "java/util/UUID",
                                    "toString",
                                    "()Ljava/lang/String;")) {
            juuidstr = (jstring)env->CallObjectMethod(juuid, minfo.methodID);
        }
        if(juuidstr == nullptr) {
            break;
        }

        if(JniHelper::getMethodInfo(minfo,
                                    "java/lang/String",
                                    "replace",
                                    "(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;")) {
            jstring jtarget = env->NewStringUTF("-");
            jstring jreplacement = env->NewStringUTF("");
            juuidstr = (jstring)env->CallObjectMethod(juuidstr, minfo.methodID, jtarget, jreplacement);
        }

        return JniHelper::jstring2string(juuidstr);
    } while(false);
#endif
    return "";
}


int UtilsSdk::getSignatureCode()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    JNIEnv *env = JniHelper::getEnv();

    jstring jPackageName = nullptr;
    if (JniHelper::getMethodInfo(minfo,
                                 "android/content/Context",
                                 "getPackageName",
                                 "()Ljava/lang/String;")) {
        jPackageName = (jstring)env->CallObjectMethod((jobject)SdkManager::appActivity, minfo.methodID);
    }
    if(jPackageName == nullptr) {
        return 0;
    }

    jobject jPackageManager = nullptr;
    if (JniHelper::getMethodInfo(minfo,
                                 "android/content/Context",
                                 "getPackageManager",
                                 "()Landroid/content/pm/PackageManager;")) {
        jPackageManager = (jobject)env->CallObjectMethod((jobject)SdkManager::appActivity, minfo.methodID);
    }
    if(jPackageManager == nullptr) {
        return 0;
    }

    jobject jPackageInfo = nullptr;
    if (JniHelper::getMethodInfo(minfo,
                                 "android/content/pm/PackageManager",
                                 "getPackageInfo",
                                 "(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;")) {
        jPackageInfo = (jobject)env->CallObjectMethod(jPackageManager, minfo.methodID, jPackageName, 64);
    }
    if(jPackageInfo == nullptr) {
        return 0;
    }

    jfieldID fidSignatures = env->GetFieldID(env->GetObjectClass(jPackageInfo),
                                             "signatures",
                                             "[Landroid/content/pm/Signature;");
    if(fidSignatures == nullptr) {
        return 0;
    }

    jobjectArray jarrSignatures = (jobjectArray)env->GetObjectField(jPackageInfo, fidSignatures);
    if(jarrSignatures == nullptr) {
        return 0;
    }

    jobject jsign = env->GetObjectArrayElement(jarrSignatures, 0);
    if(jsign == nullptr) {
        return 0;
    }

    jint code = 0;
    if (JniHelper::getMethodInfo(minfo,
                                 "android/content/pm/Signature",
                                 "hashCode",
                                 "()I")) {
        code = env->CallIntMethod(jsign, minfo.methodID);
    }

    return code;
#endif

    return 0;
}

UtilsSdk::NetworkType UtilsSdk::getNetworkType()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case ReachableViaWiFi: return WIFI;
        case ReachableViaWWAN: return MOBILE;
        default: return NO_NETWORK;
    }
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "getNetworkType", "()I")) {
        int type = minfo.env->CallStaticIntMethod(minfo.classID, minfo.methodID);
        switch (type) {
            case 0: return MOBILE;
            case 1: return WIFI;
            default: return NO_NETWORK;
        }
    }
#endif
    return NO_NETWORK;
}

#ifdef SDK_BUGLY
void UtilsSdk::setBuglyUserID(const std::string& id)
{
    CrashReport::setUserId(id.c_str());
}

void UtilsSdk::setBuglyUserData(const std::string& params)
{
    size_t index = params.find(":");
    if (std::string::npos != index)
    {
        std::string key = params.substr(0, index);
        std::string value = params.substr(index + 1, params.length() - index - 1);
// #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        CrashReport::addUserValue(key.c_str(), value.c_str());
// #endif
// #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//         JniMethodInfo minfo;
//         if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "setBuglyUserData", "(Ljava/lang/String;Ljava/lang/String;)V")) {
//             jstring jKey = minfo.env->NewStringUTF(key.c_str());
//             jstring jValue = minfo.env->NewStringUTF(value.c_str());
//             minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jKey, jValue);
//             minfo.env->DeleteLocalRef(jKey);
//             minfo.env->DeleteLocalRef(jValue);
//         }
// #endif
    }
}
#endif

void UtilsSdk::takeOrPickPhoto(const std::string& method, const std::string& path, const SdkCallback &callback)
{
    char buffer[128] = {};
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    sprintf(buffer, "%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000));
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    time_t current;
    time(&current);
    sprintf(buffer, "%lld", (long long)current);
#endif
    std::string key = std::string(buffer) + ":takePhoto";
    auto finder = _callbacks.find(key);
    if (_callbacks.end() != finder)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//        SE_REPORT_ERROR("key [%s] for callback already exists!", key.c_str());
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#endif
        callback("");
        return;
    }
    _callbacks[key] = callback;
    
    FileUtils::getInstance()->createDirectory(path);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    PhotoPicker* picker = [[PhotoPicker alloc] initWithKey:[NSString stringWithUTF8String:key.c_str()] :this];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    PhotoPicker* picker = new PhotoPicker(key, this);
#endif
    if ("takeOrPickPhoto" == method)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        [picker takeOrPickPhoto:[NSString stringWithUTF8String:(path + "/" + buffer + ".png").c_str()]];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        picker->takeOrPickPhoto(path + "/" + buffer + ".png");
#endif
    }
    else if ("takePhoto" == method)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        [picker takePhoto:[NSString stringWithUTF8String:(path + "/" + buffer + ".png").c_str()]];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        picker->takePhoto(path + "/" + buffer + ".png");
#endif
    }
    else if ("pickPhoto" == method)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        [picker pickPhoto:[NSString stringWithUTF8String:(path + "/" + buffer + ".png").c_str()]];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        picker->pickPhoto(path + "/" + buffer + ".png");
#endif
    }
}

void UtilsSdk::callbackToMainThread(const std::string key, const std::string argument)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    dispatch_async(dispatch_get_main_queue(), ^{
        this->invoke(key, argument);
    });
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    // 安卓系统中似乎没有原生的方式进行任务的线程间同步，资料显示可以通过libuv中uv_async_send实现，因需要添加第三方库，故未尝试。
    Director::getInstance()->runInNextUpdate(
        [=]
        {
            this->invoke(key, argument);
        });
#endif
}

void UtilsSdk::invoke(const std::string& key, const std::string& argument)
{
    auto finder = _callbacks.find(key);
    if (_callbacks.end() != finder)
    {
        SdkCallback& callback = finder->second;
        callback(argument);
        _callbacks.erase(finder);
    }
}
