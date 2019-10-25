LOCAL_PATH := $(call my-dir)

# --- 引用 libBugly.so ---
include $(CLEAR_VARS)
LOCAL_MODULE := bugly_native_prebuilt
LOCAL_SRC_FILES := Bugly/BuglySDK/Android/libs/$(TARGET_ARCH_ABI)/libBugly.so
include $(PREBUILT_SHARED_LIBRARY)
# --- end ---

include $(CLEAR_VARS)

LOCAL_MODULE := game_sdk_static

LOCAL_MODULE_FILENAME := libgamesdk

LOCAL_SRC_FILES := SdkManager.cpp \
                   Sdk.cpp \
                   utils/UtilsSdk.mm \
                   Bugly/BuglySdk.cpp \
                   wechat/WechatSdk.mm \
                   hash/HashSdk.cpp \

LOCAL_CPP_EXTENSION := .mm .cpp .cc

LOCAL_CFLAGS := -DCOCOS2D_JAVASCRIPT
LOCAL_CFLAGS += -x c++

LOCAL_EXPORT_CFLAGS := -DCOCOS2D_JAVASCRIPT

LOCAL_C_INCLUDES := $(LOCAL_PATH)

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)

LOCAL_STATIC_LIBRARIES := cocos2dx_static
LOCAL_STATIC_LIBRARIES += bugly_crashreport_cocos_static
LOCAL_STATIC_LIBRARIES += hashlib2plus_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module, sdks/Bugly/CocosPlugin/bugly)
$(call import-module, sdks/hash/src)
