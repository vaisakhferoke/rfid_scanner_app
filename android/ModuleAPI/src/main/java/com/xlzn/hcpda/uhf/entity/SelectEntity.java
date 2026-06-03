package com.xlzn.hcpda.uhf.entity;


public class SelectEntity {

    public static final int OPTION_EPC=4;
    public static final int OPTION_TID=2;
    public static final int OPTION_USER=3;

    //：bit
    private int address;
    //：bit
    private int  length;
    private String data;
    //2:tid  3:user  4:epc
    private int option;


    public int getAddress() {
        return address;
    }


    public void setAddress(int address) {
        this.address = address;
    }

    public int getLength() {
        return length;
    }

    public void setLength(int length) {
        this.length = length;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public int getOption() {
        return option;
    }

    public void setOption(int option) {
        this.option = option;
    }

}
