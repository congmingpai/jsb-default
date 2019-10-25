//
//  HashSdk.cpp
//  Smart_Pi
//
//  Created by YUXIAO on 2018/12/25.
//

#include "HashSdk.h"
#include "src/hashlibpp.h"

HashSdk::HashSdk()
: Sdk("HashSdk")
{

}

void HashSdk::call(const std::string &method, const std::string &params, const SdkCallback &callback)
{
    if(method == "getHashFromString") {
        Parameters p(params);
        const std::string type = p.getString("type");
        const std::string text = p.getString("text");
        const std::string hash = getHashFromString(type, text);
        callback(hash);
    }
    else if(method == "getHashFromFile") {
        Parameters p(params);
        const std::string type = p.getString("type");
        const std::string filename = p.getString("filename");
        const std::string hash = getHashFromFile(type, filename);
        callback(hash);
    }
}

std::string HashSdk::getHashFromString(const std::string &type, const std::string &text)
{
    hashwrapper *wrapper = wrapperfactory::create(type);
    if(wrapper) {
        std::string hash = wrapper->getHashFromString(text);
        delete wrapper;
        return hash;
    }
    return std::string();
}

std::string HashSdk::getHashFromFile(const std::string &type, const std::string &filename)
{
    try
    {
        std::string fullpath = cocos2d::FileUtils::getInstance()->fullPathForFilename(filename);
        if(fullpath[0] == '/') {
            hashwrapper *wrapper = wrapperfactory::create(type);
            if(wrapper) {
                std::string hash = wrapper->getHashFromFile(fullpath);
                delete wrapper;
                return hash;
            }
        }
    }
    catch (...)
    {
        //
    }
    return std::string();
}

