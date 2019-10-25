LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := game_jsb_static

LOCAL_MODULE_FILENAME := libgamejsb

LOCAL_SRC_FILES := jsb_custom_auto.cpp

LOCAL_CPP_EXTENSION := .cpp .cc

LOCAL_CFLAGS := -DCOCOS2D_JAVASCRIPT
LOCAL_CFLAGS += -x c++

LOCAL_EXPORT_CFLAGS := -DCOCOS2D_JAVASCRIPT

LOCAL_C_INCLUDES := $(LOCAL_PATH) \
                    $(LOCAL_PATH)/.. \
                    $(LOCAL_PATH)/../../../cocos2d-x \
                    $(LOCAL_PATH)/../../../cocos2d-x/cocos \
                    $(LOCAL_PATH)/../../../cocos2d-x/extensions

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH) \
                           $(LOCAL_PATH)/.. \

LOCAL_STATIC_LIBRARIES := cocos2dx_static
LOCAL_STATIC_LIBRARIES += v8_static

include $(BUILD_STATIC_LIBRARY)
