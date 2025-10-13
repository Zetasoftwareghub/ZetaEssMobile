import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class Loader extends StatelessWidget {
//   final Color? color;
//   const Loader({super.key, this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: CupertinoActivityIndicator(
//         color: color ?? AppTheme.primaryColor,
//         radius: 14.r,
//       ),
//     );
//   }
// }

class Loader extends StatefulWidget {
  final Color? color;
  const Loader({super.key, this.color});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaderColor = widget.color ?? Theme.of(context).primaryColor;

    return Center(
      child: SizedBox(
        width: 60.r,
        height: 60.r,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _OrbitLoaderPainter(
                color: loaderColor,
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrbitLoaderPainter extends CustomPainter {
  final Color color;
  final double progress;

  _OrbitLoaderPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Create multiple orbiting dots with different speeds and colors
    final dots = [
      _DotConfig(
        angle: progress * 2 * math.pi,
        radius: radius,
        size: 6.0,
        opacity: 1.0,
      ),
      _DotConfig(
        angle: progress * 2 * math.pi + (2 * math.pi / 3),
        radius: radius,
        size: 5.0,
        opacity: 0.8,
      ),
      _DotConfig(
        angle: progress * 2 * math.pi + (4 * math.pi / 3),
        radius: radius,
        size: 4.5,
        opacity: 0.6,
      ),
    ];

    // Draw orbital path
    final pathPaint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, pathPaint);

    // Draw pulsing center
    final pulseSize = 4.0 + math.sin(progress * 4 * math.pi) * 2.0;
    final centerPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, pulseSize, centerPaint);

    // Draw orbiting dots with trails
    for (var i = 0; i < dots.length; i++) {
      final dot = dots[i];
      final x = center.dx + dot.radius * math.cos(dot.angle);
      final y = center.dy + dot.radius * math.sin(dot.angle);

      // Draw trail (previous positions)
      for (var j = 1; j <= 5; j++) {
        final trailAngle = dot.angle - (j * 0.15);
        final trailX = center.dx + dot.radius * math.cos(trailAngle);
        final trailY = center.dy + dot.radius * math.sin(trailAngle);
        final trailOpacity = dot.opacity * (1 - j * 0.15);
        final trailSize = dot.size * (1 - j * 0.12);

        final trailPaint =
            Paint()
              ..color = color.withOpacity(trailOpacity.clamp(0.0, 1.0))
              ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(trailX, trailY), trailSize, trailPaint);
      }

      // Draw main dot with glow
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(x, y), dot.size + 4, glowPaint);

      final dotPaint =
          Paint()
            ..color = color.withOpacity(dot.opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), dot.size, dotPaint);

      // Draw inner highlight
      final highlightPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x - dot.size * 0.2, y - dot.size * 0.2),
        dot.size * 0.4,
        highlightPaint,
      );
    }

    // Draw connecting lines between dots
    final linePaint =
        Paint()
          ..color = color.withOpacity(0.2)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    for (var i = 0; i < dots.length; i++) {
      final dot1 = dots[i];
      final dot2 = dots[(i + 1) % dots.length];

      final x1 = center.dx + dot1.radius * math.cos(dot1.angle);
      final y1 = center.dy + dot1.radius * math.sin(dot1.angle);
      final x2 = center.dx + dot2.radius * math.cos(dot2.angle);
      final y2 = center.dy + dot2.radius * math.sin(dot2.angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _DotConfig {
  final double angle;
  final double radius;
  final double size;
  final double opacity;

  _DotConfig({
    required this.angle,
    required this.radius,
    required this.size,
    required this.opacity,
  });
}
