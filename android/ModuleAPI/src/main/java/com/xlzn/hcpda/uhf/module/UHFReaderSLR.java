package com.xlzn.hcpda.uhf.module;

import android.content.Context;
import android.os.SystemClock;
import android.util.Log;

import com.hc.so.HcPowerCtrl;
import com.xlzn.hcpda.DeviceConfigManage;
import com.xlzn.hcpda.uhf.analysis.BuilderAnalysisSLR;
import com.xlzn.hcpda.uhf.analysis.BuilderAnalysisSLR_E710;
import com.xlzn.hcpda.uhf.analysis.UHFProtocolAnalysisBase;
import com.xlzn.hcpda.uhf.analysis.UHFProtocolAnalysisSLR;
import com.xlzn.hcpda.uhf.enums.ConnectState;
import com.xlzn.hcpda.uhf.enums.LockActionEnum;
import com.xlzn.hcpda.uhf.enums.LockMembankEnum;
import com.xlzn.hcpda.uhf.interfaces.IBuilderAnalysis;
import com.xlzn.hcpda.uhf.interfaces.IUHFProtocolAnalysis;
import com.xlzn.hcpda.uhf.interfaces.IUHFReader;
import com.xlzn.hcpda.uhf.interfaces.OnInventoryDataListener;
import com.xlzn.hcpda.uhf.serialport.UHFSerialPort;
import com.xlzn.hcpda.utils.DataConverter;
import com.xlzn.hcpda.utils.LoggerUtils;
import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFTagEntity;
import com.xlzn.hcpda.uhf.entity.UHFVersionInfo;
import com.xlzn.hcpda.uhf.enums.InventoryModeForPower;
import com.xlzn.hcpda.uhf.enums.UHFSession;

public class UHFReaderSLR implements IUHFReader {
    private String TAG = "UHFReaderSLR";
    public static UHFReaderSLR uhfReaderSLR = new UHFReaderSLR();

    private HcPowerCtrl hcPowerCtrl = new HcPowerCtrl();

    private IUHFReader iuhfReader = null;

    private IUHFProtocolAnalysis uhfProtocolAnalysisSLR = new UHFProtocolAnalysisSLR();

    private IBuilderAnalysis builderAnalysisSLR = new BuilderAnalysisSLR();
    public static boolean is5300 = false;
    public static boolean isR2000 = false;

    public static  boolean isWK0 = true;

    public static UHFReaderSLR getInstance() {
        return uhfReaderSLR;
    }

    @Override
    public UHFReaderResult<Boolean> setInventoryTid(boolean flag) {
        return iuhfReader.setInventoryTid(flag);
    }

    @Override
    public UHFReaderResult<Boolean> getInventoryTidModel() {
        return iuhfReader.getInventoryTidModel();
    }

    @Override
    public UHFReaderResult<Boolean> connect(Context context) {
        LoggerUtils.d(TAG, "connect!");
        if (getConnectState() == ConnectState.CONNECTED) {

            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS, "Success!", true);
        }

        DeviceConfigManage.UHFConfig uhfConfig = DeviceConfigManage.getInstance().getUhfConfig();
//
        if (isWK0) {
            hcPowerCtrl.uhfPower(1);
            hcPowerCtrl.uhfCtrl(1);
        } else {
            hcPowerCtrl.identityCtrl(1);
            hcPowerCtrl.identityPower(1);
        }



        //****************
        UHFReaderResult<UHFVersionInfo> verInfo = null;
        int baudrate = 115200;
        for (int k = 0; k < 2; k++) {
            if (isWK0) {
                uhfConfig.setUhfUart("/dev/ttysWK0");
            } else {
                uhfConfig.setUhfUart("/dev/ttysWK1");
            }
            boolean result = UHFSerialPort.getInstance().open(uhfConfig.getUhfUart(), uhfProtocolAnalysisSLR, baudrate);
            if (!result) {
                return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_OPEN_SERIAL_PORT_FAILURE, UHFReaderResult.ResultMessage.OPEN_SERIAL_PORT_FAILURE, false);
            }
            SystemClock.sleep(180);
            sendData(DataConverter.hexToBytes("FF00041D0B"));
            SystemClock.sleep(300);

            UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo = sendAndReceiveData(builderAnalysisSLR.makeGetVersionSendData());
            verInfo = builderAnalysisSLR.analysisVersionData(dataFrameInfo);
            SystemClock.sleep(200);
            if (verInfo.getResultCode() == UHFReaderResult.ResultCode.CODE_SUCCESS) {
                if (verInfo.getData().getHardwareVersion().startsWith("32") || verInfo.getData().getHardwareVersion().startsWith("31") || verInfo.getData().getHardwareVersion().startsWith("33")) {
                    builderAnalysisSLR = new BuilderAnalysisSLR_E710();
//                    builderAnalysisSLR = new BuilderAnalysisSLR();
                    DeviceConfigManage.module_type = "E710";
                } else {
                }
//                hcPowerCtrl.identityPower(0);
//                hcPowerCtrl.identityCtrl(0);
                break;
            } else {
//                UHFSerialPort.getInstance().close();
                SystemClock.sleep(100);
                if (isWK0) {
                    uhfConfig.setUhfUart("/dev/ttysWK0");
                } else {
                    uhfConfig.setUhfUart("/dev/ttysWK1");
                }
                Log.e(TAG, "connect: - -  " +uhfConfig.getUhfUart() );
                boolean result2 = UHFSerialPort.getInstance().open(uhfConfig.getUhfUart(), uhfProtocolAnalysisSLR, baudrate);
                LoggerUtils.d(TAG, "=" + result2 + "  Uart=" + uhfConfig.getUhfUart() + "  baudrate=" + baudrate);
                if (!result2) {

                    return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_OPEN_SERIAL_PORT_FAILURE, UHFReaderResult.ResultMessage.OPEN_SERIAL_PORT_FAILURE, false);
                }
                SystemClock.sleep(80);
                sendData(DataConverter.hexToBytes("FF00041D0B"));
                SystemClock.sleep(400);

                UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo2 = sendAndReceiveData(builderAnalysisSLR.makeGetVersionSendData());
                verInfo = builderAnalysisSLR.analysisVersionData(dataFrameInfo2);
                SystemClock.sleep(200);
                if (verInfo.getResultCode() == UHFReaderResult.ResultCode.CODE_SUCCESS) {
                    if (verInfo.getData().getHardwareVersion().startsWith("32") || verInfo.getData().getHardwareVersion().startsWith("31") || verInfo.getData().getHardwareVersion().startsWith("33")) {
                        builderAnalysisSLR = new BuilderAnalysisSLR_E710();
//                        builderAnalysisSLR = new BuilderAnalysisSLR();
                        LoggerUtils.d(TAG, "E710----");
                        DeviceConfigManage.module_type = "E710";
                    } else {
                        LoggerUtils.d(TAG, " 非EE710");
                    }
                    break;
                } else {
//                    hcPowerCtrl.uhfPower(0);
//                    hcPowerCtrl.uhfCtrl(0);
                }
            }
            UHFSerialPort.getInstance().close();
        }

        if (verInfo.getResultCode() != UHFReaderResult.ResultCode.CODE_SUCCESS) {
            disConnect();
            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE, "Failed!");
        } else {
            UHFVersionInfo uhfVersionInfo = verInfo.getData();
            String hver = uhfVersionInfo.getHardwareVersion();
            String firmwareVersion = uhfVersionInfo.getFirmwareVersion();
            if (hver.startsWith("A1")) {
                LoggerUtils.d(TAG, "R2000");
                DeviceConfigManage.module_type = "R2000";
                is5300 = false;
                isR2000 = true;
                iuhfReader = new UHFReaderSLR1200(uhfProtocolAnalysisSLR, builderAnalysisSLR);
            } else if (hver.startsWith("31") || hver.startsWith("33") || hver.startsWith("32")) {

                // iuhfReader=new ...
                if (hver.startsWith("33")) {
                    DeviceConfigManage.module_type = "E310";
                } else {
                    DeviceConfigManage.module_type = "E710";
                }
                if (hver.startsWith("32")) {
                    DeviceConfigManage.module_type = "E510";
                }
                isR2000 = false;
                is5300 = false;
                iuhfReader = new UHFReaderSLR1200(uhfProtocolAnalysisSLR, builderAnalysisSLR);
            } else if (hver.startsWith("A6") || hver.startsWith("A3")) {
                LoggerUtils.d(TAG, "5300");
                if (hver.startsWith("A6")) {
                    DeviceConfigManage.module_type = "5100";
                } else {
                    DeviceConfigManage.module_type = "5300";
                }
                is5300 = true;
                iuhfReader = new UHFReaderSLR1200(uhfProtocolAnalysisSLR, builderAnalysisSLR);

            }
        }
        if (iuhfReader == null) {
            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE);
        }
        ((UHFReaderBase) iuhfReader).setConnectState(ConnectState.CONNECTED);
        return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS);
    }

    @Override
    public UHFReaderResult disConnect() {
        stopInventory();
        hcPowerCtrl.uhfPower(0);
        hcPowerCtrl.uhfCtrl(0);
        hcPowerCtrl.identityCtrl(0);
        hcPowerCtrl.identityPower(0);
        LoggerUtils.d("CHLOG", "---------------");
        UHFSerialPort.getInstance().close();
        if (iuhfReader != null) {
            ((UHFReaderBase) iuhfReader).setConnectState(ConnectState.DISCONNECT);
        }
        return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_SUCCESS);
    }

    @Override
    public UHFReaderResult<Boolean> startInventory(SelectEntity selectEntity) {
        return iuhfReader.startInventory(selectEntity);
    }

    @Override
    public UHFReaderResult<Boolean> stopInventory() {
        if (iuhfReader == null) {
            Log.e("TAG", "stopInventory: ");
            return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE, "");
        }

        return iuhfReader.stopInventory();
    }

    @Override
    public UHFReaderResult<UHFTagEntity> singleTagInventory(SelectEntity selectEntity) {
        return iuhfReader.singleTagInventory(selectEntity);
    }

    @Override
    public UHFReaderResult<Boolean> setInventorySelectEntity(SelectEntity selectEntity) {
        return iuhfReader.setInventorySelectEntity(selectEntity);
    }

    @Override
    public ConnectState getConnectState() {
        if (iuhfReader == null) {
            return ConnectState.DISCONNECT;
        }
        return iuhfReader.getConnectState();
    }

    @Override
    public UHFReaderResult<UHFVersionInfo> getVersions() {
        return iuhfReader.getVersions();
    }

    @Override
    public UHFReaderResult<Boolean> setSession(UHFSession vlaue) {
        return iuhfReader.setSession(vlaue);
    }

    @Override
    public UHFReaderResult<UHFSession> getSession() {
        return iuhfReader.getSession();
    }

    @Override
    public UHFReaderResult<Boolean> setDynamicTarget(int vlaue) {
        return iuhfReader.setDynamicTarget(vlaue);
    }

    @Override
    public UHFReaderResult<Boolean> setStaticTarget(int vlaue) {
        return iuhfReader.setStaticTarget(vlaue);
    }

    @Override
    public UHFReaderResult<int[]> getTarget() {
        return iuhfReader.getTarget();
    }

    @Override
    public UHFReaderResult<Boolean> setInventoryModeForPower(InventoryModeForPower modeForPower) {
        return iuhfReader.setInventoryModeForPower(modeForPower);
    }

    @Override
    public void setOnInventoryDataListener(OnInventoryDataListener onInventoryDataListener) {
        iuhfReader.setOnInventoryDataListener(onInventoryDataListener);
    }

    @Override
    public UHFReaderResult<Boolean> setPower(int power) {
        return iuhfReader.setPower(power);
    }

    @Override
    public UHFReaderResult<Integer> getPower() {
        return iuhfReader.getPower();
    }

    @Override
    public UHFReaderResult<Boolean> setModuleType(String moduleType) {
        return null;
    }

    @Override
    public UHFReaderResult<String> getModuleType() {
        return null;
    }


    @Override
    public UHFReaderResult<Boolean> setFrequencyRegion(int region) {
        return iuhfReader.setFrequencyRegion(region);
    }

    @Override
    public UHFReaderResult<Integer> getFrequencyRegion() {
        return iuhfReader.getFrequencyRegion();
    }

    @Override
    public UHFReaderResult<Integer> getTemperature() {
        return iuhfReader.getTemperature();
    }

    @Override
    public UHFReaderResult<String> read(String password, int membank, int address, int wordCount, SelectEntity selectEntity) {
        return iuhfReader.read(password, membank, address, wordCount, selectEntity);
    }

    @Override
    public UHFReaderResult<Boolean> write(String password, int membank, int address, int wordCount, String data, SelectEntity selectEntity) {
        return iuhfReader.write(password, membank, address, wordCount, data, selectEntity);
    }

    @Override
    public UHFReaderResult<Boolean> kill(String password, SelectEntity selectEntity) {
        return iuhfReader.kill(password, selectEntity);
    }

    @Override
    public UHFReaderResult<Boolean> lock(String password, LockMembankEnum hexMask, LockActionEnum hexAction, SelectEntity selectEntity) {
        return iuhfReader.lock(password, hexMask, hexAction, selectEntity);
    }

    @Override
    public UHFReaderResult<Boolean> setBaudRate(int baudRate) {
        return iuhfReader.setBaudRate(baudRate);
    }

    @Override
    public UHFReaderResult<Boolean> setFrequencyPoint(int baudRate) {
        return iuhfReader.setFrequencyPoint(baudRate);
    }

    @Override
    public UHFReaderResult<Boolean> setRFLink(int mode) {
        return iuhfReader.setRFLink(mode);
    }


    private boolean sendData(byte[] data) {
        return UHFSerialPort.getInstance().send(data);
    }

    private UHFProtocolAnalysisBase.DataFrameInfo sendAndReceiveData(byte[] sData) {
        if (!sendData(sData)) {
            return null;
        }
        int timeOut = 1000;
        int cmd = sData[2] & 0xFF;
        return uhfProtocolAnalysisSLR.getOtherInfo(cmd, timeOut);
    }
}


