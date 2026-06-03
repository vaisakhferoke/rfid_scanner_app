package com.xlzn.hcpda.uhf.module;

import android.os.SystemClock;
import android.util.Log;

import com.xlzn.hcpda.uhf.analysis.UHFProtocolAnalysisBase;
import com.xlzn.hcpda.uhf.interfaces.IUHFCheckCodeErrorCallback;
import com.xlzn.hcpda.uhf.interfaces.IUHFReader;
import com.xlzn.hcpda.uhf.UHFReader;
import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFTagEntity;
import com.xlzn.hcpda.uhf.enums.InventoryModeForPower;
import com.xlzn.hcpda.uhf.interfaces.IBuilderAnalysis;
import com.xlzn.hcpda.uhf.interfaces.IUHFProtocolAnalysis;
import com.xlzn.hcpda.utils.LoggerUtils;

import java.util.List;

public class UHFReaderSLR1200 extends UHFReaderSLRBase implements IUHFReader {
    private String TAG = "UHFReaderSLR1200";
    private boolean isTid = false;
    private boolean isMoreTag = false;
    private PowerSavingModeInventoryThread inventoryThread = null;
    private FastModeInventoryThread fastModeInventoryThread = null;
    private UHFCheckCodeErrorCallback uhfCheckCodeErrorCallback = new UHFCheckCodeErrorCallback();

    public UHFReaderSLR1200(IUHFProtocolAnalysis uhfProtocolAnalysisSLR, IBuilderAnalysis builderAnalysisSLR) {
        super(uhfProtocolAnalysisSLR, builderAnalysisSLR);
        uhfProtocolAnalysisSLR.setCheckCodeErrorCallback(uhfCheckCodeErrorCallback);
    }

    @Override
    public UHFReaderResult<Boolean> setInventoryTid(boolean isTid) {
//        this.isTid = true;
        this.isTid = isTid;
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
    }

    @Override
    public UHFReaderResult<Boolean> getInventoryTidModel() {

        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", isTid);
    }

    @Override
    public UHFReaderResult<Boolean> startInventory(SelectEntity selectEntity) {
        uhfProtocolAnalysisSLR.cleanTagInfo();
        isMoreTag = UHFReader.isMoreTag;
        LoggerUtils.d(TAG, " isMoreTag = " +isMoreTag );
        if (InventoryMode == InventoryModeForPower.POWER_SAVING_MODE) {

            startPowerSavingModeInventoryThread(selectEntity);
            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        } else {

            byte[] data;
            if (isTid) {
                LoggerUtils.d(TAG, "，A48  TID" );
                data = builderAnalysisSLR.makeStartFastModeInventorySendDataNeedTid512(selectEntity, true);
            } else if (isMoreTag) {
                data = builderAnalysisSLR.makeStartFastModeInventorySendDataMoreTag(null, false);
            } else {
                LoggerUtils.d(TAG, "AA48 TID " +builderAnalysisSLR.getClass() );
                data = builderAnalysisSLR.makeStartFastModeInventorySendData(selectEntity, false);
            }

            UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(data);
            UHFReaderResult<Boolean> uhfReaderResult = null;

            if (isTid) {
                uhfReaderResult = builderAnalysisSLR.analysisStartFastModeInventoryReceiveDataNeedTid(dataFrameInfo, true);
            }else if (isMoreTag){
                uhfReaderResult = builderAnalysisSLR.analysisStartFastModeInventoryReceiveDataNeedTidMoreTag(dataFrameInfo, false);

            }else {
                uhfReaderResult = builderAnalysisSLR.analysisStartFastModeInventoryReceiveData(dataFrameInfo, false);
            }
            if (uhfReaderResult.getResultCode() != UHFReaderResult.ResultCode.CODE_SUCCESS) {
                return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
            }
//            if (selectEntity != null) {
//                isNeedFilter = true;
//            }
            startFastModeInventoryThread();
            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }

    }

