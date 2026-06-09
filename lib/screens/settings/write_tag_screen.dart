import 'dart:async';
import 'package:event_rfid_app/models/rfid_tag.dart';
import 'package:event_rfid_app/widgets/common_widgets/range_settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/range_controller.dart';
import '../../services/rfid_service.dart';

class WriteTagScreen extends StatefulWidget {
  const WriteTagScreen({super.key});

  @override
  State<WriteTagScreen> createState() => _WriteTagScreenState();
}

class _WriteTagScreenState extends State<WriteTagScreen> {
  final TextEditingController _epcController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RfidService _rfidService = RfidService();
  bool _isConnected = false;
  bool _isConnecting = false;
  StreamSubscription? _tagStreamSubscription;
  bool _isFinding = false;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    if (!mounted) return;
    setState(() {
      _isConnecting = true;
    });
    try {
      bool connected = await _rfidService.checkConnectionStatus();
      if (!connected) {
        connected = await _rfidService.initializeReader();
      }
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    } catch (e) {
      debugPrint('Connection error in WriteTagScreen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stopFinding();
    _epcController.dispose();
    super.dispose();
  }

  // bool _isValidHex(String value) {
  //   final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
  //   return hexRegex.hasMatch(value);
  // }

  String _stringToHex(String value) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      sb.write(value.codeUnitAt(i).toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString().toUpperCase();
  }

  Future<void> _stopFinding() async {
    await _tagStreamSubscription?.cancel();
    _tagStreamSubscription = null;
    await _rfidService.stopInventory();
    if (mounted) {
      setState(() {
        _isFinding = false;
      });
    }
  }

  void _findSingleTag() async {
    if (_isFinding) return;

    setState(() {
      _isFinding = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Finding Tag...',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0043A4)),
            ),
            SizedBox(height: 16),
            Text(
              'Bring a tag near the scanner.',
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _stopFinding();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF0043A4)),
            ),
          ),
        ],
      ),
    );

    await _rfidService.startInventory();

    _tagStreamSubscription = _rfidService.tagStream.listen((event) async {
      final epc = event['epc'] as String?;
      final rssi = event['rssi'] as int?;
      final rfidTag = RfidTag(
        epc: epc!,
        rssi: rssi!,
        readTime: DateTime.now(),
        count: 1,
      );
      debugPrint('Tag Found: ${rfidTag.displayName}');
      if (rfidTag.epc.isNotEmpty) {
        await _stopFinding();
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        setState(() {
          _epcController.text = rfidTag.displayName; // hex to convet string
        });
        Get.snackbar(
          'Tag Found',
          'Successfully read tag data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    });
  }

  void _verifyWrittenTag(String writtenEpc) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Verifying...',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0043A4)),
            ),
            SizedBox(height: 16),
            Text(
              'Reading tag to verify details...',
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );

    await _rfidService.startInventory();
    StreamSubscription? verifySub;
    bool isVerified = false;

    verifySub = _rfidService.tagStream.listen((event) async {
      final epc = event['epc'] as String?;
      final rssi = event['rssi'] as int?;
      final rfidTag = RfidTag(
        epc: epc!,
        rssi: rssi!,
        readTime: DateTime.now(),
        count: 1,
      );
      debugPrint('Tag Found: ${rfidTag.epc}');
      if (rfidTag.epc.isNotEmpty) {
        isVerified = true;
        await verifySub?.cancel();
        await _rfidService.stopInventory();

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _showSuccessPopup(rfidTag.displayName);
      }
    });

    Future.delayed(const Duration(seconds: 3), () async {
      if (!isVerified) {
        await verifySub?.cancel();
        await _rfidService.stopInventory();
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
          _showSuccessPopup(writtenEpc, timeout: true);
        }
      }
    });
  }

  void _showSuccessPopup(String foundEpc, {bool timeout = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              timeout
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: timeout ? Colors.amber : const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            Text(
              timeout ? 'Write Success' : 'Success',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeout
                  ? 'Tag was successfully written, but couldn\'t be read back.'
                  : 'Tag was successfully written and read back.',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tag Details:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foundEpc,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0043A4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                _resetAll();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAll() {
    _epcController.clear();
    FocusScope.of(context).unfocus();
  }

  void _executeWrite() {
    if (!_formKey.currentState!.validate()) return;

    final RangeController rangeController = Get.find<RangeController>();
    final int power = rangeController.powerLevel.value;

    // Show writing progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0043A4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Writing RFID Tag...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep the RFID tag within 10cm of the scanner antenna.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: rangeController.rangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rangeController.rangeColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        color: rangeController.rangeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Power: $power dBm (${rangeController.rangeLabel})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rangeController.rangeColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                if (power < 20) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Note: Low power level ($power dBm) might reduce write range. Hold the tag closer to the scanner.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    final String textData = _epcController.text.trim();
    final String hexData = _stringToHex(textData);
    final navigator = Navigator.of(context);
    print('Writing Tag: ${hexData}');

    // Apply the saved power setting right before writing to make sure reader is configured correctly
    _rfidService.setPower(power).then((_) {
      try {
        _rfidService
            .writeTag(
              hexData: hexData,
              password: "00000000",
              membank: 1,
              address: 2,
              wordCount: 3,
            )
            .then((success) {
              if (!mounted) return;
              // Dismiss writing dialog
              navigator.pop();

              if (success) {
                setState(() {
                  _isConnected = true;
                });
                _verifyWrittenTag(hexData);
              } else {
                try {
                  _rfidService.checkConnectionStatus().then((connected) {
                    if (mounted) {
                      setState(() {
                        _isConnected = connected;
                      });
                    }
                  });
                } catch (e, stackTrace) {
                  print('Error: $e');
                  print('Stack Trace: $stackTrace');
                  Get.snackbar(
                    'Error',
                    '$e , $stackTrace',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFEF4444),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    duration: const Duration(seconds: 3),
                  );
                }

                // show exact error
              }
            });
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack Trace First Section: $stackTrace');
        Get.snackbar(
          'Error',
          '$e , $stackTrace',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 238, 161, 7),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Write Tag',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0043A4),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [RangeSettingsButton()],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Connection Status Card
                      _buildConnectionCard(context),
                      const SizedBox(height: 20),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Encode Data',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0043A4),
                                letterSpacing: 0.5,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _epcController,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                labelText: 'EPC HEX DATA',
                                labelStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                                hintText: 'Enter 6 character ',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF94A3B8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0043A4),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  onPressed: () => _epcController.clear(),
                                ),
                              ),

                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter EPC hex data';
                                }
                                if (value.length < 6) {
                                  return 'EPC data must be less than or equal to 6 characters';
                                }
                                // if (!_isValidHex(value)) {
                                //   return 'EPC data must contain hexadecimal characters only';
                                // }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _findSingleTag,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0043A4),
                            side: const BorderSide(
                              color: Color(0xFF0043A4),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Find Tag',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _executeWrite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0043A4),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(
                              0xFF0043A4,
                            ).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Write to Tag',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _isConnected
            ? const Color(0xFFECFDF5) // Light emerald green
            : const Color(0xFFFEF2F2), // Light red
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFEF4444).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Pulse-like status dot
          _isConnecting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF64748B),
                    ),
                  ),
                )
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isConnected
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444))
                                .withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnecting
                      ? 'Connecting to Reader...'
                      : _isConnected
                      ? 'Reader Connected'
                      : 'Reader Disconnected',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _isConnecting
                        ? const Color(0xFF475569)
                        : _isConnected
                        ? const Color(0xFF047857) // Dark green
                        : const Color(0xFFB91C1C), // Dark red
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isConnecting
                      ? 'Please wait, initializing connection...'
                      : _isConnected
                      ? 'Real RFID Hardware is active and ready'
                      : 'Tag writes will fail without connection',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnecting
                        ? const Color(0xFF64748B)
                        : _isConnected
                        ? const Color(0xFF065F46)
                        : const Color(0xFF991B1B),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          if (!_isConnected && !_isConnecting)
            TextButton.icon(
              onPressed: _connectToDevice,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: Color(0xFFE31E24), // VKC Red Accent
              ),
              label: const Text(
                'Connect',
                style: TextStyle(
                  color: Color(0xFFE31E24),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }
}
