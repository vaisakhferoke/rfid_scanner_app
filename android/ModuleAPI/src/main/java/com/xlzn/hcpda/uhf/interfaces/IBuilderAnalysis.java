package com.xlzn.hcpda.uhf.interfaces;

import com.xlzn.hcpda.uhf.analysis.UHFProtocolAnalysisBase;
import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFTagEntity;
import com.xlzn.hcpda.uhf.entity.UHFVersionInfo;
import com.xlzn.hcpda.uhf.enums.LockActionEnum;
import com.xlzn.hcpda.uhf.enums.LockMembankEnum;
import com.xlzn.hcpda.uhf.enums.UHFSession;

import java.util.List;


public interface IBuilderAnalysis {

    public byte[] makeSetTargetModel(int model);

    public byte[] makeStartInventorySendData(SelectEntity selectEntity,boolean isTID);


    public byte[] makeStartFastModeInventorySendData(SelectEntity selectEntity,boolean isTID);


    public byte[] makeStartFastModeInventorySendDataMoreTag(SelectEntity selectEntity,boolean isTID);

    public byte[] makeStartFastModeInventorySendDataNeedTid(SelectEntity selectEntity,boolean isTID);

    public byte[] makeStartFastModeInventorySendDataNeedTid512(SelectEntity selectEntity,boolean isTID);


    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID);

    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveDataNeedTid(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID);

    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveDataNeedTidMoreTag(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID);

    public byte[] makeStopFastModeInventorySendData();

    public UHFReaderResult<Boolean> analysisStopFastModeInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public UHFReaderResult<Integer> analysisStartInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeGetTagInfoSendData();

    public List<UHFTagEntity> analysisTagInfoReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data) ;

    public List<UHFTagEntity> analysisFastModeTagInfoReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public List<UHFTagEntity> analysisFastModeTagInfoReceiveDataOld(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeGetVersionSendData();

    public UHFReaderResult<UHFVersionInfo> analysisVersionData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeSetSessionSendData(UHFSession value);

    public UHFReaderResult<Boolean> analysisSetSessionResultData(UHFProtocolAnalysisBase.DataFrameInfo data);


    public byte[] makeGetSessionSendData();

    public UHFReaderResult<UHFSession> analysisGetSessionResultData(UHFProtocolAnalysisBase.DataFrameInfo data);



    public byte[] makeSetPowerSendData(int power);

    public UHFReaderResult<Boolean> analysisSetPowerResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeGetPowerSendData();

    public UHFReaderResult<Integer> analysisGetPowerResultData(UHFProtocolAnalysisBase.DataFrameInfo data);


    public byte[] makeSetFrequencyRegionSendData(int frequencyRegion);

    public UHFReaderResult<Boolean> analysisSetFrequencyRegionResultData(UHFProtocolAnalysisBase.DataFrameInfo data);


    public byte[] makeGetFrequencyRegionSendData();

    public UHFReaderResult<Integer> analysisGetFrequencyRegionResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeGetTemperatureSendData();

    public UHFReaderResult<Integer> analysisGetTemperatureResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeSetDynamicTargetSendData(int value);

    public UHFReaderResult<Boolean> analysisSetDynamicTargetResultData(UHFProtocolAnalysisBase.DataFrameInfo data);


    public byte[] makeSetStaticTargetSendData(int value);

    public UHFReaderResult<Boolean> analysisSetStaticTargetResultData(UHFProtocolAnalysisBase.DataFrameInfo data);


    public byte[] makeGetTargetSendData();

    public UHFReaderResult<int[]> analysisGetTargetResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeReadSendData(String password,int membank,int address,int wordCount,SelectEntity selectEntity);

    public UHFReaderResult<String> analysisReadResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeWriteSendData(String password,int membank,int address,int wordCount,String data,SelectEntity selectEntity);

    public UHFReaderResult<Boolean> analysisWriteResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeKillSendData(String password,SelectEntity selectEntity);

    public UHFReaderResult<Boolean> analysisKillResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeLockSendData(String password, LockMembankEnum hexMask, LockActionEnum hexAction, SelectEntity selectEntity);

    public UHFReaderResult<Boolean> analysisLockResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeSingleTagInventorySendData(SelectEntity selectEntity);

    public UHFReaderResult<UHFTagEntity> analysisSingleTagInventoryResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeInventorySelectEntity(SelectEntity selectEntity);
    public UHFReaderResult<Boolean> analysisInventorySelectEntityResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeSetBaudRate(int baudrate);
    public UHFReaderResult<Boolean> analysisSetBaudRateResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeSetFrequencyPoint(int frequencyPoint);
    public UHFReaderResult<Boolean> analysisSetFrequencyPointResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    public byte[] makeSetRFLink(int mode);
    public UHFReaderResult<Boolean> analysisSetRFLinkResultData(UHFProtocolAnalysisBase.DataFrameInfo data);

    List<UHFTagEntity> analysisFastModeTagInfoReceiveDataMoreTag(UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo);
}
