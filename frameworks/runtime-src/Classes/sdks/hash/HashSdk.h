//
//  HashSdk.hpp
//  Smart_Pi
//
//  Created by YUXIAO on 2018/12/25.
//

#ifndef HashSdk_hpp
#define HashSdk_hpp

#include "Sdk.h"

class HashSdk : public Sdk
{
public:
    HashSdk();
    virtual void call(const std::string &method, const std::string &params, const SdkCallback &callback) override;
    
    std::string getHashFromString(const std::string &type, const std::string &text);
    std::string getHashFromFile(const std::string &type, const std::string &filename);
};


#endif /* HashSdk_hpp */
