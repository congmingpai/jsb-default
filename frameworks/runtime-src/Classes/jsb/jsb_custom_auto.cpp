#include "jsb_custom_auto.hpp"
#include "scripting/js-bindings/manual/jsb_conversions.hpp"
#include "scripting/js-bindings/manual/jsb_global.h"
#include "jsb.h"

se::Object* __jsb_SdkManager_proto = nullptr;
se::Class* __jsb_SdkManager_class = nullptr;

static bool js_jsb_custom_auto_SdkManager_call(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 4) {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::function<void (const std::basic_string<char> &)> arg3;
        ok &= seval_to_std_string(args[0], &arg0);
        ok &= seval_to_std_string(args[1], &arg1);
        ok &= seval_to_std_string(args[2], &arg2);
        do {
            if (args[3].isObject() && args[3].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[3]);
                jsFunc.toObject()->root();
                auto lambda = [=](const std::basic_string<char> & larg0) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(1);
                    ok &= std_string_to_seval(larg0, &args[0]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg3 = lambda;
            }
            else
            {
                arg3 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_jsb_custom_auto_SdkManager_call : Error processing arguments");
        SdkManager::call(arg0, arg1, arg2, arg3);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 4);
    return false;
}
SE_BIND_FUNC(js_jsb_custom_auto_SdkManager_call)



static bool js_SdkManager_finalize(se::State& s)
{
    CCLOGINFO("jsbindings: finalizing JS object %p (SdkManager)", s.nativeThisObject());
    auto iter = se::NonRefNativePtrCreatedByCtorMap::find(s.nativeThisObject());
    if (iter != se::NonRefNativePtrCreatedByCtorMap::end())
    {
        se::NonRefNativePtrCreatedByCtorMap::erase(iter);
        SdkManager* cobj = (SdkManager*)s.nativeThisObject();
        delete cobj;
    }
    return true;
}
SE_BIND_FINALIZE_FUNC(js_SdkManager_finalize)

bool js_register_jsb_custom_auto_SdkManager(se::Object* obj)
{
    auto cls = se::Class::create("SdkManager", obj, nullptr, nullptr);

    cls->defineStaticFunction("call", _SE(js_jsb_custom_auto_SdkManager_call));
    cls->defineFinalizeFunction(_SE(js_SdkManager_finalize));
    cls->install();
    JSBClassType::registerClass<SdkManager>(cls);

    __jsb_SdkManager_proto = cls->getProto();
    __jsb_SdkManager_class = cls;

    se::ScriptEngine::getInstance()->clearException();
    return true;
}

bool register_all_jsb_custom_auto(se::Object* obj)
{
    // Get the ns
    se::Value nsVal;
    if (!obj->getProperty("jsb", &nsVal))
    {
        se::HandleObject jsobj(se::Object::createPlainObject());
        nsVal.setObject(jsobj);
        obj->setProperty("jsb", nsVal);
    }
    se::Object* ns = nsVal.toObject();

    js_register_jsb_custom_auto_SdkManager(ns);
    return true;
}

