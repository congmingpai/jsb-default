//
//  ReachabilitySdk.cpp
//  Smart_Pi-mobile
//
//  Created by YUXIAO on 2018/7/13.
//

#include "ReachabilitySdk.h"
#include "json/document.h"
#include "json/rapidjson.h"
#include "json/filestream.h"
#include "json/prettywriter.h"
#include "json/stringbuffer.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "Reachability.h"
#endif

USING_NS_CC;

void ReachabilitySdk::call(const std::string &method, const std::string &params, const SdkCallback &callback)
{
    if(method == "setReachabilityForInternetConnection") {
        setReachabilityForInternetConnection(callback);
    }
    else if(method == "setReachabilityWithHostName") {
        setReachabilityWithHostName(params, callback);
    }
    else if(method == "refreshReachabilityStatus") {
        refreshReachabilityStatus(params);
    }
}

void ReachabilitySdk::init()
{
    EventDispatcher *dispatcher = Director::getInstance()->getEventDispatcher();
    dispatcher->addEventListenerWithFixedPriority(EventListenerCustom::create("onReachabilityChanged", [=](EventCustom* event) {
        Reachability *reachability = (Reachability *)event->getUserData();
        std::map<void*, std::string>::iterator found = _reachability2name.find((void*)reachability);
        if(found != _reachability2name.end()) {
            std::string &name = found->second;
            refreshReachabilityStatus(name);
        }
    }), 1);
}

void ReachabilitySdk::setReachabilityForInternetConnection(const SdkCallback &callback)
{
    if(callback) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        addReachability("ReachabilityForInternetConnection", reachability, callback);
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onReachabilityChanged", (void*)reachability);
    }
    else {
        removeReachability("ReachabilityForInternetConnection");
    }
}

void ReachabilitySdk::setReachabilityWithHostName(const std::string &hostName, const SdkCallback &callback)
{
    if(callback) {
        NSString *hostName_ = [NSString stringWithUTF8String:hostName.c_str()];
        Reachability *reachability = [Reachability reachabilityWithHostName: hostName_];
        [reachability startNotifier];
        addReachability(hostName, reachability, callback);
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onReachabilityChanged", (void*)reachability);
    }
    else {
        removeReachability(hostName);
    }
}

void ReachabilitySdk::refreshReachabilityStatus(const std::string &name)
{
    std::map<std::string, ReachabilityState>::iterator found = _reachabilities.find(name);
    if(found != _reachabilities.end()) {
        const ReachabilityState &state = (ReachabilityState)found->second;
        Reachability *reachability = (Reachability *)state.reachability;
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        // make json string
        rapidjson::Document json;
        json.Parse<0>("{}");
        
        // reachability name
        rapidjson::Value jNameKey("name", json.GetAllocator());
        rapidjson::Value jNameValue(state.name.c_str(), json.GetAllocator());
        json.AddMember(jNameKey, jNameValue, json.GetAllocator());
        
        // reachability status
        rapidjson::Value jStatusKey("status", json.GetAllocator());
        rapidjson::Value jStatusValue((int)netStatus);
        json.AddMember(jStatusKey, jStatusValue, json.GetAllocator());
        
        // serialization
        rapidjson::StringBuffer buffer;
        rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
        json.Accept(writer);
        
        // callback
        if(state.callback) {
            state.callback(buffer.GetString());
        }
    }
}

void ReachabilitySdk::addReachability(const std::string &name, void *reachability, const SdkCallback &callback)
{
    ReachabilityState state;
    state.name = name;
    state.reachability = reachability;
    state.callback = callback;
    _reachabilities.insert(std::make_pair(name, state));
    _reachability2name.insert(std::make_pair(reachability, name));
}

void ReachabilitySdk::removeReachability(const std::string &name)
{
    std::map<std::string, ReachabilityState>::iterator found = _reachabilities.find(name);
    if(found != _reachabilities.end()) {
        const ReachabilityState &state = (ReachabilityState)found->second;
        _reachability2name.erase(state.reachability);
        [(Reachability *)state.reachability release];
        _reachabilities.erase(name);
    }
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
@interface ReachabilityListener : NSObject
+ (ReachabilityListener*)getInstance;
@end
@implementation ReachabilityListener
+ (ReachabilityListener*)getInstance {
    static ReachabilityListener *instance = NULL;
    if(instance == NULL) {
        instance = [[ReachabilityListener alloc] init];
    }
    return instance;
}
- (void) onReachabilityChanged:(NSNotification *)note {
    Reachability* reachability = [note object];
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("onReachabilityChanged", (void*)reachability);
}
@end
void ReachabilitySdk::applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary)
{
    [[NSNotificationCenter defaultCenter] addObserver:[ReachabilityListener getInstance]
                                             selector:@selector(onReachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    init();
}
#endif
