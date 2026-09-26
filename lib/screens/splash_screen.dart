import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Smooth curve for 360-degree mala bead fill
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // Initial subtle scale & fade-in entrance for the splash container
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.18, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    // Always start fresh from 0.0
    _controller.forward(from: 0.0);
  }

  void _navigateToHome() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    // Use Get.offAll for a clean, permanent root transition to HomeScreen
    Get.offAll(
      () => HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF2F6F6D); // Deep Teal
    const containerColor = Color(0xFFF5F2E9); // Warm Cream
    const textColor = Color(0xFFF5F2E9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Compact Card Container matching app icon logo
                      Container(
                        width: 250,
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(48),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: SplashMalaPainter(
                            progress: _animation.value,
                          ),
                          child: Center(
                            child: Container(
                              width: 116,
                              height: 116,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF1E6D3),
                                border: Border.all(
                                  color: const Color(0xFFC49A5A),
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC49A5A).withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Inner subtle ornamental accent ring
                                  Container(
                                    width: 102,
                                    height: 102,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFC49A5A).withValues(alpha: 0.28),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  // Central Om Symbol & Text
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'ॐ',
                                        style: TextStyle(
                                          fontSize: 36,
                                          height: 1.1,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFC49A5A),
                                        ),
                                      ),
                                      SizedBox(height: 1),
                                      Text(
                                        'PRAYER COUNT',
                                        style: TextStyle(
                                          fontSize: 7.5,
                                          letterSpacing: 1.6,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF8C7A60),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Title text under container
                      const Text(
                        'prayercount',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mindful Japa & Chant Journal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.8,
                          color: textColor.withValues(alpha: 0.75),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SplashMalaPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  SplashMalaPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Decreased Mala Circle Radius for a compact, perfectly balanced layout
    final radius = 86.0;

    const beadCount = 27; // Traditional 1/4 Mala bead count

    // Palette
    const filledBeadColor = Color(0xFF2E4C41); // Deep Emerald Green (Filled)
    const filledBeadSecondary = Color(0xFF3F6F54); // Vibrant Sage Green
    const glowColor = Color(0xFFFFD700); // Radiant Gold Fill & Glow
    const guruColor = Color(0xFFC49A5A); // Gold Guru Bead

    // 1. Transparent Background Guide Ring
    final bgLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFC49A5A).withValues(alpha: 0.22);

    canvas.drawCircle(center, radius, bgLinePaint);

    // 2. Progressive Filled Connecting Arc
    if (progress > 0) {
      final fillLinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFFC49A5A).withValues(alpha: 0.85)
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Start at top
        sweepAngle,
        false,
        fillLinePaint,
      );
    }

    // 3. Draw Top Guru Bead (Origin)
    final guruAngle = -pi / 2;
    final guruX = center.dx + radius * cos(guruAngle);
    final guruY = center.dy + radius * sin(guruAngle);
    final guruCenter = Offset(guruX, guruY);

    final guruAlpha = (0.4 + 0.6 * progress).clamp(0.0, 1.0);

    // Guru bead outer glow when animation completes or starts
    if (progress > 0.92 || progress < 0.08) {
      final guruGlowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = glowColor.withValues(alpha: 0.6 * guruAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawCircle(guruCenter, 11, guruGlowPaint);
    }

    // Guru Bead Outer Ring
    final guruPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = guruColor.withValues(alpha: guruAlpha);
    canvas.drawCircle(guruCenter, 8.5, guruPaint);

    // Guru Bead Inner Accent
    guruPaint.color = const Color(0xFFF1E6D3).withValues(alpha: guruAlpha);
    canvas.drawCircle(guruCenter, 3.5, guruPaint);

    guruPaint.color = guruColor.withValues(alpha: guruAlpha);
    canvas.drawCircle(guruCenter, 1.8, guruPaint);

    // 4. Sequential Clockwise Bead Color Fill Logic
    final activeBeadIndex = (progress * beadCount).floor();
    final beadFraction = (progress * beadCount) - activeBeadIndex;
    const stepAngle = (2 * pi) / beadCount;

    for (int i = 0; i < beadCount; i++) {
      final angle = -pi / 2 + (i + 1) * stepAngle;
      final bx = center.dx + radius * cos(angle);
      final by = center.dy + radius * sin(angle);
      final beadPosition = Offset(bx, by);

      double beadRadius = 5.2;
      Paint beadPaint = Paint()..style = PaintingStyle.fill;
      Paint beadStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      if (i < activeBeadIndex) {
        // --- FILLED BEADS (Passed) ---
        beadPaint.color = filledBeadColor;
        beadStrokePaint.color = const Color(0xFFC49A5A);

        final fillHalo = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFC49A5A).withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawCircle(beadPosition, beadRadius + 1.0, fillHalo);
      } else if (i == activeBeadIndex) {
        // --- ACTIVELY FILLING BEAD ---
        final glowIntensity = sin(beadFraction * pi); // 0 -> 1 -> 0
        beadRadius = 5.2 + 2.4 * glowIntensity;

        final auraPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = glowColor.withValues(alpha: 0.85 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(beadPosition, beadRadius + 5.5, auraPaint);

        final transparentStart = const Color(0xFF8C7A60).withValues(alpha: 0.15);
        beadPaint.color = Color.lerp(
          transparentStart,
          Color.lerp(filledBeadSecondary, glowColor, glowIntensity)!,
          beadFraction,
        )!;

        beadStrokePaint.color = Color.lerp(
          const Color(0xFFC49A5A).withValues(alpha: 0.35),
          glowColor,
          glowIntensity,
        )!;
      } else {
        // --- UNFILLED BEADS (Upcoming) ---
        beadPaint.color = const Color(0xFF8C7A60).withValues(alpha: 0.15);
        beadStrokePaint.color = const Color(0xFFC49A5A).withValues(alpha: 0.32);
      }

      // Draw Bead Body & Outline
      canvas.drawCircle(beadPosition, beadRadius, beadPaint);
      canvas.drawCircle(beadPosition, beadRadius, beadStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashMalaPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
