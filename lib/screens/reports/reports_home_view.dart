// Placeholder screen for Reports
import 'package:event_rfid_app/widgets/appbar/home_appbar.dart';
import 'package:flutter/material.dart';

class ReportsPlaceholderScreen extends StatelessWidget {
  const ReportsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppbar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Reports Screen Placeholder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Scan data analytics and metrics will appear here.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
