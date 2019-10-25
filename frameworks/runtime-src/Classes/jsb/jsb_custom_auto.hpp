#pragma once
#include "base/ccConfig.h"

#include "cocos/scripting/js-bindings/jswrapper/SeApi.h"

extern se::Object* __jsb_SdkManager_proto;
extern se::Class* __jsb_SdkManager_class;

bool js_register_SdkManager(se::Object* obj);
bool register_all_jsb_custom_auto(se::Object* obj);
SE_DECLARE_FUNC(js_jsb_custom_auto_SdkManager_call);

