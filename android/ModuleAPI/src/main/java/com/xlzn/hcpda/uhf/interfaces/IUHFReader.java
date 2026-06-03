package com.xlzn.hcpda.uhf.interfaces;

import android.content.Context;

import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFTagEntity;
import com.xlzn.hcpda.uhf.entity.UHFVersionInfo;
import com.xlzn.hcpda.uhf.enums.ConnectState;
import com.xlzn.hcpda.uhf.enums.InventoryModeForPower;
import com.xlzn.hcpda.uhf.enums.LockActionEnum;
import com.xlzn.hcpda.uhf.enums.LockMembankEnum;
import com.xlzn.hcpda.uhf.enums.UHFSession;

public interface IUHFReader {
    public UHFReaderResult<Boolean> setInventoryTid(boolean flag);
    public UHFReaderResult<Boolean> getInventoryTidModel();
    public UHFReaderResult<Boolean> connect(Context context);
    public UHFReaderResult<Boolean> disConnect();

    public UHFReaderResult<Boolean> startInventory(SelectEntity selectEntity);
    public UHFReaderResult<Boolean> stopInventory();
    public UHFReaderResult<UHFTagEntity> singleTagInventory(SelectEntity selectEntity);

    public UHFReaderResult<Boolean> setInventorySelectEntity(SelectEntity selectEntity);
    public ConnectState getConnectState();
    public UHFReaderResult<UHFVersionInfo> getVersions();
    public UHFReaderResult<Boolean> setSession(UHFSession vlaue);
    public UHFReaderResult<UHFSession> getSession();
    public UHFReaderResult<Boolean> setDynamicTarget(int value);
    public UHFReaderResult<Boolean> setStaticTarget(int value);
    public UHFReaderResult<int[]> getTarget();
    public UHFReaderResult<Boolean> setInventoryModeForPower(InventoryModeForPower modeForPower);
    public void setOnInventoryDataListener(OnInventoryDataListener onInventoryDataListener);
    public UHFReaderResult<Boolean> setPower(int power);
    public UHFReaderResult<Integer> getPower();

    //
    public UHFReaderResult<Boolean> setModuleType(String moduleType);
    public UHFReaderResult<String> getModuleType();




    public UHFReaderResult<Boolean> setFrequencyRegion(int region);
    public UHFReaderResult<Integer> getFrequencyRegion();
    public UHFReaderResult<Integer> getTemperature();
    public UHFReaderResult<String> read(String password,int membank,int address,int wordCount,SelectEntity selectEntity);
    public UHFReaderResult<Boolean> write(String password,int membank,int address,int wordCount,String data,SelectEntity selectEntity);
    public UHFReaderResult<Boolean> kill(String password,SelectEntity selectEntity);
    //lock
    public UHFReaderResult<Boolean> lock(String password, LockMembankEnum hexMask, LockActionEnum hexAction, SelectEntity selectEntity);

    public UHFReaderResult<Boolean> setBaudRate(int baudRate);

    public UHFReaderResult<Boolean> setFrequencyPoint(int baudRate);
    public UHFReaderResult<Boolean> setRFLink(int mode);
}
