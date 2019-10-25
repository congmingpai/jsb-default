//
//  WechatSdk.m
//  Smart_Pi-mobile
//
//  Created by YUXIAO on 2018/6/12.
//

#include "WechatSdk.h"
#include "SdkManager.h"
#include "network/HttpClient.h"
#include "json/document-wrapper.h"
#include "json/stringbuffer.h"
#include "json/prettywriter.h"
#include "utils/UtilsSdk.h"
#include "openssl/sha.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "WXApi.h"
#import "Control/WXApiManager.h"
#import "Control/WXApiRequestHandler.h"
#import "Control/WXApiResponseHandler.h"
#import "WechatAuthSDK.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include "platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <jni.h>
#define CLASS_NAME "org/cocos2dx/javascript/WechatSdk"
#endif

USING_NS_CC;


WechatSdk::WechatSdk()
: Sdk("WechatSdk")
{
    _appID = "wxaef50a4b91ce02ec";
    _appSecret = "36285e163d4a5d1a1ced5ecd98044809";
}

void WechatSdk::call(const std::string &method, const std::string &params, const SdkCallback &callback)
{
    if(method == "login") {
        login(callback);
    }
    else if(method == "loginWithQrcode") {
        loginWithQrcode(callback);
    }
    else if(method == "isWXAppInstalled") {
        bool ret = isWXAppInstalled();
        callback(ret ? "true" : "false");
    }
    else if(method == "getWXAppInstallUrl") {
        std::string url = getWXAppInstallUrl();
        callback(url);
    }
}

void WechatSdk::login(const Sdk::SdkCallback &callback)
{
    EventDispatcher *dispatcher = Director::getInstance()->getEventDispatcher();
    
    // do auth
    dispatcher->removeCustomEventListeners("onAuthResp");
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("onAuthResp", [=](EventCustom* event) {
        const char *code = (const char *)event->getUserData();
        callback(code ? code : "");
    }), 1);

    // send auth request
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [WXApiRequestHandler sendAuthRequestScope:@"snsapi_userinfo"
                                        State:nil
                                       OpenID:[NSString stringWithUTF8String:_appID.c_str()]
                             InViewController:(UIViewController*)SdkManager::viewController];
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniHelper::callStaticVoidMethod(CLASS_NAME, "sendAuth");
#endif
}

void WechatSdk::loginWithQrcode(const Sdk::SdkCallback &callback)
{
    EventDispatcher *dispatcher = Director::getInstance()->getEventDispatcher();
    
    dispatcher->removeCustomEventListeners("getWxAccessToken");
    dispatcher->removeCustomEventListeners("getWxTicket");
    dispatcher->removeCustomEventListeners("onAuthGotQrcode");
    dispatcher->removeCustomEventListeners("onQrcodeScanned");
    dispatcher->removeCustomEventListeners("onAuthFinish");
    std::function<void(int code, const std::string &result)> complete = [=](int code, const std::string &result) {
        rapidjson::Document json;
        rapidjson::Document::AllocatorType& allocator = json.GetAllocator();
        
        json.SetObject();
        json.AddMember("code", rapidjson::Value(code), allocator);
        json.AddMember("msg", rapidjson::Value(result.c_str(), allocator), allocator);
        
        rapidjson::StringBuffer buffer;
        rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
        json.Accept(writer);
        
        callback(buffer.GetString());
    };
    // get access token
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("getWxAccessToken", [=](EventCustom* event) {
        CCLOG("WechatSDK::loginWithQrcode dispatcher getWxAccessToken");
        const char *token = (const char *)event->getUserData();
        if(token)
            getWxTicket(token);
        else
            complete(-1, "Get Wechat Access Token Error");
    }), 1);
    // get ticket
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("getWxTicket", [=](EventCustom* event) {
        CCLOG("WechatSDK::loginWithQrcode dispatcher getWxTicket");
        const char *ticket = (const char *)event->getUserData();
        if(ticket)
            doWxQrcodeAuth(ticket);
        else
            complete(-2, "Get Wechat Ticket Error");
    }), 1);
    // qrcode auth
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("onAuthGotQrcode", [=](EventCustom* event) {
        const char *imagePath = (const char *)event->getUserData();
        complete(1, imagePath);
    }), 1);
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("onQrcodeScanned", [=](EventCustom* event) {
        complete(2, "onQrcodeScanned");
    }), 1);
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("onAuthFinish", [=](EventCustom* event) {
        const char *code = (const char *)event->getUserData();
        if(code)
            complete(0, code);
        else
            complete(-3, "Qrcode Auth Error");
    }), 1);
    
    getWxAccessToken();
}

