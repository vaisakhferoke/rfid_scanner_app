import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindTagScreen extends StatefulWidget {
  const FindTagScreen({super.key});

  @override
  State<FindTagScreen> createState() => _FindTagScreenState();
}

class _FindTagScreenState extends State<FindTagScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  bool _isScanning = false;
  double _rssiValue = 0.0;
  Timer? _rssiTimer;
  final List<double> _signalHistory = List.filled(5, 0.0);

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _radarController.repeat();
        _startSimulatingRSSI();
      } else {
        _radarController.stop();
        _stopSimulatingRSSI();
        _rssiValue = 0.0;
        _signalHistory.fillRange(0, 5, 0.0);
      }
    });
  }

  void _startSimulatingRSSI() {
    _rssiTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        // Generate pseudo-random realistic RFID RSSI fluctuations
        final random = math.Random();
        double targetRssi = random.nextDouble() * 100;
        
        // Make it trend towards a high signal occasionally to simulate tag discovery
        final timeSec = DateTime.now().second;
        if (timeSec % 10 < 4) {
          targetRssi = 70.0 + (random.nextDouble() * 25.0);
        } else if (timeSec % 10 < 7) {
          targetRssi = 15.0 + (random.nextDouble() * 30.0);
        }

        // Smooth RSSI updates (moving average)
        _rssiValue = (_rssiValue * 0.4) + (targetRssi * 0.6);
        if (_rssiValue > 100) _rssiValue = 100.0;
        
        // Add to history list for audio/visual beep rate simulation
        _signalHistory.removeAt(0);
        _signalHistory.add(_rssiValue);
      });
    });
  }

  void _stopSimulatingRSSI() {
    _rssiTimer?.cancel();
    _rssiTimer = null;
  }

  Color _getSignalColor(double value) {
    if (value >= 75) return const Color(0xFF10B981); // Strong: Emerald green
    if (value >= 40) return const Color(0xFFF59E0B); // Medium: Amber
    if (value > 0) return const Color(0xFFEF4444); // Weak: Red
    return const Color(0xFF94A3B8); // Off/Zero: Grey
  }

  @override
  void dispose() {
    _radarController.dispose();
    _stopSimulatingRSSI();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0043A4),
      appBar: AppBar(
        title: const Text(
          'Find Tag',
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  children: [
                    // Help Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF0043A4), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Hold the RFID scanner and scan the environment. The signal indicator shows proximity to the target RFID tag.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                height: 1.4,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Radar Indicator Visual
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          border: Border.all(
                            color: const Color(0xFF0043A4).withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: AnimatedBuilder(
                            animation: _radarController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: RadarPainter(
                                  angle: _radarController.value * 2 * math.pi,
                                  isScanning: _isScanning,
                                  signalStrength: _rssiValue,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // RSSI Value Panel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'RSSI Strength',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                _isScanning ? '${_rssiValue.toStringAsFixed(0)}%' : '0%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: _getSignalColor(_rssiValue),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Custom Signal Bar Chart/Indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _rssiValue / 100,
                              minHeight: 16,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getSignalColor(_rssiValue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusBadge(
                                isHighlighted: _isScanning && _rssiValue < 40 && _rssiValue > 0,
                                color: const Color(0xFFEF4444),
                                label: 'Weak',
                              ),
                              _buildStatusBadge(
                                isHighlighted: _isScanning && _rssiValue >= 40 && _rssiValue < 75,
                                color: const Color(0xFFF59E0B),
                                label: 'Medium',
                              ),
                              _buildStatusBadge(
                                isHighlighted: _isScanning && _rssiValue >= 75,
                                color: const Color(0xFF10B981),
                                label: 'Strong',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Start/Stop Scan Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _toggleScanning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isScanning ? const Color(0xFFDC2626) : const Color(0xFF0043A4),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: (_isScanning ? const Color(0xFFDC2626) : const Color(0xFF0043A4)).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              _isScanning ? 'Stop Search' : 'Start Radar Search',
                              style: const TextStyle(
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
    );
  }

  Widget _buildStatusBadge({
    required bool isHighlighted,
    required Color color,
    required String label,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? color.withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          color: isHighlighted ? color : const Color(0xFF94A3B8),
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double angle;
  final bool isScanning;
  final double signalStrength;

  RadarPainter({
    required this.angle,
    required this.isScanning,
    required this.signalStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Paint options
    final gridPaint = Paint()
      ..color = const Color(0xFF0043A4).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Draw concentric circles
    canvas.drawCircle(center, maxRadius * 0.3, gridPaint);
    canvas.drawCircle(center, maxRadius * 0.6, gridPaint);
    canvas.drawCircle(center, maxRadius * 0.9, gridPaint);

    // 2. Draw cross lines
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), gridPaint);

    if (!isScanning) return;

    // 3. Draw scanning sweep line and gradient fan
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0043A4).withOpacity(0.3),
          const Color(0xFF0043A4).withOpacity(0.01),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: maxRadius * 0.9),
        angle - 0.5, // Sweep width
        0.5,
        false,
      )
      ..close();
    canvas.drawPath(path, sweepPaint);

    // 4. Draw dynamic scanning line at leading edge
    final linePaint = Paint()
      ..color = const Color(0xFF0043A4).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final endPointX = center.dx + maxRadius * 0.9 * math.cos(angle);
    final endPointY = center.dy + maxRadius * 0.9 * math.sin(angle);
    canvas.drawLine(center, Offset(endPointX, endPointY), linePaint);

    // 5. Draw target pulsing node (if tag is found/close)
    if (signalStrength > 30) {
      final pulsePaint = Paint()
        ..color = (signalStrength >= 75
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B)).withOpacity(0.8)
        ..style = PaintingStyle.fill;

      // Draw standard mock node representing target tag
      final tagX = center.dx + maxRadius * 0.45 * math.cos(math.pi / 4);
      final tagY = center.dy - maxRadius * 0.45 * math.sin(math.pi / 4);
      
      // Calculate pulsing radius
      final pulseRadius = 8.0 + 4.0 * math.sin(DateTime.now().millisecond / 100 * math.pi);
      canvas.drawCircle(Offset(tagX, tagY), pulseRadius, pulsePaint);
      
      // Outer pulse ring
      final outerRingPaint = Paint()
        ..color = pulsePaint.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(tagX, tagY), pulseRadius + 6, outerRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.isScanning != isScanning || oldDelegate.signalStrength != signalStrength;
  }
}
