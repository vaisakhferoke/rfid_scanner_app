import 'package:event_rfid_app/controllers/range_controller.dart';
import 'package:event_rfid_app/services/range_settings_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RangeSettingsButton extends StatelessWidget {
  const RangeSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          final currentRange = Get.find<RangeController>().powerLevel.value;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Range',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '${currentRange.round()} m',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }),
        IconButton(
          onPressed: () => RangeSettingsPopup.showRangeSettingsSheet(context),
          icon: const Icon(Icons.radar_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
