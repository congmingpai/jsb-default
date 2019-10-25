package org.cocos2dx.javascript;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.content.res.Configuration;
import android.opengl.GLSurfaceView;
import android.os.Bundle;

public class SdkManager {
	public static Activity activity = null;
	public static Application application = null;

	public static native void setAppActivity(Activity a);
	public static native void setGLSurfaceView(GLSurfaceView view);

	public static native void activityOnCreate();
	public static native void activityOnPause();
	public static native void activityOnResume();
	public static native void activityOnDestroy();
	public static native void activityOnStart();
	public static native void activityOnRestart();
	public static native void activityOnStop();
	public static native void activityOnNewIntent(Intent intent);
	public static native void activityOnActivityResult(int requestCode, int resultCode, Intent data);
	public static native void activityOnBackPressed();
	public static native void activityOnSaveInstanceState(Bundle outState);
	public static native void activityOnRestoreInstanceState(Bundle savedInstanceState);
	public static native void activityOnConfigurationChanged(Configuration newConfig);
}
