import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/features/auth/screens/widgets/customPinPut_widget.dart';

import '../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../core/network_connection_checker/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/secure_stroage_service.dart';
import '../../common/screens/main_screen.dart';
import '../controller/localAuth_controller.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController pinController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _breathingAnimation;
  final connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();

    // Breathing animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.75, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🔹 First check internet before biometrics
      final hasInternet = await connectivityService.hasInternet();
      if (!mounted) return;

      if (!hasInternet) {
        _showNoInternetPopup();
      } else {
        // ✅ Continue with biometrics when online
        ref
            .read(localAuthProvider.notifier)
            .authenticateWithBiometrics(context);
      }
    });
  }

  Future<void> _showNoInternetPopup() async {
    showNoInternetPopup(
      context: context,
      onPressed: () async {
        Navigator.of(context).pop();

        final hasInternet = await connectivityService.hasInternet();

        if (!mounted) return;

        if (!hasInternet) {
          _showNoInternetPopup(); // 🔄 keep showing until back online
        } else {
          // ✅ Resume biometrics once connected
          ref
              .read(localAuthProvider.notifier)
              .authenticateWithBiometrics(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(localAuthProvider);
    final user = ref.watch(userDataProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Greeting Animated Card
              ScaleTransition(
                scale: _breathingAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.15),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        radius: 26.r,
                        child: Icon(
                          Icons.person,
                          size: 26.r,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      12.widthBox,
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder:
                              (child, anim) => FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(
                                  scale: anim,
                                  child: child,
                                ),
                              ),
                          child: Text(
                            "${greeting.tr()}, ${user?.empName ?? "Employee"} 👋",
                            key: ValueKey(user?.empName),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              30.heightBox,

              /// Heading Card (MATCHED STYLE)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.12),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      transitionBuilder:
                          (child, anim) => FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(scale: anim, child: child),
                          ),
                      child: Text(
                        authState.hasPin
                            ? "enterYourPin".tr()
                            : "createYourPin".tr(),
                        key: ValueKey(
                          authState.hasPin ? "enterYourPin" : "createYourPin",
                        ),
                        style: AppTextStyles.largeFont().copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    8.heightBox,
                    Text(
                      "enterPinForSafety".tr(),
                      style: AppTextStyles.smallFont().copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              30.heightBox,

              /// PIN Input
              CustomPinPutWidget(
                controller: pinController,
                onCompleted: (pin) => _confirmPin(),
              ),

              40.heightBox,

              /// Logout with Icon
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    await SecureStorageService.clearAll();
                    ref.invalidate(userDataProvider);
                    ref.invalidate(localAuthProvider);
                    NavigationService.navigateRemoveUntil(
                      context: context,
                      screen: LoginScreen(),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    "Log out".tr(),
                    style: AppTextStyles.mediumFont(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _confirmPin() async {
    final authState = ref.watch(localAuthProvider);
    final authNotifier = ref.read(localAuthProvider.notifier);

    if (authState.hasPin) {
      final isValid = await authNotifier.verifyPin(pinController.text, context);
      if (isValid && mounted) {
        NavigationService.navigateRemoveUntil(
          context: context,
          screen: const MainScreen(),
        );
      } else {
        showCustomAlertBox(
          context,
          title: 'invalidPin'.tr(),
          content: 'pleaseTryAgain'.tr(),
          type: AlertType.error,
          primaryButtonText: 'retry'.tr(),
          onPrimaryPressed: () {
            pinController.clear();
            Navigator.pop(context);
          },
        );
      }
    } else {
      await authNotifier.savePin(pinController.text);
      if (mounted) {
        NavigationService.navigateRemoveUntil(
          context: context,
          screen: const MainScreen(),
        );
      }
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
