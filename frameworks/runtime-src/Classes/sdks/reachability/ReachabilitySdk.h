//
//  ReachabilitySdk.hpp
//  Smart_Pi-mobile
//
//  Created by YUXIAO on 2018/7/13.
//

#ifndef ReachabilitySdk_hpp
#define ReachabilitySdk_hpp

#include "Sdk.h"

class ReachabilitySdk : public Sdk {
    struct ReachabilityState {
        std::string name;
        void *reachability;
        SdkCallback callback;
    };
    
public:
    ReachabilitySdk() : Sdk("ReachabilitySdk") {}
    
    virtual void call(const std::string &method, const std::string &params, const SdkCallback &callback) override;
    
    void init();
    
    void setReachabilityForInternetConnection(const SdkCallback &callback);
    void setReachabilityWithHostName(const std::string &hostName, const SdkCallback &callback);
    void refreshReachabilityStatus(const std::string &name);
    
private:
    void addReachability(const std::string &name, void *reachability, const SdkCallback &callback);
    void removeReachability(const std::string &name);
    
    std::map<std::string, ReachabilityState> _reachabilities;
    std::map<void*, std::string> _reachability2name;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
public:
    virtual void applicationDidFinishLaunching(void *iosUIApplication, void *iosNSDictionary) override;
#endif
};

#endif /* ReachabilitySdk_hpp */
