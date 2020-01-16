package org.cocos2dx.javascript;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.StrictMode;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.FileProvider;

import org.cocos2dx.lib.Cocos2dxHelper;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class PhotoPicker extends Activity {
    static final String KEY_METHOD = "method";
    static final String KEY_INSTANCE = "instance";
    static final String KEY_FILENAME = "filename";

    static final int PERMISSION_TAKE = 1;
    static final int PERMISSION_PICK = 2;

    static final int REQUEST_TAKE_PHOTO = 1;
    static final int REQUEST_PICK_PHOTO = 2;

    private long mInstance = 0;
    private String mFilename = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 解决7.0 "exposed beyond app through ClipData.Item.getUri"的错误
        StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
        StrictMode.setVmPolicy(builder.build());
        builder.detectFileUriExposure();

        Intent intent = this.getIntent();
        boolean needCheckPermission = Build.VERSION.SDK_INT >= 23;
        mInstance = intent.getLongExtra(KEY_INSTANCE, 0);
        mFilename = intent.getStringExtra(KEY_FILENAME);
        String method = intent.getStringExtra(KEY_METHOD);
        switch (method) {
            case "takeOrPickPhoto":
                break;
            case "takePhoto":
                if (!needCheckPermission || this.checkCameraPermission()) {
                    this.takePhoto();
                }
                break;
            case "pickPhoto":
                if (!needCheckPermission || this.checkAlbumPermission()){
                    this.pickPhoto();
                }
                break;
        }
    }

    private boolean checkCameraPermission() {
        int oldStatus = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        if (PackageManager.PERMISSION_GRANTED == oldStatus) {
            return true;
        }
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, PERMISSION_TAKE);
        return false;
    }

    private void takePhoto() {
        File file = new File(mFilename);
        if (file.exists()) {
            file.delete();
        }
        try {
            if (file.createNewFile()) {
                Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                intent.putExtra(MediaStore.EXTRA_OUTPUT, FileProvider.getUriForFile(this, "com.congmingpai.mobild.fileprovider", file));
                this.startActivityForResult(intent, REQUEST_TAKE_PHOTO);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        this.response("");
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