bool WechatSdk::isWXAppInstalled()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return [WXApi isWXAppInstalled];
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    return JniHelper::callStaticBooleanMethod(CLASS_NAME, "isWXAppInstalled");
#endif
    return false;
}

std::string WechatSdk::getWXAppInstallUrl()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSString *url = [WXApi getWXAppInstallUrl];
    return [url UTF8String];
#endif
    return std::string();
}

void WechatSdk::getWxAccessToken()
{
    char url[1024];
    snprintf(url, sizeof(url), "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s", _appID.c_str(), _appSecret.c_str());
    
    network::HttpRequest* request = new (std::nothrow) network::HttpRequest();
    request->setUrl(url);
    request->setRequestType(network::HttpRequest::Type::GET);
    request->setResponseCallback([=](network::HttpClient* client, network::HttpResponse* response) {
        std::vector<char>* data = response->getResponseData();
        std::string resp(data->begin(), data->end());
        CCLOG("WechatSDK::getWxAccessToken HttpRequest response: %s", resp.c_str());
        
        rapidjson::Document json;
        if(json.Parse<0>(resp.c_str()).HasParseError()) {
            CCLOG("response parse error");
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxAccessToken");
            return;
        }
        
        if(json.HasMember("access_token") && json["access_token"].IsString()) {
            std::string token = json["access_token"].GetString();
            CCLOG("access_token: %s", token.c_str());
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxAccessToken", (void*)token.c_str());
        }
        else {
            CCLOG("response has no access token");
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxAccessToken");
        }
    });
    network::HttpClient::getInstance()->send(request);
    request->release();
}

void WechatSdk::getWxTicket(const std::string &token)
{
    char url[1024];
    snprintf(url, sizeof(url), "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=%s&type=2", token.c_str());
    
    network::HttpRequest* request = new (std::nothrow) network::HttpRequest();
    request->setUrl(url);
    request->setRequestType(network::HttpRequest::Type::GET);
    request->setResponseCallback([=](network::HttpClient* client, network::HttpResponse* response) {
        std::vector<char>* data = response->getResponseData();
        std::string resp(data->begin(), data->end());
        CCLOG("WechatSDK::getWxTicket HttpRequest response: %s", resp.c_str());
        
        rapidjson::Document json;
        if(json.Parse<0>(resp.c_str()).HasParseError()) {
            CCLOG("response parse error");
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxTicket");
            return;
        }
        if(json.HasMember("errcode") && json["errcode"].IsInt() && json["errcode"].GetInt() != 0) {
            if(json.HasMember("errmsg") && json["errmsg"].IsString()) {
                const char *msg = json["errmsg"].GetString();
                CCLOG("%s", msg);
            }
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxTicket");
            return;
        }
        
        if(json.HasMember("ticket") && json["ticket"].IsString()) {
            std::string ticket = json["ticket"].GetString();
            CCLOG("ticket: %s", ticket.c_str());
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxTicket", (void*)ticket.c_str());
        }
        else {
            CCLOG("response has no ticket");
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("getWxTicket");
        }
        
    });
    network::HttpClient::getInstance()->send(request);
    request->release();
}

void WechatSdk::doWxQrcodeAuth(const std::string &ticket)
{
    std::string noncestr = UtilsSdk::getUUID();
    std::time_t timestamp = std::time(nullptr);
    std::string signature = genWxSignature(ticket, noncestr, timestamp);
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    WechatAuthSDK *sdk = (WechatAuthSDK*)_wechatAuthSDK;
    [sdk StopAuth];
    [sdk Auth: [NSString stringWithUTF8String:_appID.c_str()]
     nonceStr: [NSString stringWithUTF8String:noncestr.c_str()]
    timeStamp: [NSString stringWithFormat:@"%ld", timestamp]
        scope: @"snsapi_userinfo"
    signature: [NSString stringWithUTF8String:signature.c_str()]
   schemeData: [NSString stringWithUTF8String:_appID.c_str()]];
#endif
}

