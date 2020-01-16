//
//  PhotoPicker.m
//  Smart_Pi-mobile
//
//  Created by 朱嘉灵 on 2020/1/14.
//

#include "PhotoPicker.h"
#include "../UtilsSdk.h"
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
using namespace cocos2d;

extern "C"
{
    void Java_org_cocos2dx_javascript_PhotoPicker_response(JNIEnv *env, jobject thiz, long long handle, jstring jFilename)
    {
        cocos2d::log("Java_org_cocos2dx_javascript_PhotoPicker_response");
        PhotoPicker* picker = reinterpret_cast<PhotoPicker*>(handle);
        const char* filename = env->GetStringUTFChars(jFilename, JNI_FALSE);
        picker->response(reinterpret_cast<const char*>(filename));
    }
}

void PhotoPicker::takeOrPickPhoto(const std::string &filename)
{
    _filename = filename;
    this->callActivity("takeOrPickPhoto");
}

void PhotoPicker::takePhoto(const std::string &filename)
{
    _filename = filename;
    this->callActivity("takePhoto");
}

void PhotoPicker::pickPhoto(const std::string &filename)
{
    _filename = filename;
    this->callActivity("pickPhoto");
}

void PhotoPicker::callActivity(const std::string &method)
{
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/javascript/PhotoPicker", "takeOrPickPhoto", "(JLjava/lang/String;Ljava/lang/String;)V")) {
        jlong instance = reinterpret_cast<jlong>(this);
        JNIEnv* env = JniHelper::getEnv();
        jstring jMethod = env->NewStringUTF(method.c_str());
        jstring jFilename = env->NewStringUTF(_filename.c_str());
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, instance, jMethod, jFilename);
        env->DeleteLocalRef(jFilename);
        env->DeleteLocalRef(jMethod);
    }
}

void PhotoPicker::response(const std::string &filename)
{
    UtilsSdk* utils = reinterpret_cast<UtilsSdk*>(_owner);
    utils->callbackToMainThread(_key, filename);
}
