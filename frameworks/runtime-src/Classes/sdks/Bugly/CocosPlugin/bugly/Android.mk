LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := bugly_crashreport_cocos_static

LOCAL_MODULE_FILENAME := libcrashreport

LOCAL_CPP_EXTENSION := .mm .cpp .cc
LOCAL_CFLAGS += -x c++

LOCAL_SRC_FILES := CrashReport.mm 

LOCAL_C_INCLUDES := $(LOCAL_PATH)\
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos \
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos/base \
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos/2d \
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos/2d/platform/android \
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos/platform/android \
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos/math/kazmath \
$(LOCAL_PATH)/../../../../../../cocos2d-x/cocos/physics \
$(LOCAL_PATH)/../../../../../../cocos2d-x/external

include $(BUILD_STATIC_LIBRARY)