std::string WechatSdk::genWxSignature(const std::string &ticket, const std::string &noncestr, const std::time_t &timestamp)
{
    char buf1[1024];
    snprintf(buf1, sizeof(buf1), "appid=%s&noncestr=%s&sdk_ticket=%s&timestamp=%ld", _appID.c_str(), noncestr.c_str(), ticket.c_str(), timestamp);
    
    unsigned char buf2[SHA_DIGEST_LENGTH];
    SHA1((const unsigned char *)buf1, strlen(buf1), buf2);
    
    char buf3[10];
    std::string signature;
    for (int i = 0; i < SHA_DIGEST_LENGTH; i++) {
        snprintf(buf3, sizeof(buf3), "%02x", buf2[i]);
        signature.append(buf3);
    }
    
    CCLOG("signature: %s", signature.c_str());
    return signature;
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
@interface WXApiHandler : NSObject <WXApiManagerDelegate>
+ (instancetype)getInstance;
@end
@implementation WXApiHandler
+ (instancetype)getInstance {
    static WXApiHandler *instance = nil;
    if(instance == nil)
        instance = [[WXApiHandler alloc] init];
    return instance;
}
- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request {}
- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request {}
- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request {}
- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {}
- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    if(response.errCode == 0) {
        NSString *code = response.code;
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthResp", (void*)[code UTF8String]);
    }
    else {
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthResp");
    }
}
- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response {}
- (void)managerDidRecvChooseCardResponse:(WXChooseCardResp *)response {}
- (void)managerDidRecvChooseInvoiceResponse:(WXChooseInvoiceResp *)response {}
- (void)managerDidRecvSubscribeMsgResponse:(WXSubscribeMsgResp *)response {}
- (void)managerDidRecvLaunchMiniProgram:(WXLaunchMiniProgramResp *)response {}
@end


@interface WXAuthAPIDelegate : NSObject <WechatAuthAPIDelegate>
+ (instancetype)getInstance;
@end
@implementation WXAuthAPIDelegate
+ (instancetype)getInstance {
    static WXAuthAPIDelegate *instance = nil;
    if(instance == nil)
        instance = [[WXAuthAPIDelegate alloc] init];
    return instance;
}
- (void)onAuthGotQrcode:(UIImage *)image {
    std::string imageName = UtilsSdk::getUUID() + ".png";
    std::string imagePath =  FileUtils::getInstance()->getWritablePath() += "WxQrcode/" + imageName;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:[NSString stringWithUTF8String:imagePath.c_str()] atomically:NO];
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthGotQrcode", (void*)imagePath.c_str());
}
- (void)onQrcodeScanned {
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onQrcodeScanned");
}
- (void)onAuthFinish:(int)errCode AuthCode:(NSString *)authCode {
    if(errCode == 0) {
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthFinish", (void*)[authCode UTF8String]);
    }
    else {
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthFinish");
    }
}
@end

void WechatSdk::applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary)
{
    [WXApi registerApp:[NSString stringWithUTF8String:_appID.c_str()]];
    [WXApiManager sharedManager].delegate = [WXApiHandler getInstance];
    
    WechatAuthSDK *sdk = [[WechatAuthSDK alloc] init];
    sdk.delegate = [WXAuthAPIDelegate getInstance];
    _wechatAuthSDK = (void*)sdk;
    
    // clear qrcode cache
    FileUtils *fileutils = FileUtils::getInstance();
    std::string path = fileutils->getWritablePath() + "WxQrcode";
    if(fileutils->isDirectoryExist(path)) {
        fileutils->removeDirectory(path);
    }
    fileutils->createDirectory(path);
}

bool WechatSdk::applicationOpenURL(void *iosUIApplication, void *iosNSURL, void *iosNSDictionary)
{
    NSURL *url = (NSURL*)iosNSURL;
    [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    return true;
}
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void WechatSdk::activityOnCreate() {
    cocos2d::log("WechatSdk::activityOnCreate");
    JniHelper::callStaticVoidMethod(CLASS_NAME, "registerApp", _appID);
}
extern "C" {
    JNIEXPORT void JNICALL Java_org_cocos2dx_javascript_WechatSdk_managerDidRecvAuthResponse(JNIEnv *env, jobject thiz, int err, jstring jcode) {
        cocos2d::log("Java_org_cocos2dx_javascript_WechatSdk_managerDidRecvAuthResponse");
        if(err == 0) {
            std::string code = JniHelper::jstring2string(jcode);
            Director::getInstance()->getScheduler()->performFunctionInCocosThread([=] {
                Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthResp", (void*)code.c_str());
            });
        }
        else {
            Director::getInstance()->getScheduler()->performFunctionInCocosThread([=] {
                Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onAuthResp");
            });
        }
    }
}
#endif
