import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';

class CustomScreenLoader extends StatefulWidget {
  final String loadingText;
  final Color? primaryColor;
  final bool showGradientBackground;
  final double? loaderSize;

  const CustomScreenLoader({
    Key? key,
    required this.loadingText,
    this.primaryColor,
    this.showGradientBackground = false,
    this.loaderSize,
  }) : super(key: key);

  @override
  State<CustomScreenLoader> createState() => _CustomScreenLoaderState();
}

class _CustomScreenLoaderState extends State<CustomScreenLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? AppTheme.primaryColor;
    final loaderSize = widget.loaderSize ?? 80.w;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedLoader(color, loaderSize),
            SizedBox(height: 24.h),
            _buildLoadingText(color),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader(Color color, double size) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: CustomPaint(
                  painter: LoaderPainter(
                    progress: _rotationController.value,
                    color: color,
                  ),
                ),
              ),
            ),
            // Inner pulsing circle
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.8 + (0.4 * _pulseController.value);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size * 0.5,
                    height: size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
            // Center dot
            Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingText(Color color) {
    return FadeTransition(
      opacity: _textController,
      child: Column(
        children: [
          Text(
            widget.loadingText.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          _buildAnimatedDots(color),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots(Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animValue = ((value - delay) * 2).clamp(0.0, 1.0);
            final opacity = animValue > 1 ? (2 - animValue) : animValue;

            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 100)),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

// Custom painter for the loading ring
class LoaderPainter extends CustomPainter {
  final double progress;
  final Color color;

  LoaderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress, // Progress amount
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
