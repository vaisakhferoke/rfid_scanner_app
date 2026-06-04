import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void dispose() {
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

  void _executeWrite() {
    if (!_formKey.currentState!.validate()) return;

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
              ],
            ),
          ),
        );
      },
    );

    final String textData = _epcController.text.trim();
    final String hexData = _stringToHex(textData);
    final navigator = Navigator.of(context);

    _rfidService.writeTag(
      hexData: hexData,
      password: "00000000",
      membank: 1,
      address: 2,
      wordCount: 3,
    ).then((success) {
      if (!mounted) return;
      // Dismiss writing dialog
      navigator.pop();

      if (success) {
        Get.snackbar(
          'Success',
          'EPC successfully written to tag memory!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to write to tag. Make sure tag is close and reader is connected.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
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
                              maxLength: 24,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter EPC hex data';
                                }
                                if (value.length != 6) {
                                  return 'EPC data must be exactly 6 characters';
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

                      // Write Action Button
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
                              const SizedBox(width: 8),
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
}
