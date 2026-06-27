import 'dart:math';
import 'package:flutter/material.dart';

/// Realistic static water background — like a photograph of a lake.
/// Uses deep blue gradients, multiple wave layers, and specular highlights.
class WaterBackground extends StatelessWidget {
  final Widget child;

  const WaterBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
          colors: isDark
              ? [
                  const Color(0xFF0A1628), // surface
                  const Color(0xFF0D1F3C), // shallow
                  const Color(0xFF0F2847), // mid
                  const Color(0xFF0A1F3A), // deep
                  const Color(0xFF06101E), // deepest
                ]
              : [
                  const Color(0xFFB3D9F7), // sky reflection
                  const Color(0xFF85BDE6), // shallow
                  const Color(0xFF5FA3D9), // mid
                  const Color(0xFF4A8FC7), // deep
                  const Color(0xFF3A7AB5), // deepest
                ],
        ),
      ),
      child: Stack(
        children: [
          // Main water surface waves
          Positioned.fill(
            child: CustomPaint(
              painter: _WaterPainter(
                primaryColor: isDark
                    ? primary.withValues(alpha: 0.15)
                    : primary.withValues(alpha: 0.12),
                highlightColor: Colors.white.withValues(alpha: isDark ? 0.06 : 0.08),
                deepColor: isDark
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.05)
                    : const Color(0xFF0D47A1).withValues(alpha: 0.04),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final Color primaryColor;
  final Color highlightColor;
  final Color deepColor;

  _WaterPainter({
    required this.primaryColor,
    required this.highlightColor,
    required this.deepColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Deep water texture (subtle vertical variation)
    _drawDeepTexture(canvas, size);

    // Main wave bands
    _drawWaveBands(canvas, size);

    // Specular highlights (light reflections on the surface)
    _drawHighlights(canvas, size);

    // Small ripple detail
    _drawRipples(canvas, size);
  }

  void _drawDeepTexture(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = deepColor
      ..strokeWidth = 0.5;

    final rng = Random(100);
    for (var i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final len = 20 + rng.nextDouble() * 60;
      final angle = rng.nextDouble() * pi;
      paint.color = deepColor.withValues(alpha: deepColor.opacity * (0.3 + rng.nextDouble() * 0.7));
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * len, y + sin(angle) * len * 0.3),
        paint,
      );
    }
  }

  void _drawWaveBands(Canvas canvas, Size size) {
    final rng = Random(42);
    final bandCount = 8;

    for (var b = 0; b < bandCount; b++) {
      final baseY = size.height * (0.05 + 0.11 * b + rng.nextDouble() * 0.03);
      final waveHeight = 8 + rng.nextDouble() * 14;
      final freq = 0.3 + rng.nextDouble() * 0.5;
      final phase = rng.nextDouble() * 2 * pi;
      final thickness = 1.5 + rng.nextDouble() * 2.0;

      // Each band is a filled translucent shape
      final paint = Paint()
        ..color = primaryColor.withValues(alpha: primaryColor.opacity * (0.4 + 0.6 * (1 - b / bandCount)))
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final yOffset = sin(phase + b * 0.7) * (waveHeight * 0.3);

      path.moveTo(-10, baseY + yOffset);
      for (double x = -10; x <= size.width + 10; x += 3) {
        final y = baseY +
            yOffset +
            sin(x * freq * 0.01 + phase) * waveHeight +
            sin(x * freq * 0.023 + phase * 1.4) * (waveHeight * 0.35);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);

      // Secondary band slightly offset (water layer effect)
      final paint2 = Paint()
        ..color = primaryColor.withValues(alpha: primaryColor.opacity * (0.2 + 0.3 * (1 - b / bandCount)))
        ..strokeWidth = thickness * 0.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path2 = Path();
      final offsetY = 6 + rng.nextDouble() * 8;
      path2.moveTo(-10, baseY + offsetY);
      for (double x = -10; x <= size.width + 10; x += 3) {
        final y = baseY +
            offsetY +
            sin(x * freq * 0.012 + phase + 1.2) * (waveHeight * 0.7) +
            sin(x * freq * 0.025 + phase * 1.6) * (waveHeight * 0.25);
        path2.lineTo(x, y);
      }
      canvas.drawPath(path2, paint2);
    }
  }

  void _drawHighlights(Canvas canvas, Size size) {
    final rng = Random(77);
    final highlightCount = 15;

    for (var h = 0; h < highlightCount; h++) {
      final x = 20 + rng.nextDouble() * (size.width - 40);
      final y = rng.nextDouble() * size.height;
      final length = 15 + rng.nextDouble() * 40;
      final alpha = 0.3 + rng.nextDouble() * 0.7;

      final paint = Paint()
        ..color = highlightColor.withValues(alpha: highlightColor.opacity * alpha)
        ..strokeWidth = 1.0 + rng.nextDouble() * 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final waveAmp = 2 + rng.nextDouble() * 3;
      final waveFreq = 0.2 + rng.nextDouble() * 0.3;

      path.moveTo(x, y);
      for (double dx = 0; dx <= length; dx += 2) {
        path.lineTo(
          x + dx,
          y + sin(dx * waveFreq) * waveAmp,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawRipples(Canvas canvas, Size size) {
    final rng = Random(123);
    final rippleCount = 30;

    for (var r = 0; r < rippleCount; r++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final radius = 8 + rng.nextDouble() * 30;
      final alpha = 0.2 + rng.nextDouble() * 0.5;

      final paint = Paint()
        ..color = primaryColor.withValues(alpha: primaryColor.opacity * alpha * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 + rng.nextDouble() * 0.5;

      // Draw a partial elliptical arc (ripple ring fragment)
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
      final startAngle = rng.nextDouble() * 2 * pi;
      final sweepAngle = 0.5 + rng.nextDouble() * 1.5;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(_WaterPainter oldDelegate) => false;
}
