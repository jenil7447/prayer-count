import 'dart:math';
import 'package:flutter/material.dart';

class MalaCounterWidget extends StatelessWidget {
  final int count;
  final int target;
  final VoidCallback onTap;
  final Color themeColor;

  const MalaCounterWidget({
    Key? key,
    required this.count,
    required this.target,
    required this.onTap,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colors based on the provided image
    final circleBackgroundColor = const Color(0xFFF1E6D3);
    final circleBorderColor = const Color(0xFFC49A5A);
    final japaCountTextColor = const Color(0xFF8C7A60);
    final countNumberColor = const Color(0xFF2E4C41);
    final omColor = const Color(0xFFC49A5A);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: CustomPaint(
            painter: MalaPainter(
              count: count,
              target: target,
              themeColor: themeColor,
            ),
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleBackgroundColor,
                  border: Border.all(color: circleBorderColor, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'COUNTER',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                        color: japaCountTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 64,
                        height: 1.1,
                        fontWeight: FontWeight.w500, // Medium weight as in image
                        color: countNumberColor,
                      ),
                    ),
                    Text(
                      'of $target',
                      style: TextStyle(
                        fontSize: 12,
                        color: japaCountTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ॐ',
                      style: TextStyle(
                        fontSize: 22,
                        color: omColor,
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
}

class MalaPainter extends CustomPainter {
  final int count;
  final int target;
  final Color themeColor;

  MalaPainter({
    required this.count,
    required this.target,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    // ------------------------------------------------------------
    // COLORS
    // ------------------------------------------------------------

    final completedColor = const Color(0xFF9E6844);
    final remainingColor = const Color(0xFFD6A25C);

    final strokeColorCompleted = const Color(0xFF7A4E31);
    final strokeColorRemaining = const Color(0xFFB58444);

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final beadCount = target > 0 ? target : 108;

    // ------------------------------------------------------------
    // CONNECTING LINE
    // ------------------------------------------------------------
    //
    // Draw this BEFORE the beads so that the beads appear
    // on top of the line.
    //
    // This is especially useful for small targets such as
    // 10, 20, etc., where the gaps between beads are larger.
    //

    final connectingLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFC49A5A)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      connectingLinePaint,
    );

    // ------------------------------------------------------------
    // GURU BEAD
    // ------------------------------------------------------------

    final guruBeadRadius = 11.0;
    final guruAngle = -pi / 2;

    final guruX = center.dx + radius * cos(guruAngle);
    final guruY = center.dy + radius * sin(guruAngle);

    final guruPosition = Offset(guruX, guruY);

    // Outer guru bead
    paint.color = completedColor;

    canvas.drawCircle(
      guruPosition,
      guruBeadRadius,
      paint,
    );

    // Inner gold section
    paint.color = remainingColor;

    canvas.drawCircle(
      guruPosition,
      guruBeadRadius - 3.5,
      paint,
    );

    // Center
    paint.color = completedColor;

    canvas.drawCircle(
      guruPosition,
      guruBeadRadius - 7,
      paint,
    );

    // ------------------------------------------------------------
    // COMPLETION CALCULATION
    // ------------------------------------------------------------

    final currentCycleCount = count % beadCount;

    final isFullCycle =
        count > 0 && currentCycleCount == 0;

    final effectiveCount =
    isFullCycle ? beadCount : currentCycleCount;

    // ------------------------------------------------------------
    // DRAW BEADS
    // ------------------------------------------------------------

    final step = 2 * pi / (beadCount + 1);

    for (int i = 0; i < beadCount; i++) {
      final angle =
          -pi / 2 + step * (i + 1);

      final x =
          center.dx + radius * cos(angle);

      final y =
          center.dy + radius * sin(angle);

      final position = Offset(x, y);

      // ----------------------------------------------------------
      // BEAD SIZE
      // ----------------------------------------------------------

      double beadRadius = 5.5;

      // Special beads for a 108 mala
      if (beadCount == 108 &&
          ((i + 1) == 27 ||
              (i + 1) == 54 ||
              (i + 1) == 81)) {
        beadRadius = 7.0;
      }

      // ----------------------------------------------------------
      // COMPLETED STATUS
      // ----------------------------------------------------------

      bool isCompleted = i < effectiveCount;

      if (count >= beadCount &&
          effectiveCount == beadCount) {
        isCompleted = true;
      }

      // ----------------------------------------------------------
      // COLORS
      // ----------------------------------------------------------

      if (isCompleted) {
        paint.color = completedColor;
        strokePaint.color = strokeColorCompleted;
      } else {
        paint.color = remainingColor;
        strokePaint.color = strokeColorRemaining;
      }

      // ----------------------------------------------------------
      // DRAW BEAD
      // ----------------------------------------------------------

      canvas.drawCircle(
        position,
        beadRadius,
        paint,
      );

      canvas.drawCircle(
        position,
        beadRadius,
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant MalaPainter oldDelegate,
      ) {
    return oldDelegate.count != count ||
        oldDelegate.target != target ||
        oldDelegate.themeColor != themeColor;
  }
}
