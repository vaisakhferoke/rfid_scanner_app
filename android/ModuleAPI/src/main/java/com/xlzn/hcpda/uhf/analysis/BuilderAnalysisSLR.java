package com.xlzn.hcpda.uhf.analysis;

import android.util.Log;

import com.xlzn.hcpda.ModuleAPI;
import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFTagEntity;
import com.xlzn.hcpda.uhf.entity.UHFVersionInfo;
import com.xlzn.hcpda.uhf.enums.LockActionEnum;
import com.xlzn.hcpda.uhf.enums.LockMembankEnum;
import com.xlzn.hcpda.uhf.enums.UHFSession;
import com.xlzn.hcpda.uhf.interfaces.IBuilderAnalysis;
import com.xlzn.hcpda.uhf.module.UHFReaderSLR;
import com.xlzn.hcpda.utils.DataConverter;
import com.xlzn.hcpda.utils.LoggerUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class BuilderAnalysisSLR implements IBuilderAnalysis {
    private String TAG = "BuilderAnalysisSLR";
    public boolean isTID = false;
    public boolean isAB = false;


    @Override
    public byte[] makeSingleTagInventorySendData(SelectEntity selectEntity) {
        if (selectEntity == null) {
            byte[] data = new byte[5];
            //Timeout
            data[0] = 0x01;
            data[1] = (byte) 0xE8;
            //Option
            data[2] = 0x10;
            //Metadata Flags
            data[3] = 0x00;
            data[4] = 0x06;//ant+RSSI
            return buildSendData(0x21, data);
        }

        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }

        byte[] data = new byte[10 + len];
        //Timeout
        data[0] = 0x01;
        data[1] = (byte) 0xE8;
        //Option
        data[2] = (byte) (selectEntity.getOption() + 0x10);
        //Metadata Flags
        data[3] = 0x00;
        data[4] = 0x06;//ant+RSSI

        // Select Address(bits)
        int address = selectEntity.getAddress();
        data[5] = (byte) ((address >> 24) & 0xFF);
        data[6] = (byte) ((address >> 16) & 0xFF);
        data[7] = (byte) ((address >> 8) & 0xFF);
        data[8] = (byte) (address & 0xFF);
        //Select data length(bits)
        data[9] = (byte) selectEntity.getLength();
        //Select data
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());

        for (int k = 0; k < len; k++) {
            data[10 + k] = byteData[k];
        }

        return buildSendData(0x21, data);
    }

    @Override
    public UHFReaderResult<UHFTagEntity> analysisSingleTagInventoryResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null) {
            if (data.status == 00) {
                //   Length       Status   Option       rssi  ant        epc                                   epc crc      crc
                //FF 13       21   00 00   10     0006  D1    11   E2 80 68 94 00 00 40 0C 6E E2 FE 08    8F 77       92F2
                //FF 13       21   00 00   14     0006  D0    11   E2 80 68 94 00 00 50 0C 6E E2 FE 06    74 3D       AA1B
//                LoggerUtils.d(TAG, "单标签盘点指令返回Data:" + DataConverter.bytesToHex(data.data));
                byte[] bytes = data.data;
                int rssi = bytes[3];
                int ant = (bytes[4] & 0xFF) >> 4;
                byte[] epcbytes = Arrays.copyOfRange(bytes, 5, bytes.length - 2);
                UHFTagEntity uhfTagEntity = new UHFTagEntity();
                uhfTagEntity.setEcpHex(DataConverter.bytesToHex(epcbytes));
                uhfTagEntity.setCount(1);
                uhfTagEntity.setAnt(ant);
                uhfTagEntity.setRssi(rssi);
                return new UHFReaderResult<UHFTagEntity>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", uhfTagEntity);
            }
        }
        return new UHFReaderResult<UHFTagEntity>(UHFReaderResult.ResultCode.CODE_FAILURE, "", null);
    }


    @Override
    public byte[] makeInventorySelectEntity(SelectEntity selectEntity) {
        //FF+DATALEN+AA+”Moduletech”+AA+4C+data+SubCrc+bb+CRC


        byte[] senddata = new byte[512];
        byte[] moduletech = "Moduletech".getBytes();
        //************Moduletech*************
        System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
        //***********SubCmdHighByte+SubCmdLowByte************
        int index = moduletech.length;
        int subcrcIndex = index;
        senddata[index++] = (byte) 0xAA;
        senddata[index++] = (byte) 0x4C;
        //************data*******************
        //-----SELFLAG----
        senddata[index++] = (byte) 0xFF;
        senddata[index++] = (byte) 0xFF;
        //-----SELTAGCNT--------
        senddata[index++] = (byte) 1;
        //*******SELTAGDATAN****************************
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());
        int len = selectEntity.getLength() / 8;
        //selLEN+
        senddata[index++] = (byte) (len + 7);
        //selBANK+
        int selBANK = selectEntity.getOption();
        if (selBANK == 4) {
            selBANK = 1;
        }
        senddata[index++] = (byte) selBANK;
        //selADDR+
        int address = selectEntity.getAddress();
        senddata[index++] = (byte) ((address >> 24) & 0xFF);
        senddata[index++] = (byte) ((address >> 16) & 0xFF);
        senddata[index++] = (byte) ((address >> 8) & 0xFF);
        senddata[index++] = (byte) (address & 0xFF);
        //selbitsLEN+
        senddata[index++] = (byte) selectEntity.getLength();
        //Select data
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        for (int k = 0; k < len; k++) {
            senddata[index++] = byteData[k];
        }
        //****************SubCrc****************
        int subcrcTemp = 0;
        for (int k = subcrcIndex; k < index; k++) {
            subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
        }
        senddata[index++] = (byte) (subcrcTemp & 0xFF);
        //****************SubCrc****************
        senddata[index++] = (byte) 0xbb;
        //FF 22 AA 4D6F64756C6574656368  AA4C FFFF 01 13 01 00000020 60 E2000017030B020118205C16 87C7
        //FF 23 AA 4D6F64756C6574656368  AA4C FFFF 01 13 01 00000020 60 E2000017030B020118205C16 3D 4167
        return buildSendData(0XAA, Arrays.copyOf(senddata, index));
    }

    @Override
    public UHFReaderResult<Boolean> analysisInventorySelectEntityResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null) {
            if (data.status == 00) {
                //FF+DATALEN+AA+STATUS +”Moduletech”+AA+4C+data+CRC
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x4C) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }



    @Override
    public byte[] makeSetTargetModel(int model) {
        //FF 04 9B 05 01 00 00 A3 FD   A-B
        //FF 04 9B 05 01 01 00 A3 FD   A
        //FF 04 9B 05 01 01 01 A3 FD   B
        //FF 04 9B 05 01 00 01 A3 FD   B-B
        byte[] senddata = new byte[3];
        senddata[0] = (byte) 0x01;
        senddata[1] = (byte) 0x00;
        senddata[2] = (byte) 0x00;
//        senddata[3] = (byte) 0xff;
//        senddata[4] = (byte) 0xff;
        return buildSendData(0x05,senddata);
    }
    @Override
    public byte[] makeStartInventorySendData(SelectEntity selectEntity, boolean isTID) {
        LoggerUtils.d(TAG, "isTID=" + isTID);
        this.isTID = isTID;
        //FF 05 0x22 0x00 0x00 0x00 0x00 0xC8 xx xx;
        if (selectEntity == null) {
            if (isTID) {
                LoggerUtils.d(TAG, "TID");
                byte[] data = new byte[17];
                //Option
                data[0] = 0x00;
                //Search Flags
                data[1] = (byte) 0x00;
                data[2] = (byte) 0x04;
                // Timeout
                data[3] = 0x00;
                data[4] = (byte) 0x96;
                ;//  0x03E8(1000), 0x0320 (800) ,0x02BC (700) ,0x0258 (600),0x01F4(500),0x0190(400),0x012C(300), 0xC8(200),0x96(150),0x64(100)
                //嵌入命令数量，目前该值只能为1.
                data[5] = (byte) 0x01;
                //嵌入命令的数据域的字节长度。
                data[6] = (byte) 0x09;
                //嵌入的命令码。目前只能嵌入（0X28命令）
                data[7] = (byte) 0x28;
                //嵌入命令的数据域
                //Emb Cmd Timeout
                data[8] = (byte) 0x00;
                data[9] = (byte) 0x00;
                //Emb Cmd Option
                data[10] = (byte) 0x00;
                //Read Membank
                data[11] = (byte) 0x02;
                //Read Address
                data[12] = (byte) 0x00;
                data[13] = (byte) 0x00;
                data[14] = (byte) 0x00;
                data[15] = (byte) 0x00;
                //Read Word Count
                data[16] = (byte) 0x06;
                return buildSendData(0x22, data);
            }
            byte[] data = new byte[5];
            //Option
            data[0] = 0x00;
            //Search Flags
            data[1] = 0x00;
            data[2] = 0x00;
            // Timeout
            data[3] = 0x00;
            data[4] = (byte) 0x96;
            ;//  0x03E8(1000), 0x0320 (800) ,0x02BC (700) ,0x0258 (600),0x01F4(500),0x0190(400),0x012C(300), 0xC8(200),0x96(150),0x64(100)
            return buildSendData(0x22, data);
        }

        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        byte[] data = new byte[14 + len];
        data[0] = (byte) selectEntity.getOption();
        //Search Flags
        data[1] = 0x00;
        data[2] = 0x00;
        // Timeout
        data[3] = 0x00;
        data[4] = (byte) 0x96;
        //AccessPassword
        data[5] = 0x00;
        data[6] = 0x00;
        data[7] = 0x00;
        data[8] = 0x00;
        // Select Address(bits)
        int address = selectEntity.getAddress();
        data[9] = (byte) ((address >> 24) & 0xFF);
        data[10] = (byte) ((address >> 16) & 0xFF);
        data[11] = (byte) ((address >> 8) & 0xFF);
        data[12] = (byte) (address & 0xFF);
        //Select data length(bits)
        data[13] = (byte) selectEntity.getLength();
        //Select data
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());

        for (int k = 0; k < len; k++) {
            data[14 + k] = byteData[k];
        }
        return buildSendData(0x22, data);
    }


    @Override
    public UHFReaderResult<Integer> analysisStartInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null) {
            if (data.status == 0) {
                int tagCount = 0;
                //Search Flags
                if (((data.data[2] & 0xFF) >> 4) == 1) {
                    //标签数大于255,Tag Found为4个字节长度
                    tagCount = 256 + (data.data[6] & 0xFF);//第6,7个字节是标签张数
                } else {
                    tagCount = data.data[3] & 0xFF;//第四个字节是标签张数
                }

                return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", tagCount);
            }
        }
        return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    public byte[] makeStartFastModeInventorySendData(SelectEntity selectEntity, boolean isTID) {

        LoggerUtils.d(TAG,"------");
        if (selectEntity == null) {
            byte[] senddata = new byte[512];
            byte[] moduletech = "Moduletech".getBytes();
            //************Moduletech*************
            System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
            //***********SubCmdHighByte+SubCmdLowByte************
            int index = moduletech.length;
            int subcrcIndex = index;
            senddata[index++] = (byte) 0xAA;
            senddata[index++] = (byte) 0x48;//R2000

            //************data*******************
            //METADATAFLAG
            final int count = 0X0001;//Bit0
            final int rssi = 0x0002;//BIT1
            final int ant = 0X0004;//BIT2
            final int tagData = 0x0080;
            final int flag = count | rssi | ant | tagData;

            if (isTID) {
                senddata[index++] = (flag >> 8) & 0xFF;
                senddata[index++] = (byte) (flag & 0xFF);
                senddata[index++] = 0x00;//
                senddata[index++] = (0x00 | 0x10);
            } else {
                //            senddata[index++] = (flag >> 8) & 0xFF;
                senddata[index++] = 0x00;
//            senddata[index++] = (byte) (flag & 0xFF);
                senddata[index++] = 0x06;
                //OPTION
                senddata[index++] = 0x00;
//            senddata[index++] = (0x00 | 0x20);
                senddata[index++] = (byte) 0x90;//todo 0x00
            }


            if (!isTID) {
//                senddata[index++] = 0x00;
                senddata[index++] = 0x03;

            } else {

                senddata[index++] = 0x04;

                senddata[index++] = (byte) 0x01;

                senddata[index++] = (byte) 0x09;

                senddata[index++] = (byte) 0x28;

                //Emb Cmd Timeout
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                //Emb Cmd Option
                senddata[index++] = (byte) 0x00;
                //Read Membank
                senddata[index++] = (byte) 0x02;
                //Read Address
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                //Read Word Count
                senddata[index++] = (byte) 0x06;
            }

            //****************data****************
            //****************SubCrc****************
            int subcrcTemp = 0;
            for (int k = subcrcIndex; k < index; k++) {
                subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
            }
            senddata[index++] = (byte) (subcrcTemp & 0xFF);
            //****************SubCrc****************
            senddata[index++] = (byte) 0xbb;

            return buildSendData(0XAA, Arrays.copyOf(senddata, index));
        }

        byte[] senddata = new byte[512];
        byte[] moduletech = "Moduletech".getBytes();
        //************Moduletech*************
        System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
        //***********SubCmdHighByte+SubCmdLowByte************
        int index = moduletech.length;
        int subcrcIndex = index;
        senddata[index++] = (byte) 0xAA;
        senddata[index++] = (byte) 0x48;
        //************data*******************
        //METADATAFLAG
        final int count = 0X0001;//
        final int rssi = 0x0002;//BIT1
        final int ant = 0X0004;//BIT2
        final int flag = count | rssi | ant;
        senddata[index++] = (flag >> 8) & 0xFF;
        senddata[index++] = flag & 0xFF;
        //1.OPTION
        senddata[index++] = (byte) (selectEntity.getOption());
        senddata[index++] = (0x00 | 0x10);
        senddata[index++] = 0x00;
        //3. AccessPassword
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        //4. Select Address(bits)
        int address = selectEntity.getAddress();
        senddata[index++] = (byte) ((address >> 24) & 0xFF);
        senddata[index++] = (byte) ((address >> 16) & 0xFF);
        senddata[index++] = (byte) ((address >> 8) & 0xFF);
        senddata[index++] = (byte) (address & 0xFF);
        //Select data length(bits)
        senddata[index++] = (byte) selectEntity.getLength();
        //Select data
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        for (int k = 0; k < len; k++) {
            senddata[index++] = byteData[k];
        }

        //****************data****************
        //****************SubCrc****************
        int subcrcTemp = 0;
        for (int k = subcrcIndex; k < index; k++) {
            subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
        }
        senddata[index++] = (byte) (subcrcTemp & 0xFF);
        //****************SubCrc****************
        senddata[index++] = (byte) 0xbb;
        return buildSendData(0XAA, Arrays.copyOf(senddata, index));

    }

    @Override
    public byte[] makeStartFastModeInventorySendDataMoreTag(SelectEntity selectEntity, boolean isTID) {
        if (selectEntity == null) {
            byte[] senddata = new byte[512];
            byte[] moduletech = "Moduletech".getBytes();
            //************Moduletech*************
            System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
            //***********SubCmdHighByte+SubCmdLowByte************
            int index = moduletech.length;
            int subcrcIndex = index;
            senddata[index++] = (byte) 0xAA;
            senddata[index++] = (byte) 0x58;

            for (int k = 0; k < 20; k++) {
                senddata[index++] = (byte) 0x00;
            }

            //************data*******************
            //2METADATAFLAG
            final int count = 0X0001;//Bit0
            final int rssi = 0x0002;//BIT1
            final int ant = 0X0004;//BIT2
            final int tagData = 0x0080;//
//            final int flag = count | rssi | ant | tagData;
            final int flag = rssi | ant;
            senddata[index++] = (flag >> 8) & 0xFF;
            senddata[index++] = (byte) (flag & 0xFF);

            senddata[index++] = 0x00;
            senddata[index++] = (0x10);
            //senddata[index++] = 0x04;//todo 0x00
            if (!isTID) {
                senddata[index++] = 0x00;
            } else {
                senddata[index++] = 0x04;
                //**********************************************

                senddata[index++] = (byte) 0x01;

                senddata[index++] = (byte) 0x09;

                senddata[index++] = (byte) 0x28;

                //Emb Cmd Timeout
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                //Emb Cmd Option
                senddata[index++] = (byte) 0x00;
                //Read Membank
                senddata[index++] = (byte) 0x02;
                //Read Address
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                //Read Word Count
                senddata[index++] = (byte) 0x06;
            }

            //****************data****************
            //****************SubCrc****************
            int subcrcTemp = 0;
            for (int k = subcrcIndex; k < index; k++) {
                subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
            }
            senddata[index++] = (byte) (subcrcTemp & 0xFF);
            //****************SubCrc****************
            senddata[index++] = (byte) 0xbb;
            //FF 27 AA 4D 6F 64 75 6C 65 74 65 63 68 AA 58 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 05 BB B3 19
            byte[] senddataTT = new byte[512];

            return buildSendData(0XAA, Arrays.copyOf(senddata, index));
        }

        byte[] senddata = new byte[512];
        byte[] moduletech = "Moduletech".getBytes();
        //************Moduletech*************
        System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
        //***********SubCmdHighByte+SubCmdLowByte************
        int index = moduletech.length;
        int subcrcIndex = index;
        senddata[index++] = (byte) 0xAA;
        senddata[index++] = (byte) 0x58;

        for (int k = 0; k < 20; k++) {
            senddata[index++] = (byte) 0x00;
        }
        //************data*******************

        final int count = 0X0001;//Bit0
        final int rssi = 0x0002;//BIT1
        final int ant = 0X0004;//BIT2
        final int tagData = 0x0080;//
        final int flag = count | rssi | ant | tagData;
        senddata[index++] = (flag >> 8) & 0xFF;
        senddata[index++] = (byte) (flag & 0xFF);

        senddata[index++] = (byte) (selectEntity.getOption());
        senddata[index++] = (0x00 | 0x10);
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        //4. Select Address(bits)
        int address = selectEntity.getAddress();
        senddata[index++] = (byte) ((address >> 24) & 0xFF);
        senddata[index++] = (byte) ((address >> 16) & 0xFF);
        senddata[index++] = (byte) ((address >> 8) & 0xFF);
        senddata[index++] = (byte) (address & 0xFF);
        //Select data length(bits)
        senddata[index++] = (byte) selectEntity.getLength();
        //Select data
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        for (int k = 0; k < len; k++) {
            senddata[index++] = byteData[k];
        }

        //****************data****************
        //****************SubCrc****************
        int subcrcTemp = 0;
        for (int k = subcrcIndex; k < index; k++) {
            subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
        }
        senddata[index++] = (byte) (subcrcTemp & 0xFF);
        //****************SubCrc****************
        senddata[index++] = (byte) 0xbb;
        return buildSendData(0XAA, Arrays.copyOf(senddata, index));

    }

    @Override
    public byte[] makeStartFastModeInventorySendDataNeedTid(SelectEntity selectEntity, boolean isTID) {
        LoggerUtils.d(TAG,"---------------");
        if (!UHFReaderSLR.isR2000) {
            if (selectEntity != null) {
                if (isTID) {
                    return makeStartFastModeInventorySendDataNeedTid3(selectEntity, isTID);
                }
            }
        }

        if (selectEntity == null) {

            byte[] senddata = new byte[512];
            byte[] moduletech = "Moduletech".getBytes();
            //************Moduletech*************
            System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
            //***********SubCmdHighByte+SubCmdLowByte************
            int index = moduletech.length;
            int subcrcIndex = index;
            senddata[index++] = (byte) 0xAA;
            senddata[index++] = (byte) 0x48;//R2000

            //************data*******************
            //2METADATAFLAG
            final int count = 0X0001;//Bit0
            final int rssi = 0x0002;//BIT1
            final int ant = 0X0004;//BIT2
            final int tagData = 0x0080;//
            final int flag = count | rssi | ant | tagData;

            if (isTID) {
                senddata[index++] = (flag >> 8) & 0xFF;
                senddata[index++] = (byte) (flag & 0xFF);
                senddata[index++] = 0x00;
                senddata[index++] = (0x00 | 0x10);
            } else {
                //            senddata[index++] = (flag >> 8) & 0xFF;
                senddata[index++] = 0x00;
//            senddata[index++] = (byte) (flag & 0xFF);
                senddata[index++] = 0x06;
                //1字节OPTION
                senddata[index++] = 0x00;
                senddata[index++] = (byte) 0x90;//todo 0x00
            }


            if (!isTID) {
//                senddata[index++] = 0x00;
                senddata[index++] = 0x03;

            } else {

                senddata[index++] = 0x04;
                //**********************************************

                senddata[index++] = (byte) 0x01;

                senddata[index++] = (byte) 0x09;

                senddata[index++] = (byte) 0x28;

                //Emb Cmd Timeout
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                //Emb Cmd Option
                senddata[index++] = (byte) 0x00;
                //Read Membank
                senddata[index++] = (byte) 0x02;
                //Read Address
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                senddata[index++] = (byte) 0x00;
                //Read Word Count
                senddata[index++] = (byte) 0x06;
            }

            //****************data****************
            //****************SubCrc****************
            int subcrcTemp = 0;
            for (int k = subcrcIndex; k < index; k++) {
                subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
            }
            senddata[index++] = (byte) (subcrcTemp & 0xFF);
            //****************SubCrc****************
            senddata[index++] = (byte) 0xbb;
            return buildSendData(0XAA, Arrays.copyOf(senddata, index));
        }

        byte[] senddata = new byte[512];
        byte[] moduletech = "Moduletech".getBytes();
        //************Moduletech*************
        System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
        //***********SubCmdHighByte+SubCmdLowByte************
        int index = moduletech.length;
        int subcrcIndex = index;
        senddata[index++] = (byte) 0xAA;
        senddata[index++] = (byte) 0x48;
        //************data*******************
        //2METADATAFLAG
        final int count = 0X0001;//Bit0
        final int rssi = 0x0002;//BIT1
        final int ant = 0X0004;//BIT2
        final int flag = count | rssi | ant;
        senddata[index++] = (flag >> 8) & 0xFF;
        senddata[index++] = flag & 0xFF;
        //1.OPTION
        senddata[index++] = (byte) (selectEntity.getOption());
        senddata[index++] = (0x00 | 0x10);
        senddata[index++] = 0x00;

        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        int address = selectEntity.getAddress();
        senddata[index++] = (byte) ((address >> 24) & 0xFF);
        senddata[index++] = (byte) ((address >> 16) & 0xFF);
        senddata[index++] = (byte) ((address >> 8) & 0xFF);
        senddata[index++] = (byte) (address & 0xFF);
        //Select data length(bits)
        senddata[index++] = (byte) selectEntity.getLength();
        //Select data
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        for (int k = 0; k < len; k++) {
            senddata[index++] = byteData[k];
        }

        //****************data****************
        //****************SubCrc****************
        int subcrcTemp = 0;
        for (int k = subcrcIndex; k < index; k++) {
            subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
        }
        senddata[index++] = (byte) (subcrcTemp & 0xFF);
        //****************SubCrc****************
        senddata[index++] = (byte) 0xbb;
        return buildSendData(0XAA, Arrays.copyOf(senddata, index));

    }


    @Override
    public byte[] makeStartFastModeInventorySendDataNeedTid512(SelectEntity selectEntity, boolean isTID) {
        return new byte[0];
    }

    public byte[] makeStartFastModeInventorySendDataNeedTid3(SelectEntity selectEntity, boolean isTID) {
        if (selectEntity == null) {
            return null;
        }

        byte[] senddata = new byte[512];
        byte[] moduletech = "Moduletech".getBytes();
        //************Moduletech*************
        System.arraycopy(moduletech, 0, senddata, 0, moduletech.length);
        //***********SubCmdHighByte+SubCmdLowByte************
        int index = moduletech.length;
        int subcrcIndex = index;
        senddata[index++] = (byte) 0xAA;
        senddata[index++] = (byte) 0x48;
        //************data*******************
        //2METADATAFLAG
        senddata[index++] = 0x00;
        senddata[index++] = (byte) 0x87;
        //1.OPTION
        senddata[index++] = (byte) (selectEntity.getOption());
        senddata[index++] = 0x00;
        senddata[index++] = 0x04;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        int address = selectEntity.getAddress();
        senddata[index++] = (byte) ((address >> 24) & 0xFF);
        senddata[index++] = (byte) ((address >> 16) & 0xFF);
        senddata[index++] = (byte) ((address >> 8) & 0xFF);
        senddata[index++] = (byte) (address & 0xFF);
        //Select data length(bits)
        senddata[index++] = (byte) selectEntity.getLength();
        //Select data
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        for (int k = 0; k < len; k++) {
            senddata[index++] = byteData[k];
        }

        senddata[index++] = 0x01;
        senddata[index++] = 0x09;
        senddata[index++] = 0x28;

        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x02;

        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x06;

        //****************data****************
        //****************SubCrc****************
        int subcrcTemp = 0;
        for (int k = subcrcIndex; k < index; k++) {
            subcrcTemp = subcrcTemp + (senddata[k] & 0xFF);
        }
        senddata[index++] = (byte) (subcrcTemp & 0xFF);
        //****************SubCrc****************
        senddata[index++] = (byte) 0xbb;
        return buildSendData(0XAA, Arrays.copyOf(senddata, index));

    }

    public List<UHFTagEntity> analysisFastModeTagInfoReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data) {

        if (data != null) {
            //00 87 01 C9 11 00 60 E2 00 34 12 01 2F FC 00 0B 45 DE 87   103000E2000017010B014318405BA1B2F2
            if (data.status == 0) {
                LoggerUtils.d(TAG,"："+DataConverter.bytesToHex(data.data));





                byte[] taginfo = data.data;
                int statIndex = 2;
                List<UHFTagEntity> list = new ArrayList<>();
                int rssi = taginfo[statIndex++];
                byte[] dataLen = Arrays.copyOfRange(taginfo,3,5);
                int userLen = (int) (Long.parseLong(DataConverter.bytesToHex(dataLen), 16) / 8)-12;
                LoggerUtils.d(TAG, "user = " +userLen);

                int starAdd=statIndex+2;
                byte[] tidBytes=null;
                byte[] userBytes=null;
                byte[] epcBytes=null;
                int endAdd = starAdd + 12;
                tidBytes=Arrays.copyOfRange(taginfo,starAdd,endAdd);
                statIndex=endAdd;

                LoggerUtils.d(TAG," TID = " + DataConverter.bytesToHex(tidBytes));
                endAdd = userLen + statIndex;
                userBytes=Arrays.copyOfRange(taginfo,statIndex,endAdd);
                statIndex = endAdd;
                LoggerUtils.d(TAG," USER = " + DataConverter.bytesToHex(userBytes));
                int epcLen = taginfo[statIndex++];
                endAdd = Integer.parseInt(String.valueOf(epcLen), 10);
                LoggerUtils.d(TAG," epcLen = " + epcLen);

                LoggerUtils.d(TAG," statIndex  = " + statIndex );
                LoggerUtils.d(TAG," endAdd = " + endAdd);

                int epcEnd = endAdd+statIndex;
                LoggerUtils.d(TAG," epcEnd = " + epcEnd);
                epcBytes=Arrays.copyOfRange(taginfo,statIndex+2,epcEnd-2);
                LoggerUtils.d(TAG," EPC = " + DataConverter.bytesToHex(epcBytes));

                String epc = DataConverter.bytesToHex(epcBytes);
                String tid = DataConverter.bytesToHex(tidBytes);
                String user = DataConverter.bytesToHex(userBytes);


                UHFTagEntity uhfTagEntity = new UHFTagEntity();
                uhfTagEntity.setRssi(rssi);
                uhfTagEntity.setEcpHex(epc);
                uhfTagEntity.setTidHex(tid);
                uhfTagEntity.setCount(1);
                uhfTagEntity.setUserHex(user);
                list.add(uhfTagEntity);
                LoggerUtils.d(TAG,"--------------------------------------- " + epcEnd);


                return list;
            } //00 07 00 01    01  C9 11   00 80   30 00 E2 00 00 17 01 0B 00 50 17 50 61 70 BB 55
        }
        return null;
    }


    public List<UHFTagEntity> analysisFastModeTagInfoReceiveDataOld(UHFProtocolAnalysisBase.DataFrameInfo data) {

        if (data != null) {

            if (data.status == 0) {
                LoggerUtils.d(TAG, "2222222222 = " + DataConverter.bytesToHex(data.data));
                byte[] taginfo = data.data;
                int tagsTotal = taginfo[2] & 0xFF;//标签张数
                int statIndex = 3;
                List<UHFTagEntity> list = new ArrayList<>();
                for (int k = 0; k < tagsTotal; k++) {
                    int rssi = taginfo[statIndex++];   //RSSI
                    int ant = (taginfo[statIndex++] & 0xFF) >> 4; //
                    byte[] tidBytes = null;
                    int tidLen = ((taginfo[statIndex++] & 0xFF) << 8) | (taginfo[statIndex++] & 0xFF);//
                    if (tidLen > 0) {
                        tidLen = (tidLen / 8);
                        int starAdd = statIndex;
                        int endAdd = starAdd + tidLen;
                        tidBytes = Arrays.copyOfRange(taginfo, starAdd, endAdd);
                        statIndex = endAdd;
                    }
                    UHFTagEntity uhfTagEntity = new UHFTagEntity();
                    if (tidBytes != null) {
                        uhfTagEntity.setTidHex(DataConverter.bytesToHex(tidBytes));
                    } else {
                        if (isTID) {
                            continue;
                        }
                    }

                    int epcLen = (taginfo[statIndex++] & 0xFF);
                    byte[] pcBytes = new byte[]{
                            taginfo[statIndex++],
                            taginfo[statIndex++]
                    };
                    int epcIdLen = epcLen - 2 - 2;
                    byte[] epcBytes = new byte[epcIdLen];
                    for (int m = 0; m < epcIdLen; m++) {
                        epcBytes[m] = taginfo[statIndex++];
                    }
                    statIndex = statIndex + 2;

                    uhfTagEntity.setAnt(ant);
                    uhfTagEntity.setRssi(rssi);
                    uhfTagEntity.setCount(1);
                    uhfTagEntity.setEcpHex(DataConverter.bytesToHex(epcBytes));
                    if (uhfTagEntity.getEcpHex() == null) {
                        uhfTagEntity.setEcpHex("");
                    }
                    uhfTagEntity.setPcHex(DataConverter.bytesToHex(pcBytes));
                    list.add(uhfTagEntity);
                }
                if (list == null || list.size() < tagsTotal) {
                    LoggerUtils.d(TAG, "tagsTotal：" + tagsTotal + "  list.size()=" + list.size());
                }
                return list;
            } //00 07 00 01    01  C9 11   00 80   30 00 E2 00 00 17 01 0B 00 50 17 50 61 70 BB 55
        }
        return null;
    }

    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID) {
        this.isTID = isTID;
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                LoggerUtils.d(TAG, "开始盘点指令返回Data:" + DataConverter.bytesToHex(data.data));
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x48) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
                //4D 6F 64 75 6C 65 74 65 63 68 AA 48
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    @Override
    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveDataNeedTid(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID) {
        this.isTID = isTID;
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                LoggerUtils.d(TAG, "Data:" + DataConverter.bytesToHex(data.data));
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x48) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
                //4D 6F 64 75 6C 65 74 65 63 68 AA 48
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);

    }

    @Override
    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveDataNeedTidMoreTag(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID) {
        this.isTID = isTID;
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                LoggerUtils.d(TAG, "E710Data:" + DataConverter.bytesToHex(data.data));
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x58) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
                //4D 6F 64 75 6C 65 74 65 63 68 AA 48
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    public byte[] makeStopFastModeInventorySendData() {
        //FF+DATALEN+0XAA+”Moduletech”+AA+49+SubCrc+0xbb+CRC
        byte[] data = new byte[14];
        byte[] moduletech = "Moduletech".getBytes();
        System.arraycopy(moduletech, 0, data, 0, moduletech.length);
        data[10] = (byte) 0xAA;
        data[11] = (byte) 0x49;
        int subcrcTemp = 0xAA + 0x49;
        data[12] = (byte) (subcrcTemp & 0xFF);
        data[13] = (byte) 0xbb;
        return buildSendData(0XAA, data);
    }

    public UHFReaderResult<Boolean> analysisStopFastModeInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                LoggerUtils.d(TAG, "Data:" + DataConverter.bytesToHex(data.data));
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x49) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
            }
        }
        Log.e("TAG", "analysisStopFastModeInventoryReceiveData:22 = " +data  );
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    @Override
    public byte[] makeGetTagInfoSendData() {
        final int count = 0X0001;//Bit0置位即标签在盘存时间内被盘存到的次数将会返回
        final int rssi = 0x0002;//BIT1置位即标签的RSSI信号值将会被返回
        final int ant = 0X0004;//BIT2置位即标签 被盘存到时所用的天线 ID号将会被返回。（逻辑天线号）
        final int tagData = 0x0080;//返回嵌入命令内存数据
        final int flag = count | rssi | ant | tagData;
//
        byte[] data = new byte[3];
        data[0] = (byte) ((flag >> 8) & 0xFF);
        data[1] = (byte) (flag & 0xFF);//返回还没有被获取的标签信息
        data[2] = 0x00;
        //只获取标签次数+EPC数据+RSSI+天线号
        return buildSendData(0x29, data);
    }

    @Override
    public List<UHFTagEntity> analysisTagInfoReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data) {


        if (data != null) {
            if (data.status == 0) {

                byte[] taginfo = data.data;
                int tagsTotal = taginfo[3] & 0xFF;
                int statIndex = 4;

                List<UHFTagEntity> list = new ArrayList<>();
                for (int k = 0; k < tagsTotal; k++) {
                    int count = taginfo[statIndex] & 0xFF;//
                    int rssi = taginfo[++statIndex];   //RSSI
                    int ant = (taginfo[++statIndex] & 0xFF) >> 4;
                    byte[] tidBytes = null;
                    int tidLen = ((taginfo[++statIndex] & 0xFF) << 8) | (taginfo[++statIndex] & 0xFF);//嵌入命令的数据
                    if (tidLen > 0) {
                        tidLen = (tidLen / 8);
                        int starAdd = (++statIndex);
                        int endAdd = starAdd + tidLen;
                        tidBytes = Arrays.copyOfRange(taginfo, starAdd, endAdd);
                        statIndex = endAdd - 1;
                        // LoggerUtils.d(TAG, " statIndex："+statIndex);
                    }
                    int epcLen = ((taginfo[++statIndex] & 0xFF) << 8) | (taginfo[++statIndex] & 0xFF);   //EPC长度 包括:pc值+epc+epcCRC
                    // LoggerUtils.d(TAG, " epcLen："+epcLen);
                    byte[] pcBytes = new byte[]{
                            taginfo[++statIndex],
                            taginfo[++statIndex]
                    };
                    int epcIdLen = (epcLen / 8) - 2 - 2;
                    byte[] epcBytes = new byte[epcIdLen];
                    for (int m = 0; m < epcIdLen; m++) {
                        epcBytes[m] = taginfo[++statIndex];
                    }
                    statIndex = statIndex + 3;
                    UHFTagEntity uhfTagEntity = new UHFTagEntity();
                    if (tidBytes != null) {
                        uhfTagEntity.setTidHex(DataConverter.bytesToHex(tidBytes));
                    } else {
                        if (isTID) {
                            continue;
                        }
                    }
                    uhfTagEntity.setAnt(ant);
                    uhfTagEntity.setRssi(rssi);
                    uhfTagEntity.setCount(count);
                    uhfTagEntity.setEcpHex(DataConverter.bytesToHex(epcBytes));
                    if (uhfTagEntity.getEcpHex() == null) {
                        uhfTagEntity.setEcpHex("");
                    }
                    uhfTagEntity.setPcHex(DataConverter.bytesToHex(pcBytes));
                    list.add(uhfTagEntity);
                }
                return list;
            } //00 07 00 01    01  C9 11   00 80   30 00 E2 00 00 17 01 0B 00 50 17 50 61 70 BB 55
        }
        return null;
    }


    @Override
    public byte[] makeGetVersionSendData() {
        //FF  00	03	1D 0C
        return buildSendData(0x03, null);
    }

    @Override
    public UHFReaderResult<UHFVersionInfo> analysisVersionData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null) {
            if (data.status == 0) {
                byte[] version = data.data;
                //FF 14 03 00 00 15010400A1000201202007032007030000000010DEE7
                //BootLoader     Hardware      Firmware data   Firmware Version
                //15 01 04 00    A1 00 02 01   20 20 07 03      20 07 03 00         00000010DEE7
                // BootLoader Ver 0-3
                // Hardware Ver  4-7
                //Firmware data 8-11
                //Firmware Version 12-15   15 01 04 00 A1 00 02 01 20 20 07 03    20 07 03 00
                //Supported Protocol 16-19
                UHFVersionInfo versionInfo = new UHFVersionInfo();
                versionInfo.setFirmwareVersion(DataConverter.bytesToHex(Arrays.copyOfRange(version, 8, 12)));
                versionInfo.setHardwareVersion(DataConverter.bytesToHex(Arrays.copyOfRange(version, 4, 8)));

                return new UHFReaderResult<UHFVersionInfo>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", versionInfo);
            }
        }
        return new UHFReaderResult(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeSetSessionSendData(UHFSession value) {
        byte[] data = new byte[3];
        data[0] = 0x05;
        data[1] = 0x00;
        data[2] = (byte) value.getValue();
        return buildSendData(0x9B, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetSessionResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            LoggerUtils.d(TAG, "SetSession success");
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        LoggerUtils.d(TAG, "SetSession fail");
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }
    @Override
    public byte[] makeGetSessionSendData() {
        byte[] data = new byte[2];
        data[0] = 0x05;
        data[1] = 0x00;
        return buildSendData(0x6B, data);
    }

    @Override
    public UHFReaderResult<UHFSession> analysisGetSessionResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            if (data.data[0] == 0x05 && data.data[1] == 0x00) {
                return new UHFReaderResult<UHFSession>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", UHFSession.getValue(data.data[2]));
            }
        }
        return new UHFReaderResult<UHFSession>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeSetPowerSendData(int power) {
        power = power * 100;
        byte[] data = new byte[6];
        data[0] = 0x03;//potion
        data[1] = 0x01;//天线
        data[2] = (byte) ((power >> 8) & 0xff);//读功率
        data[3] = (byte) (power & 0xff);//读功率
        data[4] = (byte) ((power >> 8) & 0xff);//写功率
        data[5] = (byte) (power & 0xff);//写功率
        return buildSendData(0x91, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetPowerResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    @Override
    public byte[] makeGetPowerSendData() {
        byte[] data = new byte[1];
        data[0] = 0x03;
        return buildSendData(0x61, data);
    }

    @Override
    public UHFReaderResult<Integer> analysisGetPowerResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            byte[] temp = data.data;
            //Option
            //TX ant num
            int power = (((temp[2] & 0xFF) << 8) | (temp[3] & 0xFF)) / 100;
            //FF 29 61 00 00
            //03 01  0B B8  0B B8 0200000000030000000004000000000500000000060000000007000000000800000000B027

             /*
             if(temp!=null && temp.length==7){
                 int curr=((temp[1]&0xFF)<<8) | (temp[2]&0xFF);
                 int max=((temp[3]&0xFF)<<8) | (temp[4]&0xFF);
                 int min=((temp[5]&0xFF)<<8) | (temp[6]&0xFF);
             }
             */
            LoggerUtils.d(TAG, "power=" + power);
            return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", power);
        }
        return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_FAILURE, "", 0);
    }

    @Override
    public byte[] makeSetFrequencyRegionSendData(int FrequencyRegion) {
        byte[] data = new byte[1];
        data[0] = (byte) FrequencyRegion;
        return buildSendData(0x97, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetFrequencyRegionResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    @Override
    public byte[] makeGetFrequencyRegionSendData() {
        return buildSendData(0x67, null);
    }

    @Override
    public UHFReaderResult<Integer> analysisGetFrequencyRegionResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            int f = data.data[0] & 0xFF;
            return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", f);
        }
        return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_FAILURE, "", -1);
    }

    @Override
    public byte[] makeGetTemperatureSendData() {
        return buildSendData(0x72, null);
    }

    @Override
    public UHFReaderResult<Integer> analysisGetTemperatureResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            int f = data.data[0];
            return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", f);
        }
        return new UHFReaderResult<Integer>(UHFReaderResult.ResultCode.CODE_FAILURE, "", 0);
    }

    @Override
    public byte[] makeSetDynamicTargetSendData(int value) {
        byte[] data = new byte[4];
        data[0] = 0x05;
        data[1] = 0x01;
        data[2] = 0x00;
        data[3] = (byte) value;
        isAB = true;
        return buildSendData(0x9B, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetDynamicTargetResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    @Override
    public byte[] makeSetStaticTargetSendData(int value) {
        byte[] data = new byte[4];
        data[0] = 0x05;
        data[1] = 0x01;
        data[2] = 0x01;
        data[3] = (byte) value;
        return buildSendData(0x9B, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetStaticTargetResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }

    @Override
    public byte[] makeGetTargetSendData() {
        byte[] data = new byte[2];
        data[0] = 0x05;
        data[1] = 0x01;
        return buildSendData(0x6B, data);
    }

    @Override
    public UHFReaderResult<int[]> analysisGetTargetResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            if (data.data[0] == 0x05 && data.data[1] == 0x01) {
                return new UHFReaderResult<int[]>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", new int[]{data.data[2], data.data[3]});
            }
        }
        return new UHFReaderResult<int[]>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeReadSendData(String password, int membank, int address, int wordCount, SelectEntity selectEntity) {
        if (selectEntity == null) {
            byte[] data = new byte[13];
            data[0] = 0x07;//0x03; //timeout
            data[1] = (byte) 0xD0;//0xE8;//timeout
            data[2] = (byte) 0x05;//Option 0x00 不需要密码，  0x05 需要密码
            data[3] = (byte) membank;
            data[4] = (byte) ((address >> 24) & 0xFF);
            data[5] = (byte) ((address >> 16) & 0xFF);
            data[6] = (byte) ((address >> 8) & 0xFF);
            data[7] = (byte) (address & 0xFF);
            data[8] = (byte) wordCount;
            byte[] pwd = DataConverter.hexToBytes(password);
            data[9] = pwd[0];
            data[10] = pwd[1];
            data[11] = pwd[2];
            data[12] = pwd[3];
            return buildSendData(0x28, data);
        }
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }

        byte[] data = new byte[18 + len];
        data[0] = 0x03; //timeout
        data[1] = (byte) 0xE8;//timeout
        data[2] = (byte) selectEntity.getOption();//Option
        data[3] = (byte) membank;
        data[4] = (byte) ((address >> 24) & 0xFF);
        data[5] = (byte) ((address >> 16) & 0xFF);
        data[6] = (byte) ((address >> 8) & 0xFF);
        data[7] = (byte) (address & 0xFF);
        data[8] = (byte) wordCount;
        byte[] pwd = DataConverter.hexToBytes(password);
        data[9] = pwd[0];
        data[10] = pwd[1];
        data[11] = pwd[2];
        data[12] = pwd[3];
        data[13] = (byte) ((selectEntity.getAddress() >> 24) & 0xFF);//address
        data[14] = (byte) ((selectEntity.getAddress() >> 16) & 0xFF);//address
        data[15] = (byte) ((selectEntity.getAddress() >> 8) & 0xFF);//address
        data[16] = (byte) (selectEntity.getAddress() & 0xFF);//address
        data[17] = (byte) selectEntity.getLength();
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());

        for (int k = 0; k < len; k++) {
            data[18 + k] = byteData[k];
        }
        return buildSendData(0x28, data);
    }

    @Override
    public UHFReaderResult<String> analysisReadResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            byte[] tag = Arrays.copyOfRange(data.data, 1, data.data.length);
            return new UHFReaderResult<String>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", DataConverter.bytesToHex(tag));
        }
        return new UHFReaderResult<String>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeWriteSendData(String password, int membank, int address, int wordCount, String hexData, SelectEntity selectEntity) {

        if (hexData.length() / 4 > wordCount) {
            hexData = hexData.substring(0, wordCount * 4);
        }

        if (selectEntity == null) {
            byte[] byteData = DataConverter.hexToBytes(hexData);
            byte[] data = new byte[12 + byteData.length];
            data[0] = 0x07;//0x03; //timeout
            data[1] = (byte) 0xD0;//0xE8;//timeout
            data[2] = (byte) 0x05;//Option 0x00 不需要密码，  0x05 需要密码
            data[3] = (byte) ((address >> 24) & 0xFF);
            data[4] = (byte) ((address >> 16) & 0xFF);
            data[5] = (byte) ((address >> 8) & 0xFF);
            data[6] = (byte) (address & 0xFF);
            data[7] = (byte) membank;//写入的区域
            byte[] pwd = DataConverter.hexToBytes(password);
            data[8] = pwd[0];
            data[9] = pwd[1];
            data[10] = pwd[2];
            data[11] = pwd[3];
            for (int k = 0; k < byteData.length; k++) {
                data[12 + k] = byteData[k];
            }
            return buildSendData(0x24, data);
        }
        //------过滤的数据长度--------
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }

        byte[] byteData = DataConverter.hexToBytes(hexData);
        byte[] data = new byte[12 + 4 + 1 + byteData.length + len];
        data[0] = 0x03; //timeout
        data[1] = (byte) 0xE8;//timeout
        data[2] = (byte) selectEntity.getOption();//Option 0x00 不需要密码，  0x05 需要密码
        data[3] = (byte) ((address >> 24) & 0xFF);
        data[4] = (byte) ((address >> 16) & 0xFF);
        data[5] = (byte) ((address >> 8) & 0xFF);
        data[6] = (byte) (address & 0xFF);
        data[7] = (byte) membank;//写入的区域
        byte[] pwd = DataConverter.hexToBytes(password);
        data[8] = pwd[0];
        data[9] = pwd[1];
        data[10] = pwd[2];
        data[11] = pwd[3];

        //--------过滤-------------
        data[12] = (byte) ((selectEntity.getAddress() >> 24) & 0xFF);
        data[13] = (byte) ((selectEntity.getAddress() >> 16) & 0xFF);
        data[14] = (byte) ((selectEntity.getAddress() >> 8) & 0xFF);
        data[15] = (byte) (selectEntity.getAddress() & 0xFF);
        data[16] = (byte) selectEntity.getLength();
        byte[] selectData = DataConverter.hexToBytes(selectEntity.getData());
        for (int k = 0; k < len; k++) {
            data[17 + k] = selectData[k];
        }
        int index = 17 + len;
        for (int k = 0; k < byteData.length; k++) {
            data[index + k] = byteData[k];
        }
        return buildSendData(0x24, data);


    }

    @Override
    public UHFReaderResult<Boolean> analysisWriteResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeKillSendData(String password, SelectEntity selectEntity) {
        if (selectEntity == null) {
            byte[] data = new byte[8];
            data[0] = 0x03; //timeout
            data[1] = (byte) 0xE8;//timeout
            data[2] = (byte) 0x00;//只支持0x00
            byte[] pwd = DataConverter.hexToBytes(password);
            data[3] = pwd[0];
            data[4] = pwd[1];
            data[5] = pwd[2];
            data[6] = pwd[3];
            data[7] = 0x00;//RFU
            return buildSendData(0x26, data);
        }
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }

        byte[] data = new byte[13 + len];
        data[0] = 0x03; //timeout
        data[1] = (byte) 0xE8;//timeout
        data[2] = (byte) selectEntity.getOption();//Option
        byte[] pwd = DataConverter.hexToBytes(password);
        data[3] = pwd[0];
        data[4] = pwd[1];
        data[5] = pwd[2];
        data[6] = pwd[3];
        data[7] = 0x00;//RFU

        data[8] = (byte) ((selectEntity.getAddress() >> 24) & 0xFF);//address
        data[9] = (byte) ((selectEntity.getAddress() >> 16) & 0xFF);//address
        data[10] = (byte) ((selectEntity.getAddress() >> 8) & 0xFF);//address
        data[11] = (byte) (selectEntity.getAddress() & 0xFF);//address
        data[12] = (byte) selectEntity.getLength();
        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());

        for (int k = 0; k < len; k++) {
            data[13 + k] = byteData[k];
        }

        return buildSendData(0x26, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisKillResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeLockSendData(String password, LockMembankEnum membankEnum, LockActionEnum actionEnum, SelectEntity selectEntity) {
        byte[] membankByte = new byte[2];
        byte[] actionByte = new byte[2];
        switch (membankEnum) {
            case EPC:
                switch (actionEnum) {
                    case LOCK:
                        membankByte[0] = 32;
                        actionByte[0] = 32;
                        break;
                    case UNLOCK:
                        membankByte[0] = 32;
                        actionByte[0] = 0;
                        break;
                    case PERMANENT_LOCK:
                        membankByte[0] = 48;
                        actionByte[0] = 32;
                        break;
                    case PERMANENT_UNLOCK:
                        membankByte[0] = 48;
                        actionByte[0] = 16;
                        break;
                }
                break;
            case TID:
                switch (actionEnum) {
                    case LOCK:
                        membankByte[0] = 8;
                        actionByte[0] = 8;
                        break;
                    case UNLOCK:
                        membankByte[0] = 8;
                        actionByte[0] = 0;
                        break;
                    case PERMANENT_LOCK:
                        membankByte[0] = 12;
                        actionByte[0] = 12;
                        break;
                    case PERMANENT_UNLOCK:
                        membankByte[0] = 12;
                        actionByte[0] = 4;
                        break;
                }
                break;
            case USER:
                switch (actionEnum) {
                    case LOCK:
                        membankByte[0] = 2;
                        actionByte[0] = 2;
                        break;
                    case UNLOCK:
                        membankByte[0] = 2;
                        actionByte[0] = 0;
                        break;
                    case PERMANENT_LOCK:
                        membankByte[0] = 3;
                        actionByte[0] = 3;
                        break;
                    case PERMANENT_UNLOCK:
                        membankByte[0] = 3;
                        actionByte[0] = 1;
                        break;
                }
                break;
            case KillPwd:
                switch (actionEnum) {
                    case LOCK:
                        membankByte[1] = 2;
                        actionByte[1] = 2;
                        break;
                    case UNLOCK:
                        membankByte[1] = 2;
                        actionByte[1] = 0;
                        break;
                    case PERMANENT_LOCK:
                        membankByte[1] = 3;
                        actionByte[1] = 3;
                        break;
                    case PERMANENT_UNLOCK:
                        membankByte[1] = 3;
                        actionByte[1] = 1;
                        break;
                }

                break;
            case AccessPwd:
                switch (actionEnum) {
                    case LOCK:
                        membankByte[0] = (byte) 128;
                        actionByte[0] = (byte) 128;
                        break;
                    case UNLOCK:
                        membankByte[0] = (byte) 128;
                        actionByte[0] = 0;
                        break;
                    case PERMANENT_LOCK:
                        membankByte[0] = (byte) 192;
                        actionByte[0] = (byte) 192;
                        break;
                    case PERMANENT_UNLOCK:
                        membankByte[0] = (byte) 192;
                        actionByte[0] = 64;
                        break;
                }
                break;
        }

        //-------------------------------

        byte temp = membankByte[0];
        membankByte[0] = membankByte[1];
        membankByte[1] = temp;

        temp = actionByte[0];
        actionByte[0] = actionByte[1];
        actionByte[1] = temp;

        String hexMask = DataConverter.bytesToHex(membankByte);
        String hexAction = DataConverter.bytesToHex(actionByte);
        LoggerUtils.d(TAG, "lock hexMask=" + hexMask);
        LoggerUtils.d(TAG, "lock hexAction=" + hexAction);

        if (selectEntity == null) {
            byte[] data = new byte[11];
            data[0] = 0x03; //timeout
            data[1] = (byte) 0xE8;//timeout
            data[2] = (byte) 0x00;//只支持0x00
            byte[] pwd = DataConverter.hexToBytes(password);
            data[3] = pwd[0];
            data[4] = pwd[1];
            data[5] = pwd[2];
            data[6] = pwd[3];
            byte[] byteMask = DataConverter.hexToBytes(hexMask);
            data[7] = byteMask[0];
            data[8] = byteMask[1];
            byte[] byteAction = DataConverter.hexToBytes(hexAction);
            data[9] = byteAction[0];
            data[10] = byteAction[1];
            return buildSendData(0x25, data);
        }
        int len = selectEntity.getLength() / 8;
        if (selectEntity.getLength() % 8 != 0) {
            len += 1;
        }
        byte[] data = new byte[16 + len];
        data[0] = 0x03; //timeout
        data[1] = (byte) 0xE8;//timeout
        data[2] = (byte) selectEntity.getOption();
        byte[] pwd = DataConverter.hexToBytes(password);
        data[3] = pwd[0];
        data[4] = pwd[1];
        data[5] = pwd[2];
        data[6] = pwd[3];
        byte[] byteMask = DataConverter.hexToBytes(hexMask);
        data[7] = byteMask[0];
        data[8] = byteMask[1];
        byte[] byteAction = DataConverter.hexToBytes(hexAction);
        data[9] = byteAction[0];
        data[10] = byteAction[1];

        data[11] = (byte) ((selectEntity.getAddress() >> 24) & 0xFF);//address
        data[12] = (byte) ((selectEntity.getAddress() >> 16) & 0xFF);//address
        data[13] = (byte) ((selectEntity.getAddress() >> 8) & 0xFF);//address
        data[14] = (byte) (selectEntity.getAddress() & 0xFF);//address
        data[15] = (byte) selectEntity.getLength();

        byte[] byteData = DataConverter.hexToBytes(selectEntity.getData());
        for (int k = 0; k < len; k++) {
            data[16 + k] = byteData[k];
        }

        return buildSendData(0x25, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisLockResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    public byte[] buildSendData(int cmd, byte[] data) {
        LoggerUtils.d(TAG,"-------"+DataConverter.bytesToHex(data));
        int index = 0;
        if (data != null && data.length > 0) {
            byte[] sendData = new byte[5 + data.length];
            sendData[index++] = (byte) 0xFF;
            sendData[index++] = (byte) data.length;
            sendData[index++] = (byte) cmd;
            for (int k = 0; k < data.length; k++) {
                sendData[index++] = data[k];
            }
            byte[] crc = new byte[2];
            //需要校验的数据
            byte[] check = Arrays.copyOfRange(sendData, 1, 1 + 1 + 1 + data.length);
            ModuleAPI.getInstance().CalcCRC(check, check.length, crc);
            sendData[index++] = crc[0];
            sendData[index++] = crc[1];
            LoggerUtils.d(TAG, "buildSendData=>" + DataConverter.bytesToHex(sendData));
            return sendData;
        } else {
            byte[] sendData = new byte[5];
            sendData[0] = (byte) 0xFF;
            sendData[1] = (byte) 0;
            sendData[2] = (byte) cmd;
            byte[] crc = new byte[2];
            ModuleAPI.getInstance().CalcCRC(Arrays.copyOfRange(sendData, 1, 3), 2, crc);//
            sendData[3] = crc[0];
            sendData[4] = crc[1];
            LoggerUtils.d(TAG, "buildSendData=>" + DataConverter.bytesToHex(sendData));
            return sendData;
        }

    }

    @Override
    public byte[] makeSetBaudRate(int baudrate) {
        byte[] data = new byte[4];
        data[0] = (byte) ((baudrate >> 24) & 0xFF);
        data[1] = (byte) ((baudrate >> 16) & 0xFF);
        data[2] = (byte) ((baudrate >> 8) & 0xFF);
        data[3] = (byte) (baudrate & 0xFF);
        return buildSendData(0x06, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetBaudRateResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeSetFrequencyPoint(int frequencyPoint) {
        byte[] data = new byte[4];
        data[0] = (byte) ((frequencyPoint >> 24) & 0xFF);
        data[1] = (byte) ((frequencyPoint >> 16) & 0xFF);
        data[2] = (byte) ((frequencyPoint >> 8) & 0xFF);
        data[3] = (byte) (frequencyPoint & 0xFF);
        return buildSendData(0x95, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetFrequencyPointResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    @Override
    public byte[] makeSetRFLink(int mode) {

        byte[] data = new byte[3];
        data[0] = 0x05;
        data[1] = 0x02;
        if (mode == 0) {
            data[2] = 0x6F;//FM0
        }
        if (mode == 1) {
            data[2] = 0x65;//M2 640k
        }
        if (mode == 2) {
            data[2] = 0x6B;//M4 250k
        }
        if (mode == 3) {
            data[2] = 0x71;//M8 160k
        }

        return buildSendData(0x9B, data);
    }

    @Override
    public UHFReaderResult<Boolean> analysisSetRFLinkResultData(UHFProtocolAnalysisBase.DataFrameInfo data) {
        if (data != null && data.status == 0) {
            return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE);
    }

    //解析连续盘点数据
    @Override
    public List<UHFTagEntity> analysisFastModeTagInfoReceiveDataMoreTag(UHFProtocolAnalysisBase.DataFrameInfo dataFrameInfo) {
        return null;
    }
}