    @Override
    public UHFReaderResult<Boolean> stopInventory() {
        if (InventoryMode == InventoryModeForPower.POWER_SAVING_MODE) {
            stopPowerSavingModeInventoryThread();
            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS);
        } else {
            byte[] data = builderAnalysisSLR.makeStopFastModeInventorySendData();
            UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(data);
            UHFReaderResult<Boolean> uhfReaderResult = builderAnalysisSLR.analysisStopFastModeInventoryReceiveData(dataFrameInfo);
            stopFastModeInventoryThread();
            if (uhfReaderResult.getResultCode() != UHFReaderResult.ResultCode.CODE_SUCCESS) {
                Log.e("ttt", "stopInventory:  "  );
                return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
            }
            Log.e("ttt", "stopInventory:  "  );

            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }

    }

    @Override
    public UHFReaderResult<UHFTagEntity> singleTagInventory(SelectEntity selectEntity) {

        //
        byte[] data = builderAnalysisSLR.makeSingleTagInventorySendData(selectEntity);
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(data);
        UHFReaderResult<UHFTagEntity> uhfReaderResult = builderAnalysisSLR.analysisSingleTagInventoryResultData(dataFrameInfo);
        return uhfReaderResult;
    }

    @Override
    public UHFReaderResult<Boolean> setInventorySelectEntity(SelectEntity selectEntity) {
        byte[] data = builderAnalysisSLR.makeInventorySelectEntity(selectEntity);
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(data);
        UHFReaderResult<Boolean> uhfReaderResult = builderAnalysisSLR.analysisInventorySelectEntityResultData(dataFrameInfo);
        return uhfReaderResult;
    }

    @Override
    public UHFReaderResult<Boolean> setModuleType(String moduleType) {
        return null;
    }

    @Override
    public UHFReaderResult<String> getModuleType() {
        return null;
    }




    public void startPowerSavingModeInventoryThread(SelectEntity selectEntity) {
        if (inventoryThread == null) {
            inventoryThread = new PowerSavingModeInventoryThread(selectEntity);
            inventoryThread.start();
        }
    }

    public void stopPowerSavingModeInventoryThread() {
        if (inventoryThread != null) {
            inventoryThread.stopThread();
            inventoryThread = null;
        }
    }

    public void startFastModeInventoryThread() {
        if (fastModeInventoryThread == null) {
            fastModeInventoryThread = new FastModeInventoryThread();
            fastModeInventoryThread.start();
        }
    }

    public void stopFastModeInventoryThread() {
        if (fastModeInventoryThread != null) {
            fastModeInventoryThread.stopThread();
            fastModeInventoryThread = null;
        }
    }


    class FastModeInventoryThread extends Thread {
        private boolean isStop = false;
        private Object lock = new Object();

        @Override
        public void run() {
            while (!isStop) {
                {
                    UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = uhfProtocolAnalysisSLR.getTagInfo();
                    List<UHFTagEntity> list = null;


                    if (isTid) {
                        list = builderAnalysisSLR.analysisFastModeTagInfoReceiveData(dataFrameInfo);
                    } else if (isMoreTag){
                        list = builderAnalysisSLR.analysisFastModeTagInfoReceiveDataMoreTag(dataFrameInfo);
                    }else {
                        list = builderAnalysisSLR.analysisFastModeTagInfoReceiveDataOld(dataFrameInfo);
                    }

                    if (list != null && list.size() > 0) {
                        if (onInventoryDataListener != null) {
                            onInventoryDataListener.onInventoryData(list);
                        }
                    } else {
                        sleep(1);

                    }
                }
            }
        }

        private void sleep(int time) {
            synchronized (lock) {
                try {
                    lock.wait(time);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }

        public void stopThread() {
            isStop = true;
            synchronized (lock) {
                lock.notifyAll();
            }
        }
    }

    class PowerSavingModeInventoryThread extends Thread {
        private boolean isStop = false;
        private Object lock = new Object();
        private int tagNumber = 0;
        private long starTime = SystemClock.elapsedRealtime();
        private long tempTime = SystemClock.elapsedRealtime();
        private SelectEntity selectEntity = null;

        public PowerSavingModeInventoryThread(SelectEntity selectEntity) {
            this.selectEntity = selectEntity;
        }

        @Override
        public void run() {
            while (!isStop) {
                if (tagNumber <= 0) {

                    UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(builderAnalysisSLR.makeStartInventorySendData(selectEntity, isTid));
                    UHFReaderResult<Integer> result = builderAnalysisSLR.analysisStartInventoryReceiveData(dataFrameInfo);
                    if (result.getResultCode() == UHFReaderResult.ResultCode.CODE_SUCCESS && result.getData() > 0) {
                        starTime = SystemClock.elapsedRealtime();
                        tagNumber = result.getData();
                    }
                } else {

                    boolean result = sendData(builderAnalysisSLR.makeGetTagInfoSendData());
                    if (result) {
                        int count = 50;
                        tempTime = SystemClock.elapsedRealtime();
                        for (int k = 0; k < count; k++) {
                            UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = uhfProtocolAnalysisSLR.getTagInfo();
                            List<UHFTagEntity> list = builderAnalysisSLR.analysisTagInfoReceiveData(dataFrameInfo);
                            if (list != null && list.size() > 0) {
                                if (onInventoryDataListener != null) {
                                    onInventoryDataListener.onInventoryData(list);
                                }
                                tagNumber = tagNumber - list.size();
                                break;
                            }
                            sleep(1);
                            if (SystemClock.elapsedRealtime() - tempTime > count) {
                                break;
                            }
                        }
                    } else {
                        //TID
                        //FF1FAA4D6F64756C6574656368AA480006009004010928000000020000000006C6BBD321

                        // TID
                        //FF13AA4D6F64756C6574656368AA4800060090038BBB97DA

                        sleep(10);
                    }
                    if (SystemClock.elapsedRealtime() - starTime > 800) {
                        tagNumber = 0;
                    }

                }
            }
        }

        private void sleep(int time) {
            synchronized (lock) {
                try {
                    lock.wait(time);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }

        public void stopThread() {
            isStop = true;
            synchronized (lock) {
                lock.notifyAll();
            }
        }
    }

    class UHFCheckCodeErrorCallback implements IUHFCheckCodeErrorCallback {
        @Override
        public void checkCodeError(int mode, int cmd, byte[] errorData) {
            if (inventoryThread != null) {
                inventoryThread.tagNumber = 0;
            }
        }
    }
}
