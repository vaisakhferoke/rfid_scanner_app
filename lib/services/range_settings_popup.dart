import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/range_controller.dart';

class RangeSettingsPopup {
  static void showRangeSettingsSheet(BuildContext context) {
    final RangeController rangeController = Get.find<RangeController>();
    // Pre-fetch range value to keep JNI state in sync
    rangeController.fetchCurrentPower();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark slate matching image
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row (READ RANGE status dots + dynamic label, power dBm)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Status dots and Labels
                    Row(
                      children: [
                        // Dynamic Green status dots
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'READ RANGE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 1.0,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rangeController.rangeLabel,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: rangeController.rangeColor,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Right: Dynamic power dBm text
                    Obx(
                      () => Text(
                        '${rangeController.powerLevel.value} dBm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: rangeController.rangeColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Slider and adjusters row
                Row(
                  children: [
                    // Minus Button & "Short" Label Column
                    Column(
                      children: [
                        InkWell(
                          onTap: rangeController.decrementPower,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Short',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),

                    // Slider
                    Expanded(
                      child: Column(
                        children: [
                          Obx(
                            () => SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                activeTrackColor: const Color(0xFF0284C7),
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.1,
                                ),
                                thumbColor: const Color(0xFF38BDF8),
                                overlayColor: const Color(
                                  0xFF38BDF8,
                                ).withOpacity(0.15),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7.0,
                                ),
                              ),
                              child: Slider(
                                min: 5.0,
                                max: 33.0,
                                value: rangeController.powerLevel.value
                                    .toDouble(),
                                onChanged: (double value) {
                                  rangeController.setPowerLevel(value.toInt());
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Medium',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Plus Button & "Long" Label Column
                    Column(
                      children: [
                        InkWell(
                          onTap: rangeController.incrementPower,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0284C7,
                              ), // Blue color from screenshot
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0284C7,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Long',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
