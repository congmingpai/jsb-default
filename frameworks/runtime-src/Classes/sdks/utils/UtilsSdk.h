//
//  UtilsSdk.hpp
//  Smart_Pi
//
//  Created by YUXIAO on 2018/7/17.
//

#ifndef UtilsSdk_hpp
#define UtilsSdk_hpp

#include "Sdk.h"

class UtilsSdk : public Sdk {
public:
    UtilsSdk() : Sdk("UtilsSdk") {}

    virtual void call(const std::string &method, const std::string &params, const SdkCallback &callback) override;

    static bool isDebugMode();
    static bool isReleaseMode();

    // memory
    unsigned long long getTotalMemorySize();
    unsigned long long getAvailableMemorySize();

    // file system storage
    unsigned long long getFileSystemTotalSize();
    unsigned long long getFileSystemFreeSize();

    static std::string getUUID();
    static int getSignatureCode();

    enum NetworkType {
        NO_NETWORK = 0,
        WIFI,
        MOBILE,
    };
    static NetworkType getNetworkType();

#ifdef SDK_BUGLY
    static void setBuglyUserID(const std::string& id);
    static void setBuglyUserData(const std::string& params);
#endif
};

#endif /* UtilsSdk_hpp */
