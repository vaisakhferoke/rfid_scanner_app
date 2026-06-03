package com.xlzn.hcpda.uhf.entity;

import java.math.BigInteger;


public class UHFTagEntity implements Comparable<UHFTagEntity>{
//public class UHFTagEntity  {
    private String tidHex;
    private String ecpHex;
    private String pcHex;
    private String userHex;
    private int rssi;
    private int ant;
    private int count;


    public String getUserHex() {
        return userHex;
    }

    public void setUserHex(String userHex) {
        this.userHex = userHex;
    }


    public String getEcpHex() {
        return ecpHex;
    }

    public void setEcpHex(String ecpHex) {
        this.ecpHex = ecpHex;
    }

    public String getPcHex() {
        return pcHex;
    }

    public void setPcHex(String pcHex) {
        this.pcHex = pcHex;
    }

    public int getRssi() {
        return rssi;
    }

    public void setRssi(int rssi) {
        this.rssi = rssi;
    }

    public int getAnt() {
        return ant;
    }

    public void setAnt(int ant) {
        this.ant = ant;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public String getTidHex() {
        return tidHex;
    }

    public void setTidHex(String tidHex) {
        this.tidHex = tidHex;
    }

    @Override
    public int compareTo(UHFTagEntity o) {

        String ecpHex = getEcpHex();
        String ecpHex2 = o.getEcpHex();
        BigInteger one = new BigInteger(ecpHex,16);
        BigInteger two = new BigInteger(ecpHex2,16);

//        one.compareTo(two);
        return one.compareTo(two);
    }
}
