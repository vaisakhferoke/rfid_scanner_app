import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_settings_controller.dart';

class EventSettingsScreen extends GetView<EventSettingsController> {
  const EventSettingsScreen({super.key});

  void _showPasswordDialog(BuildContext context, var setting) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isObscure = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: Color(0xFF0043A4),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Authentication Required',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Password',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value != 'git123') {
                          return 'Incorrect password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      _showEditDialog(context, setting);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0043A4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, var setting) {
    final formKey = GlobalKey<FormState>();
    final keyController = TextEditingController(text: setting.key);
    final valueController = TextEditingController(text: setting.value);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Color(0xFF0043A4),
              ),
              SizedBox(width: 8),
              Text(
                'Edit Configuration',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuration Key',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: keyController,
                  enabled: false, // Key is read-only
                  decoration: InputDecoration(
                    fillColor: const Color(0xFFF1F5F9),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Value',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: valueController,
                  decoration: InputDecoration(
                    hintText: 'e.g. current day',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter value'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final navigator = Navigator.of(context);
                  final success = await controller.updateEventSetting(
                    id: setting.id,
                    key: keyController.text.trim(),
                    value: valueController.text.trim(),
                  );
                  if (success) {
                    navigator.pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0043A4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0043A4),
      appBar: AppBar(
        title: const Text(
          'Configuration Settings',
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
            child: Obx(() {
              if (controller.isLoading.value && controller.settingsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0043A4),
                    ),
                  ),
                );
              }

              if (controller.settingsList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings_suggest_rounded,
                        size: 72,
                        color: Color(0xFFCBD5E1),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Settings Found',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchEventSettings,
                color: const Color(0xFF0043A4),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  itemCount: controller.settingsList.length,
                  itemBuilder: (context, index) {
                    final setting = controller.settingsList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0043A4).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings_suggest_rounded,
                                color: Color(0xFF0043A4),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    setting.key,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    setting.value,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${setting.id}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () => _showPasswordDialog(context, setting),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
