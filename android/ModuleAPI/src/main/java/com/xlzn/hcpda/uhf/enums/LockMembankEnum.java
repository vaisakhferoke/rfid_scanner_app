package com.xlzn.hcpda.uhf.enums;


public enum LockMembankEnum {

    KillPwd(0),

    AccessPwd(1),

    EPC(2),

    TID(3),

    USER(4);
    int lock=0;
    private LockMembankEnum(int lock) {
        this.lock=lock;
    }

    public int getValue(){
        return lock;
    }

    public static LockMembankEnum getValue(int value) {
        LockMembankEnum lockActionEnum = null;
        switch (value) {
            case 0:
                lockActionEnum = KillPwd;
                break;
            case 1:
                lockActionEnum = AccessPwd;
                break;
            case 2:
                lockActionEnum = EPC;
                break;
            case 3:
                lockActionEnum = TID;
                break;
            case 4:
                lockActionEnum = USER;
                break;
        }
        return lockActionEnum;
    }
}
