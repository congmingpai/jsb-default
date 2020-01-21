package com.congmingpai.mobile;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.net.Uri;
import android.os.Bundle;
import android.os.StrictMode;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;

import com.congmingpai.mobile.stable.R;

import org.cocos2dx.lib.Cocos2dxHelper;

import java.io.FileInputStream;
import java.io.FileOutputStream;

public class PhotoPicker extends Activity implements View.OnClickListener {
    static final String KEY_METHOD = "method";
    static final String KEY_INSTANCE = "instance";
    static final String KEY_FILENAME = "filename";

    static final String METHOD_TAKE = "takePhoto";
    static final String METHOD_PICK = "pickPhoto";

    static final int PERMISSION_TAKE = 1;
    static final int PERMISSION_PICK = 2;

    static final int REQUEST_TAKE_PHOTO = 1;
    static final int REQUEST_PICK_PHOTO = 2;

    private long mInstance = 0;
    private String mFilename = "";

    private Button mTakeButton = null;
    private Button mCheckButton = null;
    private Button mCancelButton = null;
    private SurfaceView mSurfaceView = null;

    private Camera mCamera = null;
    private PhotoPicker mSelf = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mSelf = this;

        Intent intent = this.getIntent();
        mInstance = intent.getLongExtra(KEY_INSTANCE, 0);
        mFilename = intent.getStringExtra(KEY_FILENAME);
        String method = intent.getStringExtra(KEY_METHOD);
        switch (method) {
            case "takeOrPickPhoto":
                break;
            case METHOD_TAKE:
                if (this.checkCameraPermission()) {
                    this.takePhoto();
                }
                break;
            case METHOD_PICK:
                // 解决7.0 "exposed beyond app through ClipData.Item.getUri"的错误
                StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
                StrictMode.setVmPolicy(builder.build());
                builder.detectFileUriExposure();

                if (this.checkAlbumPermission()){
                    this.pickPhoto();
                }
                break;
        }
    }

    private void initializeContent() {
        Log.d("PhotoPicker", "initializeContent");
        Point screenSize = new Point();
        this.getWindowManager().getDefaultDisplay().getSize(screenSize);

        WindowManager.LayoutParams windowParams = this.getWindow().getAttributes();
        // 锁定宽高比，与游戏内一致
        windowParams.height = screenSize.y;
        windowParams.width = (int)(windowParams.height * 1280.0 / 720);
        // 隐藏下方导航栏，全屏显示
        windowParams.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE; // SYSTEM_UI_FLAG_IMMERSIVE为沉浸式体验，点击也不显示导航栏

        this.setContentView(R.layout.activity_photopicker);

        mTakeButton = (Button)this.findViewById(R.id.photo_button_take_photo);
        mTakeButton.setOnClickListener(this);
        mTakeButton.setVisibility(View.INVISIBLE);
        mCheckButton = (Button)this.findViewById(R.id.photo_button_check);
        mCheckButton.setVisibility(View.INVISIBLE);
        mCheckButton.setOnClickListener(this);
        mCancelButton = (Button)this.findViewById(R.id.photo_button_cancel);
        mCancelButton.setVisibility(View.INVISIBLE);
        mCancelButton.setOnClickListener(this);

        Log.d("PhotoPicker", "initialize surface view");
        mSurfaceView = (SurfaceView)this.findViewById(R.id.photo_surface_view);
        SurfaceHolder holder = mSurfaceView.getHolder();
        holder.setKeepScreenOn(true);
        holder.addCallback(mSurfaceHolderCallback);
//        holder.lockCanvas();
    }

    private Camera.Callback mCameraCallback = new Camera.Callback() {
        @Override
        public void response(Bitmap bitmap) {
            if (null == bitmap) {
                // 理论上的拍照失败
                mTakeButton.setVisibility(View.VISIBLE);
            }
            else {
                mCheckButton.setVisibility(View.VISIBLE);
                mCancelButton.setVisibility(View.VISIBLE);
            }
        }
    };

    private SurfaceHolder.Callback mSurfaceHolderCallback = new SurfaceHolder.Callback() {
        @Override
        public void surfaceCreated(SurfaceHolder holder) {
            Log.d("PhotoPicker", "surface view created");
            mTakeButton.setVisibility(View.VISIBLE);

            mCamera = new Camera(mSelf, holder, mCameraCallback);
            mCamera.open();
        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {

        }
    };

    private void initializeCamera() {

    }

    @Override
    public void onClick(final View v) {
        if (v == mTakeButton && null != mCamera) {
            if (mCamera.capture()) {
                mTakeButton.setVisibility(View.INVISIBLE);
            }
            else {
                this.response("");
            }
        }
        if (v == mCancelButton && null != mCamera) {
            mCamera.open();
            mTakeButton.setVisibility(View.VISIBLE);
            mCheckButton.setVisibility(View.INVISIBLE);
            mCancelButton.setVisibility(View.INVISIBLE);
        }
        if (v == mCheckButton && null != mCamera) {
            try {
                Bitmap bitmap = mCamera.getResult();
                FileOutputStream outStream = new FileOutputStream(mFilename, false);
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outStream);
                outStream.close();
                mSelf.response(mFilename);
            } catch (Exception e) {
                e.printStackTrace();
                mSelf.response("");
            }
        }
    }

    private boolean checkCameraPermission() {
        // TODO: 也许可以使用this.getApplicationContext()替代？
        int oldStatus = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        if (PackageManager.PERMISSION_GRANTED == oldStatus) {
            return true;
        }
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, PERMISSION_TAKE);
        return false;
    }

    private void takePhoto() {
        this.initializeContent();
        this.initializeCamera();
    }

    private boolean checkAlbumPermission() {
        int oldStatus = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE);
        if (PackageManager.PERMISSION_GRANTED == oldStatus) {
            return true;
        }
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, PERMISSION_PICK);
        return false;
    }

    private void pickPhoto(){
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        this.startActivityForResult(intent, REQUEST_PICK_PHOTO);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        for (int i = 0; i < permissions.length; ++i) {
            switch (requestCode) {
                case PERMISSION_TAKE:
                    this.takePhoto();
                    break;
                case PERMISSION_PICK:
                    this.pickPhoto();
                    break;
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case REQUEST_TAKE_PHOTO:
                this.response(RESULT_OK == resultCode ? mFilename : "");
                break;
            case REQUEST_PICK_PHOTO:
                if (RESULT_OK == resultCode) {
                    Uri uri = data.getData();
                    try {
                        String filename = PathUtils.getRealPathFromUri(this, uri);
                        FileInputStream inStream = new FileInputStream(filename);
                        FileOutputStream outStream = new FileOutputStream(mFilename, false);
                        byte[] buffer = new byte[inStream.available()];
                        inStream.read(buffer);
                        outStream.write(buffer);
                        outStream.close();
                        inStream.close();

                        this.response(mFilename);
                        return;
                    }
                    catch(Exception e){
                        e.printStackTrace();
                    }
                }
                this.response("");
                break;
        }
    }

    private void response(String filename) {
        PhotoPicker.response(mInstance, mFilename);
        this.finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        this.response("");
    }

    static public void takeOrPickPhoto(long instance, String method, String filename) {
        Activity current = Cocos2dxHelper.getActivity();
        Intent intent = new Intent(current, PhotoPicker.class);
        intent.putExtra(KEY_INSTANCE, instance);
        intent.putExtra(KEY_METHOD, method);
        intent.putExtra(KEY_FILENAME, filename);
        current.startActivity(intent);
    }

    static native void response(long instance, String filename);
}