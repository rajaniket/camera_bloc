import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';

class RecordingProgressIndicator extends StatelessWidget {
  const RecordingProgressIndicator({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue = 15,
  });
  final double value;
  final double minValue;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialGaugePainter(
        maxValue: maxValue,
        minValue: minValue,
        value: value,
      ),
    );
  }
}

class RadialGaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;

  RadialGaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double minSide = min(size.height, size.width); // diameter
    final double centerX = minSide / 2;
    final double centerY = minSide / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = minSide / 2;
    const double strokeWidth = 5;

    // Paint for the track of the progress
    final Paint progressTrackPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..colorFilter = ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint for the background gradient
    final Paint backGroundpaint = Paint()
      ..shader = SweepGradient(
        colors: progressBackgroundColor,
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        tileMode: TileMode.repeated,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..colorFilter = const ColorFilter.mode(Colors.black38, BlendMode.darken)
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth;

    // Paint for the progress arc
    final Paint progressStrokePaint = Paint()
      ..shader = SweepGradient(
        colors: progressStrokeColor,
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        tileMode: TileMode.repeated,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * value / maxValue;

    // Draw the track of the progress
    canvas.drawCircle(center, radius + 2, progressTrackPaint);

    // Draw the background gradient arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      backGroundpaint,
    );

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 2),
      startAngle,
      sweepAngle,
      false,
      progressStrokePaint,
    );

    // Calculate text position
    final double x = centerX + radius * cos(sweepAngle + startAngle);
    final double y = centerY + radius * sin(sweepAngle + startAngle);
    final Offset textCenter = Offset(x, y);
    const double textBorderRadius = 10;

    // Paint for the text background
    Paint textBackPaint = Paint()..color = Colors.black.withOpacity(0.85);

    // Paint for the text border
    Paint textBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw a line connecting the center and the text center
    canvas.drawLine(center, textCenter, textBorderPaint);

    // Draw the text background circle
    canvas.drawCircle(textCenter, textBorderRadius, textBackPaint);
    // Draw the border for the text background circle
    canvas.drawCircle(textCenter, textBorderRadius, textBorderPaint);

    // Draw the text
    final TextSpan textSpan = TextSpan(
      text: "${(value).toInt()}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10.0,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final Offset textOffset = Offset(x - textPainter.width / 2, y - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
