package com.xlzn.hcpda.uhf.analysis;

import android.os.SystemClock;
import android.util.Log;

import com.xlzn.hcpda.ModuleAPI;
import com.xlzn.hcpda.uhf.interfaces.IUHFCheckCodeErrorCallback;
import com.xlzn.hcpda.uhf.interfaces.IUHFProtocolAnalysis;
import com.xlzn.hcpda.utils.DataConverter;
import com.xlzn.hcpda.utils.LoggerUtils;

import java.util.Arrays;
import java.util.Iterator;


public class UHFProtocolAnalysisSLR extends UHFProtocolAnalysisBase implements IUHFProtocolAnalysis {
    private String TAG = "UHFProtocolAnalysisSLR";
    private byte[] rawPack = null;
    private final int HEADDATA = 0XFF;
    private Object lock=new Object();
    private IUHFCheckCodeErrorCallback iuhfCheckCodeErrorCallback;
    @Override
    public void analysis(byte[] data) {
        if (rawPack == null) {
            rawPack = data;
        } else {
            int len = rawPack.length + data.length;
            byte[] newData = new byte[len];
            System.arraycopy(rawPack, 0, newData, 0, rawPack.length);
            System.arraycopy(data, 0, newData, rawPack.length, data.length);
            rawPack = newData;
        }
        int lastSuccessIndex = 0;
        int index = -1;
        //0   1  2  3  4  5  6   index
        //FF 00 72 01 01 DB 14   len=7
        while (rawPack.length > index) {
            index++;
            LoggerUtils.d(TAG, "analysis index="+index);
            if (rawPack.length - index < 7) {
                if (index > 0) {
                    //
                    rawPack = Arrays.copyOfRange(rawPack, lastSuccessIndex, rawPack.length);
                }
                return;
            }

            if ((rawPack[index] & 0xFF) == HEADDATA) {
                int start = index + 1;
                int dataLen = rawPack[start] & 0xFF;
                if(rawPack.length-(index+1+1+2+dataLen+2)<0){
                   // 0   1  2  3  4  5  6  7  8  9
                   // dd cc ff 01 29 00 00 11 xx xx
                    rawPack = Arrays.copyOfRange(rawPack, lastSuccessIndex, rawPack.length);
                    if(LoggerUtils.isDebug()) LoggerUtils.d(TAG, "" + DataConverter.bytesToHex(rawPack));
                    return;
                }

                int end = start + (1 + 1 + 2 + dataLen);
                byte[] validateData = Arrays.copyOfRange(rawPack, start, end);
                byte[] crc = Arrays.copyOfRange(rawPack, end, end + 2);
                byte[] crcTemp=new byte[2];
                ModuleAPI.getInstance().CalcCRC(validateData,validateData.length,crcTemp);
                if (crc[0] == crcTemp[0] && crc[1] == crcTemp[1]) {

                    int cmdIndex = index + 2;
                    int statusIndex = index + 3;
                    int statusEnd = statusIndex + 2;
                    byte[] status = Arrays.copyOfRange(rawPack, statusIndex, statusEnd);
                    DataFrameInfo dataFrameInfo = new DataFrameInfo();
                    dataFrameInfo.command = rawPack[cmdIndex] & 0xFF;
                    dataFrameInfo.time = SystemClock.elapsedRealtime();
                    dataFrameInfo.status = ((status[0] & 0xFF) << 8) | (status[1] & 0xFF);
                    if (dataLen > 0) {
                        int dataIndex = statusEnd;
                        int dataEnd = statusEnd + dataLen;
                        dataFrameInfo.data = Arrays.copyOfRange(rawPack, dataIndex, dataEnd);
                    }
                    addData(dataFrameInfo);
                    byte[] allData = Arrays.copyOfRange(rawPack, index, statusEnd + dataLen + 2);

                    index = statusEnd + dataLen + 2 -1;
                    lastSuccessIndex = index;
                } else {
                    lastSuccessIndex=index;
                    if(iuhfCheckCodeErrorCallback!=null){
                        iuhfCheckCodeErrorCallback.checkCodeError(0,rawPack[index+2] & 0xFF,null);
                    }
                }
            }else{
                lastSuccessIndex=index;
            }
            if (rawPack.length - 1 == index) {
                if (lastSuccessIndex == index) {
                    rawPack = null;
                } else {
                    rawPack = Arrays.copyOfRange(rawPack, lastSuccessIndex, rawPack.length);
                }
                LoggerUtils.d(TAG, "!");
                return;
            }

        }
    }

    @Override
    public void setCheckCodeErrorCallback(IUHFCheckCodeErrorCallback iuhfCheckCodeErrorCallback) {
        this.iuhfCheckCodeErrorCallback=iuhfCheckCodeErrorCallback;
    }

    public DataFrameInfo getOtherInfo(int cmd,int timeOut){
        long startTime=SystemClock.uptimeMillis();
        while (SystemClock.uptimeMillis()-startTime<timeOut){
            if(listCmd!=null && listCmd.size()>0){
                synchronized (lock) {
                    for (int k = 0; k < listCmd.size(); k++) {
                        DataFrameInfo dataFrameInfo = listCmd.get(k);
                        if (dataFrameInfo.command == cmd) {
                            listCmd.remove(dataFrameInfo);
                            return dataFrameInfo;
                        }
                    }
                }
            }
            try {
                Thread.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        Log.e("TAG", "getOtherInfo: "  +(SystemClock.uptimeMillis()-startTime<timeOut) );
        return null;

    }

    protected void addData(DataFrameInfo dataFrameInfo){
        if(dataFrameInfo.command==0x29){

            if(dataFrameInfo.status==0) {
                byte[] taginfo = dataFrameInfo.data;
                int tagsTotal = taginfo[3] & 0xFF;//标签张数
                if (tagsTotal > 0) {
                    queueTaginfo.offer(dataFrameInfo);
                }
            }
        }else if(dataFrameInfo.command==0xAA){
              //”Moduletech” //4D 6F 64 75 6C 65 74 65 63 68
            byte[] data=dataFrameInfo.data;
            if(data!=null && data.length>=10){
              boolean flag= (data[0] & 0xFF)==0x4D && (data[1] & 0xFF)==0x6F && (data[2] & 0xFF)==0x64 &&
                            (data[3] & 0xFF)==0x75 && (data[4] & 0xFF)==0x6C && (data[5] & 0xFF)==0x65 &&
                            (data[6] & 0xFF)==0x74 && (data[7] & 0xFF)==0x65 && (data[8] & 0xFF)==0x63 && (data[9] & 0xFF)==0x68;
              if(flag){
                  addOtherInfoData(dataFrameInfo);
              }else{
                  if(dataFrameInfo.status==0) {
                      byte[] taginfo = dataFrameInfo.data;
                      int tagsTotal = taginfo[3] & 0xFF;//标签张数
                      if (tagsTotal > 0) {
                          LoggerUtils.d(TAG, "= "+ tagsTotal);
                          queueTaginfo.offer(dataFrameInfo);
                      }
                  }
              }
            }
        }else{
            addOtherInfoData(dataFrameInfo);
        }
    }
    private void addOtherInfoData(DataFrameInfo dataFrameInfo){
        synchronized (lock) {
            Iterator<DataFrameInfo> iterator= listCmd.iterator();
            while (iterator.hasNext()){
                DataFrameInfo info= iterator.next();
                if(SystemClock.elapsedRealtime()-info.time>5000){
                    iterator.remove();
                }
            }

            listCmd.add(dataFrameInfo);
        }
    }

}

