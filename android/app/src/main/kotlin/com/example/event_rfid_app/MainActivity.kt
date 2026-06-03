package com.example.event_rfid_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.view.KeyEvent
import android.media.SoundPool
import android.os.Bundle
import android.util.Log
import android.content.pm.PackageManager
import android.Manifest
import com.example.event_rfid_app.R
import com.xlzn.hcpda.uhf.UHFReader
import com.xlzn.hcpda.uhf.entity.UHFReaderResult
import com.xlzn.hcpda.uhf.entity.UHFTagEntity
import com.xlzn.hcpda.uhf.enums.InventoryModeForPower
import com.xlzn.hcpda.uhf.module.UHFReaderSLR
import com.xlzn.hcpda.uhf.interfaces.OnInventoryDataListener

class MainActivity: FlutterActivity() {
    private val TAG = "RFID_MainActivity"
    private val METHOD_CHANNEL = "com.example.event_rfid_app/rfid_channel"
    private val EVENT_CHANNEL = "com.example.event_rfid_app/rfid_events"

    private var methodChannel: MethodChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private var soundPool: SoundPool? = null
    private var soundId: Int = 0
    private var lastBeepTime: Long = 0
    private val lastSendTimeMap = HashMap<String, Long>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initSoundPool()
        requestStoragePermissions()
    }

    private fun requestStoragePermissions() {
        val permissions = arrayOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        )
        val listPermissionsNeeded = ArrayList<String>()
        for (p in permissions) {
            if (checkSelfPermission(p) != PackageManager.PERMISSION_GRANTED) {
                listPermissionsNeeded.add(p)
            }
        }
        if (listPermissionsNeeded.isNotEmpty()) {
            requestPermissions(listPermissionsNeeded.toTypedArray(), 123)
        }
    }

    private fun initSoundPool() {
        try {
            soundPool = SoundPool.Builder().setMaxStreams(5).build()
            soundId = soundPool?.load(this, R.raw.beep, 1) ?: 0
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun playBeep() {
        val now = System.currentTimeMillis()
        if (now - lastBeepTime >= 250) {
            lastBeepTime = now
            try {
                soundPool?.play(soundId, 1.0f, 1.0f, 1, 0, 1.0f)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun releaseSoundPool() {
        soundPool?.release()
        soundPool = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkConnectionStatus" -> {
                    val connected = UHFReader.getInstance().connectState == com.xlzn.hcpda.uhf.enums.ConnectState.CONNECTED
                    result.success(connected)
                }
                "initializeReader" -> {
                    Thread {
                        var success = false
                        try {
                            Log.d(TAG, "Attempting to connect to real UHF Reader...")
                            val connectionResult = UHFReader.getInstance().connect(this@MainActivity)
                            val resultCode = connectionResult.resultCode
                            val resultMessage = connectionResult.message
                            val resultData = connectionResult.data
                            Log.d(TAG, "UHF Reader connect returned: Code=$resultCode, Message=$resultMessage, Data=$resultData")
                            
                            success = resultCode == UHFReaderResult.ResultCode.CODE_SUCCESS
                            if (success) {
                                Log.d(TAG, "UHF Reader connected successfully. Applying settings...")
                                if (UHFReaderSLR.is5300) {
                                    UHFReader.getInstance().setInventoryModeForPower(InventoryModeForPower.POWER_SAVING_MODE)
                                }
                                UHFReader.getInstance().setDynamicTarget(0)
                                UHFReader.getInstance().setPower(30)
                            } else {
                                Log.e(TAG, "UHF Reader connection failed: Code=$resultCode, Msg=$resultMessage")
                            }
                        } catch (t: Throwable) {
                            Log.e(TAG, "Failed to initialize real SDK due to exception: ${t.message}")
                            t.printStackTrace()
                        }
                        runOnUiThread {
                            result.success(success)
                        }
                    }.start()
                }
                "startInventory" -> {
                    Thread {
                        try {
                            var connected = UHFReader.getInstance().connectState == com.xlzn.hcpda.uhf.enums.ConnectState.CONNECTED
                            if (!connected) {
                                Log.d(TAG, "Reader not connected. Attempting auto-connect during startInventory...")
                                val connectionResult = UHFReader.getInstance().connect(this@MainActivity)
                                connected = connectionResult.resultCode == UHFReaderResult.ResultCode.CODE_SUCCESS
                                if (connected) {
                                    Log.d(TAG, "Auto-connect successful. Applying settings...")
                                    if (UHFReaderSLR.is5300) {
                                        UHFReader.getInstance().setInventoryModeForPower(InventoryModeForPower.POWER_SAVING_MODE)
                                    }
                                    UHFReader.getInstance().setDynamicTarget(0)
                                    UHFReader.getInstance().setPower(30)
                                } else {
                                    Log.e(TAG, "Auto-connect failed during startInventory: ${connectionResult.resultCode}")
                                }
                            }
                            
                            if (connected) {
                                synchronized(lastSendTimeMap) {
                                    lastSendTimeMap.clear()
                                }
                                UHFReader.getInstance().setOnInventoryDataListener(object : OnInventoryDataListener {
                                     override fun onInventoryData(tagEntityList: List<UHFTagEntity>?) {
                                         if (tagEntityList != null && tagEntityList.isNotEmpty()) {
                                             var shouldBeep = false
                                             val now = System.currentTimeMillis()
                                             
                                             for (tag in tagEntityList) {
                                                 val epc = tag.ecpHex
                                                 val rssi = tag.rssi
                                                 if (epc != null && epc.isNotEmpty()) {
                                                     var lastSend = 0L
                                                     synchronized(lastSendTimeMap) {
                                                         lastSend = lastSendTimeMap[epc] ?: 0L
                                                     }
                                                     if (now - lastSend >= 200) {
                                                         synchronized(lastSendTimeMap) {
                                                             lastSendTimeMap[epc] = now
                                                         }
                                                         shouldBeep = true
                                                         val tagData = mapOf(
                                                             "epc" to epc,
                                                             "rssi" to rssi
                                                         )
                                                         runOnUiThread {
                                                             eventSink?.success(tagData)
                                                         }
                                                     }
                                                 }
                                             }
                                             if (shouldBeep) {
                                                 playBeep()
                                             }
                                         }
                                     }
                                 })
                                 val readerResult = UHFReader.getInstance().startInventory()
                                val success = readerResult.data ?: false
                                runOnUiThread {
                                    result.success(success)
                                }
                            } else {
                                runOnUiThread {
                                    result.success(false)
                                }
                            }
                        } catch (t: Throwable) {
                            Log.e(TAG, "startInventory error: ${t.message}")
                            t.printStackTrace()
                            runOnUiThread {
                                result.success(false)
                            }
                        }
                    }.start()
                }
                "stopInventory" -> {
                    try {
                        val readerResult = UHFReader.getInstance().stopInventory()
                        val success = readerResult.data ?: false
                        result.success(success)
                    } catch (t: Throwable) {
                        Log.e(TAG, "stopInventory error: ${t.message}")
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    try {
                        UHFReader.getInstance().stopInventory()
                    } catch (t: Throwable) {
                        t.printStackTrace()
                    }
                }
            }
        )
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (event?.repeatCount == 0 && (keyCode == 11 || keyCode == 293 || keyCode == 290 || keyCode == 287 || keyCode == 286)) {
            runOnUiThread {
                methodChannel?.invokeMethod("physicalTriggerPressed", null)
            }
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onDestroy() {
        super.onDestroy()
        releaseSoundPool()
        try {
            UHFReader.getInstance().disConnect()
        } catch (t: Throwable) {
            t.printStackTrace()
        }
    }
}
