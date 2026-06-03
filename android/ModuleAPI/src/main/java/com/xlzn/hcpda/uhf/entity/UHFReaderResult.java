package com.xlzn.hcpda.uhf.entity;


public class UHFReaderResult<T> {


    public class ResultCode{

        public static final int CODE_SUCCESS=0;

        public static final int CODE_FAILURE=1;

        public static final int CODE_READER_NOT_CONNECTED=2;

        public static final int CODE_OPEN_SERIAL_PORT_FAILURE=3;

        public static final int CODE_POWER_ON_FAILURE=4;

    }


    public class ResultMessage{
        //uhf.
        public static final String READER_NOT_CONNECTED="UHF Not Connected";
        public static final String OPEN_SERIAL_PORT_FAILURE="Failed";
        public static final String CODE_POWER_ON_FAILURE="!";
    }
    public UHFReaderResult(int resultCode){
        this.resultCode=resultCode;
    }
    public UHFReaderResult(int resultCode,String message){
        this.resultCode=resultCode;
        this.message=message;
    }
    public UHFReaderResult(int resultCode,String msg,T data){
        this.resultCode=resultCode;
        this.message=message;
        this.data=data;
    }

    private int resultCode;

    private T data;

    private String message;

    public int getResultCode() {
        return resultCode;
    }

    public void setResultCode(int resultCode) {
        this.resultCode = resultCode;
    }


    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
