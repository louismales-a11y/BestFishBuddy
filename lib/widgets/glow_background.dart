import 'dart:math';
import 'package:flutter/material.dart';

/// Animated gradient orbs background for a futuristic feel.
class GlowBackground extends StatefulWidget {
  final Widget child;

  const GlowBackground({super.key, required this.child});

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildGradient(_controller.value, isDark),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  RadialGradient _buildGradient(double t, bool isDark) {
    final base = isDark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFF0F4FF);

    // Moving glow spots
    final x1 = (sin(t * 2 * pi * 0.7) + 1) / 2;
    final y1 = (cos(t * 2 * pi * 0.5) + 1) / 2;
    final x2 = (sin(t * 2 * pi * 0.3 + 1.5) + 1) / 2;
    final y2 = (cos(t * 2 * pi * 0.6 + 2.1) + 1) / 2;

    return RadialGradient(
      center: Alignment(x1 * 2 - 1, y1 * 2 - 1),
      radius: 1.2,
      colors: [
        const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.06 : 0.04),
        base,
        const Color(0xFFD500F9).withValues(alpha: isDark ? 0.04 : 0.03),
        base,
        const Color(0xFF76FF03).withValues(alpha: isDark ? 0.03 : 0.02),
        base,
      ],
      stops: [
        0.0,
        _wobble(t * 0.5, 0.2),
        _wobble(t * 0.7 + 0.3, 0.4),
        _wobble(t * 0.4 + 0.6, 0.6),
        _wobble(t * 0.6 + 0.9, 0.8),
        1.0,
      ],
    );
  }

  double _wobble(double t, double offset) {
    return (sin(t * 2 * pi) / 8 + offset).clamp(0.0, 1.0);
  }
}
