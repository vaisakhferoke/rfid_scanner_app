package com.xlzn.hcpda.uhf.interfaces;

import com.xlzn.hcpda.uhf.analysis.UHFProtocolAnalysisBase;

public interface IUHFProtocolAnalysis {

    public void analysis(byte[] data);

    public void setCheckCodeErrorCallback(IUHFCheckCodeErrorCallback iuhfCheckCodeErrorCallback);

    public UHFProtocolAnalysisBase.DataFrameInfo getTagInfo();

    public UHFProtocolAnalysisBase.DataFrameInfo getOtherInfo(int cmd, int timeOut);

    public void cleanTagInfo();
}
