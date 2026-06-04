import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward().then((_) {
      // Delay navigation slightly to let the completed state settle
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.off(
          () => MainNavigationScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 600),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0043A4), // Primary theme blue
              Color(0xFF00235C), // Deep premium dark blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Centered Animated Logo & Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo/app_logo.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback in case of asset loading issues
                            return Container(
                              width: 110,
                              height: 110,
                              color: const Color(0xFFE31E24), // VKC brand red
                              child: const Center(
                                child: Text(
                                  'VKC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.5),
                          child: child,
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Text(
                          'RFID SCANNER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'VKC Event Management',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom loading status
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Initializing Scanner...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          letterSpacing: 0.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
