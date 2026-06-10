import 'package:event_rfid_app/config/api_config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void showAttendeeDetails(BuildContext context, String uniqId) {
  // Show a loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF213AEC)),
      );
    },
  );

  // Call API to fetch user profile
  ApiConfig.getBaseUrl()
      .then((baseUrl) {
        final String urlString =
            '$baseUrl/flutter/event_phuket/list_users.aspx';
        print(" url : ${urlString} ");
        print(" user_id : ${uniqId} ");
        http
            .post(Uri.parse(urlString), body: {'user_id': uniqId})
            .timeout(const Duration(seconds: 8))
            .then((response) {
              Navigator.of(context).pop(); // Close loading dialog

              if (response.statusCode == 200) {
                try {
                  final Map<String, dynamic> data = json.decode(response.body);
                  if (data['status'] == true &&
                      data['data'] != null &&
                      (data['data'] as List).isNotEmpty) {
                    final Map<String, dynamic> userMap = data['data'][0];
                    _showUserProfileDialog(context, userMap);
                  } else {
                    _showErrorDialog(
                      context,
                      data['Message'] ?? 'User details not found.',
                    );
                  }
                } catch (e) {
                  _showErrorDialog(context, 'Failed to parse user details.');
                }
              } else {
                _showErrorDialog(
                  context,
                  'Server responded with status code: ${response.statusCode}',
                );
              }
            })
            .catchError((error) {
              Navigator.of(context).pop(); // Close loading dialog
              _showErrorDialog(context, 'Failed to connect to server: $error');
            });
      })
      .catchError((error) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, 'Failed to load configuration: $error');
      });
}

void _showUserProfileDialog(
  BuildContext context,
  Map<String, dynamic> userMap,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      print('Name  : ${userMap['name']}');
      final String title = userMap['title'] ?? '';
      final String name = userMap['name'] ?? 'Unknown Name';
      final String fullName = title.isNotEmpty ? '$title $name' : name;
      final String uniqueId = userMap['unique_id'] ?? '';
      final String code = userMap['code'] ?? '';
      final String state = userMap['state'] ?? '';
      final String type = userMap['type'] ?? 'Attendee';
      final String bus = userMap['bus'] ?? '';

      // Initials for avatar
      String initials = '';
      if (name.isNotEmpty) {
        final parts = name.split(' ');
        if (parts.isNotEmpty) {
          initials += parts[0][0].toUpperCase();
          if (parts.length > 1 && parts[1].isNotEmpty) {
            initials += parts[1][0].toUpperCase();
          }
        }
      }
      if (initials.isEmpty) initials = '?';

      Widget buildInfoField(String label, String value, IconData icon) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF213AEC), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      value.isNotEmpty ? value : 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Dialog(
        insetPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            minWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF213AEC), Color(0xFF5D71F4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF213AEC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Details Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERSONAL DETAILS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildInfoField(
                        'Employee Code',
                        code,
                        Icons.badge_outlined,
                      ),
                      buildInfoField('Unique ID', uniqueId, Icons.fingerprint),
                      buildInfoField(
                        'State / Location',
                        state,
                        Icons.location_on_outlined,
                      ),
                      if (bus.isNotEmpty)
                        buildInfoField(
                          'Assigned Bus',
                          bus,
                          Icons.directions_bus_outlined,
                        ),

                      const SizedBox(height: 16),
                      const Text(
                        'Last Vehicle Scan Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildInfoField(
                        'Vehicle',
                        bus,
                        Icons.directions_bus_outlined,
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF213AEC),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Close Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Fetch Error',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF213AEC),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
