package com.xlzn.hcpda.jxl;

import android.annotation.SuppressLint;
import android.os.Environment;
import android.util.Log;

import com.xlzn.hcpda.uhf.entity.UHFTagEntity;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class FileImport {
    //    static String xlsFilePath = Environment.getExternalStorageDirectory() + "/Android/";
    @SuppressLint("SdCardPath")
//    static String xlsFilePath = "/storage/emulated/0/Download/";
    static String xlsFilePath = Environment.getExternalStorageDirectory().getPath() + "/scanData/";

    public static boolean daochu(String tmpname, List<UHFTagEntity> lists2) {
        try {
            String file = xlsFilePath + tmpname;
            File path2 = new File(xlsFilePath);
            File path3 = new File(file);
//            @SuppressLint("SdCardPath") File path2 = new File("/sdcard/Android/data/com.example.uhf/");


            if (!path3.exists()) {
                path2.createNewFile();
            }
            Log.e("TAG", ": " + file);
            List<Object> al22 = new ArrayList<Object>();
            List<String> al2 = new ArrayList<String>();

            al2.add("编号");
            al22.add(al2);
            FileXls.writeXLS(file, al22);
            List<Object> ac = new ArrayList<Object>();
            for (int i = 0; i < lists2.size(); i++) {
                List<String> al = new ArrayList<String>();
                al.add(lists2.get(i).getEcpHex());
                // al.add(sxl);
                ac.add(al);
            }

            return FileXls.writeXLS(file, ac);
        } catch (Exception ex) {

            Log.e("TAG", " = : " + ex.getMessage());
            return false;
        }
    }

    public static boolean daochuStringList(String tmpname, List<String> lists2) {
        try {
            String file = xlsFilePath + tmpname;
            File path2 = new File(xlsFilePath);

            if (!path2.exists()) {
                path2.createNewFile();
            }
            List<Object> al22 = new ArrayList<Object>();
            List<String> al2 = new ArrayList<String>();

            al2.add("编号");


            al22.add(al2);
            FileXls.writeXLS(file, al22);
            List<Object> ac = new ArrayList<Object>();
            for (int i = 0; i < lists2.size(); i++) {
                List<String> al = new ArrayList<String>();
                al.add(lists2.get(i));
                // al.add(sxl);
                ac.add(al);
            }

            return FileXls.writeXLS(file, ac);
        } catch (Exception ex) {

            Log.e("TAG", " = : " + ex.getMessage());
            return false;
        }
    }


    public static String GetTimesyyyymmdd() {

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        Date curDate = new Date(System.currentTimeMillis());
        String dt = formatter.format(curDate);

        return dt;

    }

    public static String GetTimesddMMyy() {

        SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yy");
        Date curDate = new Date(System.currentTimeMillis());
        String dt = formatter.format(curDate);

        return dt;

    }

    public static String GetTimesyyyymmddhhmmss() {

        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        Date curDate = new Date(System.currentTimeMillis());
        String dt = formatter.format(curDate);

        return dt;

    }
}
