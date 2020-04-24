package com.congmingpai.mobile;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.hardware.camera2.*;
import android.media.Image;
import android.media.ImageReader;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

public class Camera extends CameraDevice.StateCallback {
    static public abstract class Callback {
        public abstract void response(@Nullable Bitmap bitmap);
    }

    private CameraManager mCameraManager = null;
    private CameraDevice mCameraDevice = null;

    private SurfaceHolder mTarget = null;
    private Context mOwner = null;

    private Callback mCallback = null;

    private CameraCaptureSession mCaptureSession = null;
    private ImageReader mImageReader = null;

    private Bitmap mResult = null;
    public Bitmap getResult() { return mResult; }

//    private boolean mCaptured = false;

    private Camera mSelf = null;

    public Camera(@NonNull Context owner, @NonNull SurfaceHolder target, @NonNull Callback callback){
        mSelf = this;
        mOwner = owner;
        mTarget = target;
        mCallback = callback;
    }

    @SuppressLint("MissingPermission")
    public boolean open(){
        Log.d("Camera", "try to open camera");
        if (null != mCameraDevice){
            this.captureToRender();
            return true;
        }

//            CameraCharacteristics characteristics = mCameraManager.getCameraCharacteristics(camera.getId());
//            StreamConfigurationMap configurationMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
//            Size[] supportedSizes = configurationMap.getOutputSizes(ImageFormat.JPEG);
//            mTarget.setFixedSize(supportedSizes[0].getWidth(), supportedSizes[0].getHeight());
        mTarget.setFixedSize(1280, 720);

        CameraManager manager = mCameraManager = mOwner.getSystemService(CameraManager.class);
        try {
            // 使用前置摄像头
            String targetId = "";
            String[] deviceIds = manager.getCameraIdList();
            for (int i = 0; i < deviceIds.length; ++i) {
                CameraCharacteristics characteristics = mCameraManager.getCameraCharacteristics(deviceIds[i]);
                if (CameraCharacteristics.LENS_FACING_FRONT == characteristics.get(CameraCharacteristics.LENS_FACING)) {
                    targetId = deviceIds[i];
                    break;
                }
            }
            manager.openCamera("" == targetId ? deviceIds[0] : targetId, this, null);
            return true;
        } catch (CameraAccessException e) {
            e.printStackTrace();
            mSelf.response(null);
        }
        return false;
    }

    public boolean capture(){
        if (null == mCaptureSession){
            return false;
        }
        try {
            mCaptureSession.stopRepeating();

            CaptureRequest.Builder requestBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
            requestBuilder.addTarget(mImageReader.getSurface());
            mCaptureSession.capture(requestBuilder.build(), mCaptureCallback, null);
        } catch (CameraAccessException e) {
            e.printStackTrace();
            mSelf.response(null);
            return false;
        }
        return true;
    }

    private CameraCaptureSession.StateCallback mStateCallback = new CameraCaptureSession.StateCallback() {
        @Override
        public void onConfigured(@NonNull CameraCaptureSession session) {
            try {
                CaptureRequest.Builder requestBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                requestBuilder.addTarget(mTarget.getSurface());
                session.setRepeatingRequest(requestBuilder.build(), mCaptureCallback, null);
                mCaptureSession = session;
            } catch (CameraAccessException e) {
                e.printStackTrace();
                mSelf.response(null);
            }
        }

        @Override
        public void onConfigureFailed(@NonNull CameraCaptureSession session) {
            mSelf.response(null);
        }
    };

    private CameraCaptureSession.CaptureCallback mCaptureCallback = new CameraCaptureSession.CaptureCallback() {
        @Override
        public void onCaptureCompleted(CameraCaptureSession session, CaptureRequest request, TotalCaptureResult result) {
            super.onCaptureCompleted(session, request, result);
//            mCaptured = true;
        }

        @Override
        public void onCaptureFailed(@NonNull CameraCaptureSession session, @NonNull CaptureRequest request, @NonNull CaptureFailure failure) {
            super.onCaptureFailed(session, request, failure);
            mSelf.response(null);
        }
    };

    private ImageReader.OnImageAvailableListener mImageAvailableListener = new ImageReader.OnImageAvailableListener() {
        @Override
        public void onImageAvailable(ImageReader reader) {
            Bitmap bitmap = null;
            try {
                Image image = reader.acquireNextImage();

                Image.Plane[] planes = image.getPlanes();
                ByteBuffer byteBuffer = planes[0].getBuffer();
                byte[] buffer = new byte[byteBuffer.limit()];
                byteBuffer.get(buffer);
                bitmap = Bitmap.createBitmap(BitmapFactory.decodeByteArray(buffer, 0, buffer.length));
                bitmap = Bitmap.createScaledBitmap(bitmap, -bitmap.getWidth(), bitmap.getHeight(), false);

                image.close();
            }catch (Exception e){
                e.printStackTrace();
            }
            mResult = bitmap;
            mSelf.response(bitmap);
        }
    };

    private void captureToRender() {
        if (null == mCameraDevice){
            return;
        }

        mResult = null;

        try {
            Log.d("Camera", "try to create capture session");
            List<Surface> surfaces = new ArrayList<Surface>();
            Surface surface = mTarget.getSurface();
            surfaces.add(surface);

            Rect rect = mTarget.getSurfaceFrame();
            ImageReader imageReader = mImageReader = ImageReader.newInstance(rect.width(), rect.height(), ImageFormat.JPEG, 1);
            imageReader.setOnImageAvailableListener(mImageAvailableListener, null);
            surfaces.add(imageReader.getSurface());

            mCameraDevice.createCaptureSession(surfaces, mStateCallback, null);
        } catch (CameraAccessException e) {
            e.printStackTrace();
            mSelf.response(null);
        }
    }

    @Override
    public void onOpened(@NonNull CameraDevice camera) {
        Log.d("Camera", "camera open");
        mCameraDevice = camera;
        this.captureToRender();
    }

    @Override
    public void onDisconnected(@NonNull CameraDevice camera) {
        // 以下三种情况会触发此事件：
        // 1. 启动相机之后，其他应用占用相机
        // 2. 启动相机之后，再次启动相机
        // 3. 主动释放相机
//        if (!mCaptured) {
//            mSelf.response(null);
//        }
    }

    @Override
    public void onError(@NonNull CameraDevice camera, int error) {
        Log.e("General custom camera", String.format("CameraDevice error : %d", error));
        mSelf.response(null);
    }

    private void response(@Nullable Bitmap bitmap) {
        mCallback.response(bitmap);
    }

    public void Release() {
        if (null != mCameraDevice) {
            mCameraDevice.close();
            mCameraDevice = null;
        }
    }
}
