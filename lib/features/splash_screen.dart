import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';

import '../core/constants/constants.dart';
import '../core/providers/storage_repository_provider.dart';
import 'auth/controller/localAuth_controller.dart';
import 'auth/screens/createPin_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _toolsController;
  late AnimationController _particlesController;
  late AnimationController _pulseController;

  // Logo Animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;

  // Tools Showcase Animations
  late Animation<double> _toolsRevealAnimation;
  late Animation<double> _toolsOrbitAnimation;
  late Animation<double> _toolsGlowAnimation;

  // Background Animations
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _pulseAnimation;

  // HR Tools Data
  final List<HRTool> _hrTools = [
    HRTool(
      icon: Icons.group,
      label: 'Employee\nManagement',
      color: const Color(0xFF4CAF50),
    ),
    HRTool(
      icon: Icons.event_available,
      label: 'Attendance\nTracking',
      color: const Color(0xFF2196F3),
    ),
    HRTool(
      icon: Icons.payment,
      label: 'Payroll\nSystem',
      color: const Color(0xFFFF9800),
    ),
    HRTool(
      icon: Icons.assessment,
      label: 'Salary\nAnalytics',
      color: const Color(0xFF9C27B0),
    ),
    HRTool(
      icon: Icons.schedule,
      label: 'Leave\nManagement',
      color: const Color(0xFFF44336),
    ),
    HRTool(
      icon: Icons.bar_chart,
      label: 'HR\nReports',
      color: const Color(0xFF00BCD4),
    ),
  ];

  int _currentToolIndex = 0;
  String _currentStatus = 'Initializing Modern HRMS...';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initializeAnimations();
    _startModernAnimation();
  }

  void _initializeAnimations() {
    // Main controller - 3 seconds total
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Logo controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Tools showcase controller
    _toolsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Continuous animations
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initializeAnimationTweens();
  }

  void _initializeAnimationTweens() {
    // Logo animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Tools animations
    _toolsRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _toolsController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _toolsOrbitAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _toolsController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _toolsGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Background animations
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particlesController, curve: Curves.linear),
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startModernAnimation() async {
    _mainController.forward();

    // Start logo animation immediately
    _logoController.forward();

    // Add delay before tools showcase starts
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      _toolsController.forward();

      // Add additional delay before tools showcase begins
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        await _startToolsShowcase(); // Wait for tools showcase to complete
      }
    }

    // Show welcome message and navigate
    if (mounted) {
      setState(() {
        _currentStatus = 'Welcome to Modern HRMS';
      });
      await Future.delayed(const Duration(milliseconds: 400));
      _navigateWithEnterpriseTransition();
    }
  }

  Future<void> _startToolsShowcase() async {
    for (int i = 0; i < _hrTools.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentToolIndex = i + 1;
        _currentStatus =
            'Loading ${_hrTools[i].label.replaceAll('\n', ' ')}...';
      });
      switch (i) {
        case 1: // Authentication/Attendance Tracking
          try {
            await ref.read(localAuthProvider.notifier).loadInitialAuthState();
          } catch (e) {
            // Continue with fallback if auth loading fails
          }
          break;
        case 2: // User Config/Payroll System
          try {
            await ref
                .read(storageRepositoryProvider.notifier)
                .loadLocalStorageValues();
          } catch (e) {
            // Continue with fallback if storage loading fails
          }
          break;
        default:
          // Regular delay for other tools
          break;
      }
      //TODO check this correctly
      // await ref.read(localAuthProvider.notifier).loadInitialAuthState();
      // await ref
      //     .read(storageRepositoryProvider.notifier)
      //     .loadLocalStorageValues();

      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void _navigateWithEnterpriseTransition() {
    final authState = ref.read(localAuthProvider);
    Widget nextScreen;
    if (authState.hasPin || authState.isAuthenticated && authState.urlExist) {
      nextScreen = const CreatePinScreen();
    } else if (authState.urlExist) {
      nextScreen = LoginScreen();
    } else {
      nextScreen = ActivationUrlScreen();
    }
    NavigationService.navigateRemoveUntil(context: context, screen: nextScreen);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _toolsController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _logoController,
          _toolsController,
          _particlesController,
          _pulseController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF0D1421),
                    const Color(0xFF1A237E),
                    _gradientAnimation.value * 0.6,
                  )!,
                  Color.lerp(
                    const Color(0xFF1A237E),
                    const Color(0xFF3949AB),
                    _gradientAnimation.value * 0.4,
                  )!,
                  Color.lerp(
                    const Color(0xFF3949AB),
                    const Color(0xFF5C6BC0),
                    _gradientAnimation.value * 0.3,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles background
                _buildModernParticles(screenSize),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Modern logo with pulse effect
                      _buildModernLogo(screenSize),

                      SizedBox(height: 40.h),

                      // Brand text
                      _buildBrandText(),

                      SizedBox(height: 60.h),

                      // HR Tools showcase
                      _buildToolsShowcase(screenSize),

                      SizedBox(height: 80.h),

                      // Status text
                      _buildStatusText(),
                    ],
                  ),
                ),

                // Modern branding
                _buildModernBranding(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernLogo(Size screenSize) {
    return Transform.rotate(
      angle: _logoRotateAnimation.value,
      child: FadeTransition(
        opacity: _logoFadeAnimation,
        child: ScaleTransition(
          scale: _logoScaleAnimation,
          child: Container(
            width: screenSize.width * 0.25,
            height: screenSize.width * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.transparent],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF5C6BC0,
                  ).withOpacity(0.4 + _pulseAnimation.value * 0.3),
                  blurRadius: 40 + (_pulseAnimation.value * 30),
                  spreadRadius: 10 + (_pulseAnimation.value * 10),
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Image.asset(
                  Constants.logoPath,
                  width: screenSize.width * 0.15,
                  height: screenSize.width * 0.15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandText() {
    return FadeTransition(
      opacity: _logoFadeAnimation,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFF5C6BC0),
                    const Color(0xFF3949AB),
                  ],
                ).createShader(bounds),
            child: Text(
              'ZETA HRMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Next-Generation HR Management',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsShowcase(Size screenSize) {
    return Container(
      width: screenSize.width * 0.7,
      height: screenSize.width * 0.7,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Central hub
          FadeTransition(
            opacity: _toolsRevealAnimation,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5C6BC0).withOpacity(0.8),
                    const Color(0xFF3949AB).withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5C6BC0).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(Icons.hub, color: Colors.white, size: 32.w),
            ),
          ),

          // Orbiting tools
          ...List.generate(_hrTools.length, (index) {
            final angle =
                (index * 2 * math.pi / _hrTools.length) +
                _toolsOrbitAnimation.value;
            final radius = screenSize.width * 0.25;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            final tool = _hrTools[index];
            final isActive = index < _currentToolIndex;

            return Transform.translate(
              offset: Offset(x, y),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 70.w : 50.w,
                height: isActive ? 70.w : 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isActive
                          ? tool.color.withOpacity(0.9)
                          : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color:
                        isActive ? Colors.white : Colors.white.withOpacity(0.3),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: tool.color.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _toolsRevealAnimation,
                      curve: Interval(
                        index * 0.1,
                        0.8 + (index * 0.02),
                        curve: Curves.elasticOut,
                      ),
                    ),
                  ),
                  child: Icon(
                    tool.icon,
                    color:
                        isActive ? Colors.white : Colors.white.withOpacity(0.5),
                    size: isActive ? 28.w : 20.w,
                  ),
                ),
              ),
            );
          }),

          // Connection lines
          if (_toolsRevealAnimation.value > 0.5)
            CustomPaint(
              size: Size(screenSize.width * 0.7, screenSize.width * 0.7),
              painter: ConnectionLinesPainter(
                _toolsOrbitAnimation.value,
                _currentToolIndex,
                _hrTools.length,
                screenSize.width * 0.25,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        _currentStatus,
        key: ValueKey(_currentStatus),
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModernParticles(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ModernParticlesPainter(_particleAnimation.value, screenSize),
      ),
    );
  }

  Widget _buildModernBranding() {
    return Positioned(
      bottom: 110.h,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _logoFadeAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Powered by Zeta Softwares',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

// HR Tool Data Model
class HRTool {
  final IconData icon;
  final String label;
  final Color color;

  HRTool({required this.icon, required this.label, required this.color});
}

// Custom Painters
class ModernParticlesPainter extends CustomPainter {
  final double animation;
  final Size screenSize;

  ModernParticlesPainter(this.animation, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw modern geometric particles
    for (int i = 0; i < 40; i++) {
      final progress = (animation + i * 0.1) % 1.0;
      final x = (size.width * (i * 0.15 + progress * 0.3)) % size.width;
      final y = (size.height * (i * 0.08 + progress * 0.2)) % size.height;
      final opacity = (math.sin(animation * 3 + i * 0.5) + 1) / 2;
      final size_particle = 2.0 + math.sin(animation * 2 + i) * 1.0;

      paint.color = Colors.white.withOpacity(opacity * 0.4);

      if (i % 3 == 0) {
        // Circles
        canvas.drawCircle(Offset(x, y), size_particle, paint);
      } else if (i % 3 == 1) {
        // Squares
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: size_particle * 2,
            height: size_particle * 2,
          ),
          paint,
        );
      } else {
        // Triangles
        final path = Path();
        path.moveTo(x, y - size_particle);
        path.lineTo(x - size_particle, y + size_particle);
        path.lineTo(x + size_particle, y + size_particle);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConnectionLinesPainter extends CustomPainter {
  final double orbitAnimation;
  final int activeToolsCount;
  final int totalTools;
  final double radius;

  ConnectionLinesPainter(
    this.orbitAnimation,
    this.activeToolsCount,
    this.totalTools,
    this.radius,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw connection lines from center to active tools
    for (int i = 0; i < math.min(activeToolsCount, totalTools); i++) {
      final angle = (i * 2 * math.pi / totalTools) + orbitAnimation;
      final endPoint = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      paint.color = Colors.white.withOpacity(0.3);
      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
