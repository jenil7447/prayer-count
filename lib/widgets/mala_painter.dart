import 'dart:math';
import 'package:flutter/material.dart';

class MalaPainter extends CustomPainter {
  final int currentCount;
  final int targetCount;
  final Color activeColor;
  final Color inactiveColor;

  MalaPainter({
    required this.currentCount,
    required this.targetCount,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 16;

    // Total beads in the mala (108 by default or user target)
    final totalBeads = targetCount > 0 ? targetCount : 108;

    // Progress within current round
    final activeBeadsCount = currentCount % totalBeads;
    final isTargetReached = currentCount > 0 && activeBeadsCount == 0;

    // 1. Draw connecting string line
    final stringPaint = Paint()
      ..color = inactiveColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, stringPaint);

    // 2. Draw 108 individual Mala Beads around the string
    for (int i = 0; i < totalBeads; i++) {
      // Angle starting from top (-pi / 2) clockwise
      double angle = -pi / 2 + (2 * pi * i / totalBeads);

      // Skip position index 0 to make room for Guru bead
      if (i == 0) continue;

      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);

      bool isActive = isTargetReached || (i <= activeBeadsCount);
      Color beadColor = isActive ? activeColor : inactiveColor;

      final beadPaint = Paint()
        ..color = beadColor
        ..style = PaintingStyle.fill;

      // Slight natural variation in bead size for organic mala look
      double beadRadius = (i % 8 == 0) ? 5.0 : 4.0;
      canvas.drawCircle(Offset(x, y), beadRadius, beadPaint);
    }

    // 3. Draw Top Guru Bead (Header Bead)
    final guruBeadRadius = 9.0;
    final guruBeadOffset = Offset(
      center.dx + radius * cos(-pi / 2),
      center.dy + radius * sin(-pi / 2),
    );

    final guruOuterPaint = Paint()
      ..color = (activeBeadsCount > 0 || isTargetReached) ? activeColor : inactiveColor
      ..style = PaintingStyle.fill;

    final guruInnerPaint = Paint()
      ..color = Colors.amber.shade300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(guruBeadOffset, guruBeadRadius, guruOuterPaint);
    canvas.drawCircle(guruBeadOffset, guruBeadRadius * 0.45, guruInnerPaint);
  }

  @override
  bool shouldRepaint(covariant MalaPainter oldDelegate) {
    return oldDelegate.currentCount != currentCount ||
        oldDelegate.targetCount != targetCount ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}