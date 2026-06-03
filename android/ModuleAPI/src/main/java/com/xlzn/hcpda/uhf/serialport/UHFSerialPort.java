package com.xlzn.hcpda.uhf.serialport;

import com.xlzn.hcpda.SerialPort;
import com.xlzn.hcpda.utils.DataConverter;
import com.xlzn.hcpda.utils.LoggerUtils;
import com.xlzn.hcpda.uhf.interfaces.IUHFProtocolAnalysis;

public class UHFSerialPort {
    private String TAG="UHFSerialPort";
    private int uart_fd=-1;
    private SerialPort serialPort=new SerialPort();
    private static UHFSerialPort uhfSerialPort=new UHFSerialPort();
    private ReadThread readThread=null;
    private IUHFProtocolAnalysis iuhfProtocolAnalysis=null;

    public static UHFSerialPort getInstance(){
        return uhfSerialPort;
    }
    public void setIUHFProtocolAnalysis(IUHFProtocolAnalysis iuhfProtocolAnalysis){
        this.iuhfProtocolAnalysis=iuhfProtocolAnalysis;
    }
    public boolean open(String uart,int baudrate, int databits,int stopbits, int parity,IUHFProtocolAnalysis iuhfProtocolAnalysis){
        this.iuhfProtocolAnalysis=iuhfProtocolAnalysis;
        uart_fd= serialPort.open(  uart,   baudrate,   databits,   stopbits,   parity);
        if(uart_fd>=0){
            startThread();
            return true;
        }
        return false;
    }
    public boolean open(String uart,IUHFProtocolAnalysis iuhfProtocolAnalysis,int baudrate){
        int databits=8;
        int stopbits=1;
        int parity=0;
        return open(uart,baudrate,databits,stopbits,parity,iuhfProtocolAnalysis);
    }
    public boolean open(String uart,IUHFProtocolAnalysis iuhfProtocolAnalysis){
        int baudrate=115200;
        int databits=8;
        int stopbits=1;
        int parity=0;
        return open(uart,baudrate,databits,stopbits,parity,iuhfProtocolAnalysis);
    }
    public boolean close(){
        serialPort.close(uart_fd);
        stopThread();
        return true;
    }
    public boolean send(byte[] data){
        if(LoggerUtils.isDebug()){
            LoggerUtils.d(TAG,""+ DataConverter.bytesToHex(data));
        }
       return serialPort.send(uart_fd,data);
    }

    public byte[] receive() {
        return serialPort.receive(uart_fd);
    }

    private void startThread(){
        if(readThread==null){
            readThread=new ReadThread();
            readThread.start();
        }
    }
    private void stopThread(){
        if(readThread!=null){
            readThread.stopThread();
            readThread=null;
        }
    }

    class ReadThread extends Thread{
        private boolean isSop=false;
        Object lock=new Object();
        public void run(){
             while (!isSop){
                byte[] data=receive();
                if(data==null){
                    synchronized (lock){
                        try {
                            lock.wait(5);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                }else{
                    if(LoggerUtils.isDebug())LoggerUtils.d(TAG,"data=>"+ DataConverter.bytesToHex(data));

                    if(iuhfProtocolAnalysis!=null){
                        iuhfProtocolAnalysis.analysis(data);
                    }
                }
             }
        }
        public void stopThread(){
            isSop=true;
            synchronized (lock){
                lock.notifyAll();
            }
        }
    }
}
