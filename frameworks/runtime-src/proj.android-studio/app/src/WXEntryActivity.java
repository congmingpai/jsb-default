package com.congmingpai.mobile.wxapi;

import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import org.cocos2dx.javascript.WechatSdk;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //注意：
        // 第三方开发者如果使用透明界面来实现WXEntryActivity，
        // 需要判断handleIntent的返回值，如果返回值为false，
        // 则说明入参不合法未被SDK处理，应finish当前透明界面，
        // 避免外部通过传递非法参数的Intent导致停留在透明界面，引起用户的疑惑
        try {
            boolean ret = WechatSdk.handleIntent(getIntent(), this);
            Log.d("WechatSdk", String.format("handleIntent: %b", ret));
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        WechatSdk.handleIntent(intent, this);
    }

    // 微信发送请求到第三方应用时，会回调到该方法
    @Override
    public void onReq(BaseReq req) {
        WechatSdk.onReq(req);
        this.finish();
    }

    // 第三方应用发送到微信的请求处理后的响应结果，会回调到该方法
    @Override
    public void onResp(BaseResp resp) {
        WechatSdk.onResp(resp);
        this.finish();
    }
}