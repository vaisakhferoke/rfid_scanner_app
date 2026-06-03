package com.xlzn.hcpda.uhf.enums;

public enum LockActionEnum {

    LOCK(0),

    UNLOCK(1),

    PERMANENT_LOCK(2),

    PERMANENT_UNLOCK(3);

    int action=0;
    private LockActionEnum(int action) {
        this.action=action;
    }

    public int getValue(){
        return action;
    }

    public static LockActionEnum getValue(int value) {
        LockActionEnum lockActionEnum = null;
        switch (value) {
            case 0:
                lockActionEnum = LOCK;
                break;
            case 1:
                lockActionEnum = UNLOCK;
                break;
            case 2:
                lockActionEnum = PERMANENT_LOCK;
                break;
            case 3:
                lockActionEnum = PERMANENT_UNLOCK;
                break;
        }
        return lockActionEnum;
    }
}
