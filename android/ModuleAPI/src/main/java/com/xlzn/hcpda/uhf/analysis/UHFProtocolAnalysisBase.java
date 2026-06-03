package com.xlzn.hcpda.uhf.analysis;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingQueue;

public abstract class UHFProtocolAnalysisBase {
    public LinkedBlockingQueue<DataFrameInfo>  queueTaginfo=new LinkedBlockingQueue<>(2000);
    public List<DataFrameInfo> listCmd=new ArrayList<>();
    public static class DataFrameInfo{
        public int command;
        public int status;
        //
        public byte[] data;
        //
        public long time;
    }

    public DataFrameInfo getTagInfo(){
       return queueTaginfo.poll();
    }
    public void cleanTagInfo() {
        queueTaginfo.clear();
    }



}
