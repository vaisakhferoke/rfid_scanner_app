package com.xlzn.hcpda.uhf.module;
import android.content.Context;
import android.util.Log;

import com.xlzn.hcpda.uhf.analysis.UHFProtocolAnalysisBase;
import com.xlzn.hcpda.uhf.enums.ConnectState;
import com.xlzn.hcpda.uhf.enums.LockActionEnum;
import com.xlzn.hcpda.uhf.enums.LockMembankEnum;
import com.xlzn.hcpda.uhf.interfaces.IBuilderAnalysis;
import com.xlzn.hcpda.uhf.interfaces.IUHFProtocolAnalysis;
import com.xlzn.hcpda.uhf.interfaces.IUHFReader;
import com.xlzn.hcpda.uhf.interfaces.OnInventoryDataListener;
import com.xlzn.hcpda.uhf.serialport.UHFSerialPort;
import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFVersionInfo;
import com.xlzn.hcpda.uhf.enums.InventoryModeForPower;
import com.xlzn.hcpda.uhf.enums.UHFSession;

abstract class UHFReaderSLRBase extends UHFReaderBase implements IUHFReader {
    private String TAG="UHFReaderSLRBase";
    //UHF
    protected IUHFProtocolAnalysis uhfProtocolAnalysisSLR=null;

    protected IBuilderAnalysis builderAnalysisSLR=null;
    //
    protected OnInventoryDataListener onInventoryDataListener=null;

    //
    protected InventoryModeForPower InventoryMode=InventoryModeForPower.FAST_MODE;

    public UHFReaderSLRBase(IUHFProtocolAnalysis uhfProtocolAnalysisSLR, IBuilderAnalysis builderAnalysisSLR){
        this.uhfProtocolAnalysisSLR=uhfProtocolAnalysisSLR;
        this.builderAnalysisSLR=builderAnalysisSLR;
    }
    @Override
    public UHFReaderResult connect(Context context) {
        return null;
    }

    @Override
    public UHFReaderResult disConnect() {
        return  null;
    }
    @Override
    public UHFReaderResult<Boolean> setInventoryModeForPower(InventoryModeForPower modeForPower) {
        InventoryMode=modeForPower;
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS,"",true);
    }

    @Override
    public ConnectState getConnectState() {
        return super.getConnectState();
    }

    @Override
    public UHFReaderResult<UHFVersionInfo> getVersions() {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeGetVersionSendData());
        return builderAnalysisSLR.analysisVersionData(dataFrameInfo);
    }

    @Override
    public UHFReaderResult<Boolean> setSession(UHFSession vlaue) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetSessionSendData(vlaue));
        return builderAnalysisSLR.analysisSetSessionResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<UHFSession> getSession() {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeGetSessionSendData());
        return builderAnalysisSLR.analysisGetSessionResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> setPower(int power) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(builderAnalysisSLR.makeSetPowerSendData(power));
        int status = dataFrameInfo.status;
        Log.e("ttt", "setPower: status = " + status );
        if (status == 261) {
            UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo2 = sendAndReceiveData(builderAnalysisSLR.makeSetPowerSendData(30));
            Log.e("ttt", "setPower: status = " + status );
            return builderAnalysisSLR.analysisSetPowerResultData(dataFrameInfo2);
        }
        return builderAnalysisSLR.analysisSetPowerResultData(dataFrameInfo);
    }

    @Override
    public UHFReaderResult<Integer> getPower() {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(builderAnalysisSLR.makeGetPowerSendData());

        return builderAnalysisSLR.analysisGetPowerResultData(dataFrameInfo);
    }

    @Override
    public UHFReaderResult<Boolean> setFrequencyRegion(int region) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetFrequencyRegionSendData(region));
        return builderAnalysisSLR.analysisSetFrequencyRegionResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Integer> getFrequencyRegion() {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeGetFrequencyRegionSendData());
        return builderAnalysisSLR.analysisGetFrequencyRegionResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Integer> getTemperature() {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeGetTemperatureSendData());
        return builderAnalysisSLR.analysisGetTemperatureResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> setDynamicTarget(int vlaue) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetDynamicTargetSendData(vlaue));
        return builderAnalysisSLR.analysisSetDynamicTargetResultData(dataFrameInfo);
    }

    @Override
    public UHFReaderResult<Boolean> setStaticTarget(int vlaue) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetStaticTargetSendData(vlaue));
        return builderAnalysisSLR.analysisSetStaticTargetResultData(dataFrameInfo);
    }

    @Override
    public UHFReaderResult<String> read(String password,int membank,int address,int wordCount,SelectEntity selectEntity) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeReadSendData(  password,  membank,  address,  wordCount,  selectEntity));
        return builderAnalysisSLR.analysisReadResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> write(String password, int membank, int address, int wordCount, String data, SelectEntity selectEntity) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeWriteSendData(  password,  membank,  address,  wordCount, data, selectEntity));
        return builderAnalysisSLR.analysisWriteResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> kill(String password, SelectEntity selectEntity) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeKillSendData(  password, selectEntity));
        return builderAnalysisSLR.analysisKillResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> lock(String password, LockMembankEnum hexMask, LockActionEnum hexAction, SelectEntity selectEntity) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeLockSendData(  password, hexMask,hexAction,selectEntity));
        return builderAnalysisSLR.analysisLockResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<int[]> getTarget() {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeGetTargetSendData());
        return builderAnalysisSLR.analysisGetTargetResultData(dataFrameInfo);
    }
    @Override
    public void setOnInventoryDataListener(OnInventoryDataListener onInventoryDataListener) {
        this.onInventoryDataListener=onInventoryDataListener;
    }
    @Override
    public UHFReaderResult<Boolean> setBaudRate(int baudRate) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetBaudRate(baudRate));
        return builderAnalysisSLR.analysisSetBaudRateResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> setFrequencyPoint(int frequencyPoint) {
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetFrequencyPoint(frequencyPoint));
        return builderAnalysisSLR.analysisSetFrequencyPointResultData(dataFrameInfo);
    }
    @Override
    public UHFReaderResult<Boolean> setRFLink(int mode) {
        Log.e("TAG", "setRFLink: RFLINK"  );
        UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo=sendAndReceiveData(builderAnalysisSLR.makeSetRFLink(mode));
        return builderAnalysisSLR.analysisSetRFLinkResultData(dataFrameInfo);
    }



    protected boolean sendData(byte[] data){
        return UHFSerialPort.getInstance().send(data);
    }

    protected UHFProtocolAnalysisBase.DataFrameInfo sendAndReceiveData(byte[] sData){
        if(!sendData(sData)){
            Log.e("TAG", "E: "  );
            return null;
        }
        int timeOut=1000;
        int cmd= sData[2]&0xFF;
        return uhfProtocolAnalysisSLR.getOtherInfo(cmd,timeOut);
    }



}
