/*
// TODO old standard splash screen
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';

import '../core/constants/constants.dart';
import '../core/theme/app_theme.dart';
import 'auth/controller/localAuth_controller.dart';
import 'auth/screens/createPin_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationFunction();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Constants.logoPath,
                      height: screenSize.width * 0.4,
                      width: screenSize.width * 0.4,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Zeta HRMS',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> animationFunction() async {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    await ref.read(localAuthProvider.notifier).loadInitialAuthState();
    await ref.read(storageRepositoryProvider.notifier).loadLocalStorageValues();
    print(ref.watch(userDataProvider));
    Timer(const Duration(seconds: 3), () {
      final authState = ref.read(localAuthProvider);
      //TODO check this validation from splash screen
      if (authState.hasPin || authState.isAuthenticated && authState.urlExist) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CreatePinScreen()),
        );
      } else if (authState.urlExist) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ActivationUrlScreen()),
        );
      }
    });
  }
}
*/

// TODO THIS SPLASH IS AWESOME BUT ACTIVATION URL IS NOT WORKING !!!
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';

import '../core/constants/constants.dart';
import '../core/theme/app_theme.dart';
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
  late AnimationController _masterController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _wavesController;

  // Logo Animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<double> _logoRotationAnimation;

  // Text Animations
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _taglineFadeAnimation;

  // Background Animations
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _gradientAnimation;

  // Progress Animations
  late Animation<double> _progressFadeAnimation;
  late Animation<double> _progressValueAnimation;

  // Loading States
  bool _showProgress = false;
  String _loadingText = 'Initializing Enterprise Systems...';
  double _progressValue = 0.0;

  final List<String> _loadingStages = [
    'Initializing Enterprise Systems...',
    'Securing Authentication Layer...',
    'Loading User Configurations...',
    'Synchronizing Global Data...',
    'Optimizing Performance...',
    'Finalizing Setup...',
    'Welcome to Zeta HRMS',
  ];

  int _currentStage = 0;

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
    _startEnterpriseAnimation();
  }

  void _initializeAnimations() {
    // Master controller for overall timing
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Individual controllers
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _wavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _initializeAnimationTweens();
  }

  void _initializeAnimationTweens() {
    // Logo Animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Text Animations
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // Background Animations
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _wavesController, curve: Curves.linear));

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    // Progress Animations
    _progressFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _progressValueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  Future<void> _startEnterpriseAnimation() async {
    // Start master animation
    _masterController.forward();

    // Staggered animation start
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _showProgress = true;
      });
      _progressController.forward();
      await _performEnterpriseInitialization();
    }
  }

  Future<void> _performEnterpriseInitialization() async {
    try {
      for (int i = 0; i < _loadingStages.length; i++) {
        if (!mounted) return;

        setState(() {
          _currentStage = i;
          _loadingText = _loadingStages[i];
          _progressValue = (i + 1) / _loadingStages.length;
        });

        // Simulate enterprise-level loading with different durations
        switch (i) {
          case 0: // Initializing
            await Future.delayed(const Duration(milliseconds: 800));
            break;
          case 1: // Authentication
            await ref.read(localAuthProvider.notifier).loadInitialAuthState();
            await Future.delayed(const Duration(milliseconds: 600));
            break;
          case 2: // User Config
            await ref
                .read(storageRepositoryProvider.notifier)
                .loadLocalStorageValues();
            await Future.delayed(const Duration(milliseconds: 700));
            break;
          case 3: // Global Data
            await Future.delayed(const Duration(milliseconds: 900));
            break;
          case 4: // Performance
            await Future.delayed(const Duration(milliseconds: 500));
            break;
          case 5: // Finalizing
            await Future.delayed(const Duration(milliseconds: 600));
            break;
          case 6: // Welcome
            await Future.delayed(const Duration(milliseconds: 800));
            break;
        }
      }

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateWithEnterpriseTransition();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingText = 'Enterprise system ready with fallback mode';
          _progressValue = 1.0;
        });
        await Future.delayed(const Duration(milliseconds: 1000));
        _navigateWithEnterpriseTransition();
      }
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
    _masterController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    _wavesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _masterController,
          _logoController,
          _particleController,
          _textController,
          _progressController,
          _glowController,
          _wavesController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF1A1A2E),
                    AppTheme.primaryColor,
                    _gradientAnimation.value * 0.3,
                  )!,
                  Color.lerp(
                    const Color(0xFF16213E),
                    AppTheme.primaryColor.withOpacity(0.8),
                    _gradientAnimation.value * 0.2,
                  )!,
                  Color.lerp(
                    const Color(0xFF0F3460),
                    AppTheme.primaryColor.withOpacity(0.6),
                    _gradientAnimation.value * 0.1,
                  )!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated waves background
                _buildAnimatedWaves(),

                // Floating particles
                _buildFloatingParticles(),

                // Main content with glassmorphism
                Center(
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: _buildMainContent(screenSize),
                        ),
                      ),
                    ),
                  ),
                ),

                // Enterprise branding elements
                _buildEnterpriseBranding(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Premium logo with glow effect
        Transform.rotate(
          angle: _logoRotationAnimation.value,
          child: FadeTransition(
            opacity: _logoFadeAnimation,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Container(
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(
                        0.3 + (_logoGlowAnimation.value * 0.4),
                      ),
                      blurRadius: 40 + (_logoGlowAnimation.value * 20),
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Image.asset(
                  Constants.logoPath,
                  height: screenSize.width * 0.3,
                  width: screenSize.width * 0.3,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 50.h),

        // Enterprise title with premium styling
        Transform.translate(
          offset: Offset(0, _titleSlideAnimation.value),
          child: FadeTransition(
            opacity: _titleFadeAnimation,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                          AppTheme.primaryColor.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ).createShader(bounds),
                  child: Text(
                    'ZETA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8.0,
                      height: 1.0,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: Text(
                    'HRMS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // Enterprise subtitle
        FadeTransition(
          opacity: _subtitleFadeAnimation,
          child: Text(
            'ENTERPRISE HUMAN RESOURCE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // Tagline
        FadeTransition(
          opacity: _taglineFadeAnimation,
          child: Text(
            'MANAGEMENT SYSTEM',
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),

        SizedBox(height: 80.h),

        // Enterprise progress indicator
        AnimatedOpacity(
          opacity: _showProgress ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 800),
          child: _buildEnterpriseProgress(),
        ),
      ],
    );
  }

  Widget _buildEnterpriseProgress() {
    return Column(
      children: [
        // Progress bar with glow
        Container(
          width: 280.w,
          height: 6.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor.withOpacity(0.9),
              ),
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Loading text with typewriter effect
        Container(
          height: 30.h,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _loadingText,
              key: ValueKey(_loadingText),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Progress percentage
        Text(
          '${(_progressValue * 100).toInt()}%',
          style: TextStyle(
            color: AppTheme.primaryColor.withOpacity(0.9),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedWaves() {
    return Positioned.fill(
      child: CustomPaint(painter: WavesPainter(_waveAnimation.value)),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: CustomPaint(painter: ParticlesPainter(_particleAnimation.value)),
    );
  }

  Widget _buildEnterpriseBranding() {
    return Positioned(
      bottom: 40.h,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _taglineFadeAnimation,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30.w,
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'POWERED BY ZETA SOFTWARES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Container(
                  width: 30.w,
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Enterprise Grade • Global Scale • Secure',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 9.sp,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painters for advanced graphics
class WavesPainter extends CustomPainter {
  final double animation;

  WavesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    final path = Path();

    // Create flowing waves
    for (int i = 0; i < 3; i++) {
      path.reset();
      final waveHeight = 60.0 + (i * 20);
      final frequency = 0.02 + (i * 0.01);
      final phase = animation * 2 * math.pi + (i * math.pi / 3);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 2) {
        final y =
            size.height -
            waveHeight +
            math.sin(x * frequency + phase) * (30 + i * 10);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      paint.color = Colors.white.withOpacity(0.02 + i * 0.01);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlesPainter extends CustomPainter {
  final double animation;

  ParticlesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 30; i++) {
      final x = (size.width * (i * 0.1 + animation * 0.1)) % size.width;
      final y = (size.height * (i * 0.05 + animation * 0.05)) % size.height;
      final opacity = (math.sin(animation * 2 + i) + 1) / 2;
      final radius = 1.0 + math.sin(animation + i) * 0.5;

      paint.color = Colors.white.withOpacity(opacity * 0.3);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
