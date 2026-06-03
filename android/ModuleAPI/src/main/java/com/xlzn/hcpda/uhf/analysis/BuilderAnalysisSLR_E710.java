package com.xlzn.hcpda.uhf.analysis;

import com.xlzn.hcpda.uhf.entity.SelectEntity;
import com.xlzn.hcpda.uhf.entity.UHFReaderResult;
import com.xlzn.hcpda.uhf.entity.UHFTagEntity;
import com.xlzn.hcpda.uhf.module.UHFReaderSLR;
import com.xlzn.hcpda.utils.DataConverter;
import com.xlzn.hcpda.utils.LoggerUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class BuilderAnalysisSLR_E710 extends BuilderAnalysisSLR {

    private String TAG = "BuilderAnalysisSLR_E710";

    @Override
    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveDataNeedTid(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID) {
        this.isTID = isTID;
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x48) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
                //4D 6F 64 75 6C 65 74 65 63 68 AA 48
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);

    }


    public byte[] makeStartFastModeInventorySendData(SelectEntity selectEntity, boolean isTID) {
        if(selectEntity==null) {
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
            senddata[index++] = 0x00;
            senddata[index++] = (byte) 0x02;

            senddata[index++] = 0x00;
            senddata[index++] = (0x00);
//            82 00 00 03 77 BB 64 F8
            if(!isTID) {
                senddata[index++] = 0x03;
                senddata[index++] = (byte) 0xF7;
            }else {
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
//            senddata[index++] = (byte) (subcrcTemp & 0xFF);
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
        final int count = 0X0001;
        final int rssi = 0x0002;
        final int ant = 0X0004;
        final int flag = count | rssi | ant;
        senddata[index++] = (flag >> 8) & 0xFF;
        senddata[index++] = flag & 0xFF;
        //1OPTION
        senddata[index++] = (byte) (selectEntity.getOption());
        senddata[index++] = (0x00 | 0x10);
        senddata[index++] = 0x00;
        //3. 4AccessPassword
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        senddata[index++] = 0x00;
        //4. Select Address(bits)
        int address=selectEntity.getAddress();
        senddata[index++]=(byte)((address>>24) &0xFF);
        senddata[index++]=(byte)((address>>16) &0xFF);
        senddata[index++]=(byte)((address>>8) &0xFF);
        senddata[index++]=(byte)(address&0xFF);
        //Select data length(bits)
        senddata[index++]=(byte)selectEntity.getLength();
        //Select data
        byte[] byteData=DataConverter.hexToBytes(selectEntity.getData());
        int len=selectEntity.getLength()/8;
        if(selectEntity.getLength()%8!=0) {
            len += 1;
        }
        for(int k=0;k<len;k++){
            senddata[index++]=byteData[k];
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


    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveDataMoreTag(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID) {
        this.isTID = isTID;
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                LoggerUtils.d(TAG, "E710开始盘点指令返回Data:" + DataConverter.bytesToHex(data.data));
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x58) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
                //4D 6F 64 75 6C 65 74 65 63 68 AA 48
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }


    public List<UHFTagEntity> analysisFastModeTagInfoReceiveDataMoreTag(UHFProtocolAnalysisBase.DataFrameInfo data ) {
        if (data != null) {
            if (data.status == 0) {

                LoggerUtils.d(TAG, "解析盘点数据："+DataConverter.bytesToHex(data.data));
                byte[] taginfo = data.data;
//                int tagsTotal = taginfo[3] & 0xFF;//
                int statIndex = 2;
                //00 06 D3 01 10 3400 300833B2DDD9014000000000 C41E
                //00 02 E1 10 3400 300833B2DDD9014000000000 C41E
                List<UHFTagEntity> list = new ArrayList<>();
                int rssi = taginfo[statIndex];   //RSSI

                int count = taginfo[statIndex++] & 0xFF; //
                int epcLen = (taginfo[statIndex++] & 0xFF);   //

                UHFTagEntity uhfTagEntity = new UHFTagEntity();
                byte[] pcBytes = new byte[]{
                        taginfo[statIndex++],
                        taginfo[statIndex++]
                };
                int epcIdLen = epcLen - 2 - 2;
                byte[] epcBytes = new byte[epcIdLen];
                for (int m = 0; m < epcIdLen; m++) {
                    epcBytes[m] = taginfo[statIndex++];
                }
                uhfTagEntity.setRssi(rssi);
                uhfTagEntity.setCount(count);
                uhfTagEntity.setEcpHex(DataConverter.bytesToHex(epcBytes));
                if (uhfTagEntity.getEcpHex() == null) {
                    uhfTagEntity.setEcpHex("");
                }
                uhfTagEntity.setPcHex(DataConverter.bytesToHex(pcBytes));
                list.add(uhfTagEntity);

                return list;
            } //00 07 00 01    01  C9 11   00 80   30 00 E2 00 00 17 01 0B 00 50 17 50 61 70 BB 55
        }
        return null;
    }

    public UHFReaderResult<Boolean> analysisStartFastModeInventoryReceiveData(UHFProtocolAnalysisBase.DataFrameInfo data, boolean isTID) {
        this.isTID=isTID;
        //0xFF+DATALEN+0XAA+STATUS +”Moduletech”+SubCmdHighByte+SubCmdLowByte+data+CRC
        if (data != null) {
            if (data.status == 00) {
                if ((data.data[10] & 0xFF) == 0xAA && (data.data[11] & 0xFF) == 0x48) {
                    return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_SUCCESS, "", true);
                }
                //4D 6F 64 75 6C 65 74 65 63 68 AA 48
            }
        }
        return new UHFReaderResult<Boolean>(UHFReaderResult.ResultCode.CODE_FAILURE, "", false);
    }


    public List<UHFTagEntity> analysisFastModeTagInfoReceiveDataOld(UHFProtocolAnalysisBase.DataFrameInfo data) {

        if (data != null) {
            if (data.status == 0) {
                //00 02 E1 10 3400 300833B2DDD9014000000000 C41E
//                00 07 01 CA 01 08 1400 C0000171 03E9
                byte[] taginfo = data.data;
                int rssi = taginfo[2] & 0xFF;//
                int statIndex = 3;


                List<UHFTagEntity> list = new ArrayList<>();
                    UHFTagEntity uhfTagEntity = new UHFTagEntity();
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
                    uhfTagEntity.setRssi(rssi-256);
                    uhfTagEntity.setCount(1);
                    uhfTagEntity.setEcpHex(DataConverter.bytesToHex(epcBytes));
                    if (uhfTagEntity.getEcpHex() == null) {
                        uhfTagEntity.setEcpHex("");
                    }
                    uhfTagEntity.setPcHex(DataConverter.bytesToHex(pcBytes));
                    list.add(uhfTagEntity);

                if (list == null ) {
                    LoggerUtils.d(TAG, "list.size()=" + list.size());
                }
                return list;
            } //00 07 00 01    01  C9 11   00 80   30 00 E2 00 00 17 01 0B 00 50 17 50 61 70 BB 55
        }
        return null;
    }

    public byte[] makeStartFastModeInventorySendDataNeedTid(SelectEntity selectEntity, boolean isTID) {
        LoggerUtils.d(TAG,"0000000000000000000000---------------" + selectEntity);
        if (!UHFReaderSLR.isR2000) {
            if (selectEntity != null) {
                if (isTID) {
                    return makeStartFastModeInventorySendDataNeedTid3(selectEntity, true);
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
            senddata[index++] = (byte) 0x48;

//             0080 00 0004  04 1B 28 0000 00 00 00000000 04 01

//           0080 00 0004  02 0F 28 0000 00  02 00000000 06 03 00000000 43 D9 BB DB23

//            AA 48 00 80 00 00 04 02 0F 28 00 00 00 02 00 00 00 00 06 03 00 00 00 00 2B E5
//            AA 48 00 82 00 00 04 03 15 28 00 00 00 02 00 00 00 00 06 03 00 00 00 00 20 03 00 00 00 20 0B 11 BB 53 EA
            //AA 48 00 82 00 00 04 02 0F 28 00 00 00 02 00 00 00 00 06 03 00 00 00 00 20 DC BB 94 12
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x82;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x04;
            senddata[index++] = (byte) 0x03;

            senddata[index++] = (byte) 0x15;
            senddata[index++] = (byte) 0x28;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x02;

            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;

            senddata[index++] = (byte) 0x06;
            senddata[index++] = (byte) 0x03;


            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x20;

            senddata[index++] = (byte) 0x03;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x20;
            senddata[index++] = (byte) 0x0B;








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
        final int count = 0X0001;//
        final int rssi = 0x0002;//
        final int ant = 0X0004;//
        final int flag = count | rssi | ant;
        senddata[index++] = (flag >> 8) & 0xFF;
        senddata[index++] = flag & 0xFF;
        //1.OPTION
        senddata[index++] = (byte) (selectEntity.getOption());
        senddata[index++] = (0x00 | 0x10);
        senddata[index++] = 0x00;
        //3. 4AccessPassword
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


    public byte[] makeStartFastModeInventorySendDataNeedTid512(SelectEntity selectEntity, boolean isTID) {
        LoggerUtils.d(TAG,"0000000000000000000000---------------" + selectEntity);
        if (!UHFReaderSLR.isR2000) {
            if (selectEntity != null) {
                if (isTID) {
                    return makeStartFastModeInventorySendDataNeedTid3(selectEntity, true);
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
            senddata[index++] = (byte) 0x48;

//             0080 00 0004  04 1B 28 0000 00 00 00000000 04 01

//           0080 00 0004  02 0F 28 0000 00  02 00000000 06 03 00000000 43 D9 BB DB23

//            AA 48 00 80 00 00 04 02 0F 28 00 00 00 02 00 00 00 00 06 03 00 00 00 00 2B E5
//            AA 48 00 82 00 00 04 03 15 28 00 00 00 02 00 00 00 00 06 03 00 00 00 00 20 03 00 00 00 20 0B 11 BB 53 EA
            //AA 48 00 82 00 00 04 02 0F 28 00 00 00 02 00 00 00 00 06 03 00 00 00 00 20 DC BB 94 12
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x82;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x04;
            senddata[index++] = (byte) 0x02;

            senddata[index++] = (byte) 0x0F;
            senddata[index++] = (byte) 0x28;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x02;

            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;

            senddata[index++] = (byte) 0x06;
            senddata[index++] = (byte) 0x03;


            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x00;
            senddata[index++] = (byte) 0x20;










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
        //1OPTION
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
}
