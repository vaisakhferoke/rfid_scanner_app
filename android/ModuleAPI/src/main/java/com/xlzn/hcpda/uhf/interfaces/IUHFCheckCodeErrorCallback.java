package com.xlzn.hcpda.uhf.interfaces;

public interface IUHFCheckCodeErrorCallback {

    public void checkCodeError(int mode,int cmd,byte[] errorData);
}
