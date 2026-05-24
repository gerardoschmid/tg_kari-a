import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);

    const double verticalSpacing = 220;
    final offsets = [0.0, 80.0, -80.0, 0.0];

    for (int i = 0; i < offsets.length; i++) {
      double targetY = 140 + i * verticalSpacing;
      double targetX = size.width / 2 + offsets[i];
      if (i == 0) {
        path.lineTo(targetX, targetY);
      } else {
        double prevY = 140 + (i - 1) * verticalSpacing;
        double prevX = size.width / 2 + offsets[i - 1];
        path.cubicTo(
          prevX,
          prevY + verticalSpacing / 2,
          targetX,
          targetY - verticalSpacing / 2,
          targetX,
          targetY,
        );
      }
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
