package org.cocos2dx.javascript;

import android.app.ActivityManager;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Environment;
import android.os.StatFs;

import com.tencent.bugly.crashreport.CrashReport;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

import org.cocos2dx.javascript.SdkManager;

public class UtilsSdk {

    public static long getAvailMemory() {
        Context context = SdkManager.activity;
        ActivityManager activityManager = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        return memoryInfo.availMem; // Byte
    }

    public static long getTolalMemory() {
        try {
            String path = "/proc/meminfo";
            FileReader fr = new FileReader(path);
            BufferedReader br = new BufferedReader(fr);
            String memTotal = br.readLine().split("\\s+")[1]; // kB
            br.close();

            return Long.valueOf(memTotal) * 1024;
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // 获取手机内部空间总容量
    public static long getTotalInternalFileSystemSize() {
        File path = Environment.getDataDirectory();
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();
        long totalBlocks = stat.getBlockCount();
        return totalBlocks * blockSize;
    }

    // 获取手机内部空间可用容量
    static public long getAvailableInternalFileSystemSize() {
        File path = Environment.getDataDirectory();
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();
        long availableBlocks = stat.getAvailableBlocks();
        return availableBlocks * blockSize;
    }

     static public boolean isSDCardEnable() {
        return Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState());
    }

    // 获取手机外部空间总容量
    static public long getTotalExternalFileSystemSize() {
        if (isSDCardEnable()) {
            File path = Environment.getExternalStorageDirectory();
            StatFs stat = new StatFs(path.getPath());
            long blockSize = stat.getBlockSize();
            long totalBlocks = stat.getBlockCount();
            return totalBlocks * blockSize;
        }
        return -1;
    }

    // 获取手机外部空间可用容量
    public static long getAvailableExternalFileSystemSize() {
        if (isSDCardEnable()) {
            File path = Environment.getExternalStorageDirectory();
            StatFs stat = new StatFs(path.getPath());
            long blockSize = stat.getBlockSize();
            long availableBlocks = stat.getAvailableBlocks();
            return availableBlocks * blockSize;
        }
        return -1;
    }

    public static int getNetworkType() {
        ConnectivityManager manager = (ConnectivityManager)SdkManager.activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = manager.getActiveNetworkInfo();
        if(info != null && info.isAvailable()) {
            return info.getType();
        }
        return -1;
    }

    public static void setBuglyUserData(String key, String value) {
        CrashReport.putUserData(SdkManager.activity, key, value);
    }
}
