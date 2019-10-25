LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := hashlib2plus_static

LOCAL_MODULE_FILENAME := libhl++

LOCAL_CPP_EXTENSION := .mm .cpp .cc
LOCAL_CFLAGS += -x c++
LOCAL_CPPFLAGS += -fexceptions

LOCAL_SRC_FILES := hl_md5.cpp \
                   hl_md5wrapper.cpp \
                   hl_sha1.cpp \
                   hl_sha1wrapper.cpp \
                   hl_sha2ext.cpp \
                   hl_sha256.cpp \
                   hl_sha256wrapper.cpp \
                   hl_sha384wrapper.cpp \
                   hl_sha512wrapper.cpp \
                   hl_wrapperfactory.cpp \

LOCAL_C_INCLUDES := $(LOCAL_PATH)

include $(BUILD_STATIC_LIBRARY)

