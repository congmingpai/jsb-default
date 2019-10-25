package org.cocos2dx.javascript;

import android.util.Log;
import android.content.Intent;

import org.cocos2dx.javascript.SdkManager;

import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.constants.ConstantsAPI;

public class WechatSdk {
    public static IWXAPI api = null;

    public static void registerApp(String appid) {
        Log.d("WechatSDK", String.format("registerApp: %s", appid));
        api = WXAPIFactory.createWXAPI(SdkManager.activity, appid, true);
        api.registerApp(appid);
    }

    public static void sendText(String text, int scene) {
        Log.d("WechatSDK", String.format("sendText, text: %s, scene: %d", text, scene));

        WXMediaMessage msg = new WXMediaMessage();
        msg.description = text;

        WXTextObject textObj = new WXTextObject();
        textObj.text = text;
        msg.mediaObject = textObj;

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = buildTransaction("text");
        req.message = msg;
        req.scene = scene;
        api.sendReq(req);
    }

    public static void sendWebpage(String url, String title, String description, String thumb, int scene) {
        Log.d("WechatSDK", String.format("sendWebpage, url: %s, title: %s, description: %s, thumb: %s, scene: %d", url, title, description, thumb, scene));

        WXMediaMessage msg = new WXMediaMessage();
        msg.title = title;
        msg.description = description;

        WXWebpageObject webpage = new WXWebpageObject();
        webpage.webpageUrl = url;
        msg.mediaObject = webpage;

        // Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.drawable.send_music_thumb);
        // Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
        // bmp.recycle();
        // msg.thumbData = Util.bmpToByteArray(thumbBmp, true);

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = buildTransaction("webpage");
        req.message = msg;
        req.scene = scene;
        api.sendReq(req);
    }

    public static void sendAuth() {
        Log.d("WechatSDK", "sendAuth");

        SdkManager.activity.runOnUiThread(new Runnable() {
          public void run() {
            SendAuth.Req req = new SendAuth.Req();
            req.scope = "snsapi_userinfo";
            api.sendReq(req);
          }
        });
    }

    private static String buildTransaction(final String type) {
        return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
    }

    public static boolean isWXAppInstalled() {
        Log.d("WechatSDK", "isWXAppInstalled");
        return api.isWXAppInstalled();
    }

    public static boolean handleIntent(Intent intent, IWXAPIEventHandler handle) {
        Log.d("WechatSDK", "handleIntent");
        return api.handleIntent(intent, handle);
    }

    public static void onReq(BaseReq req) {
        Log.d("WechatSDK", "onReq: " + req.getType());

        switch (req.getType()) {
            case ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX:
                Log.d("WechatSDK", "onReq ERR_OK");
                break;
            case ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX:
                Log.d("WechatSDK", "onReq ERR_OK");
                break;
            default:
                break;
        }
    }

    public static void onResp(BaseResp resp) {
        Log.d("WechatSDK", String.format("onResp, type: %d, code: %d", resp.getType(), resp.errCode));

        switch (resp.getType()) {
            case ConstantsAPI.COMMAND_SENDAUTH:
                SendAuth.Resp r = (SendAuth.Resp)resp;
                Log.d("WechatSDK", "onResp resp.code: " + r.code);
                Log.d("WechatSDK", "onResp resp.state: " + r.state);
                Log.d("WechatSDK", "onResp resp.url: " + r.url);
                Log.d("WechatSDK", "onResp resp.lang: " + r.lang);
                Log.d("WechatSDK", "onResp resp.country: " + r.country);
                managerDidRecvAuthResponse(r.errCode, r.code);
                break;

            case ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX:
                break;
        }
    }

    public static native void managerDidRecvAuthResponse(int err, String code);
}
