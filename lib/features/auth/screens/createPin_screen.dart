import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/auth/controller/auth_controller.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/features/auth/screens/widgets/customPinPut_widget.dart';

import '../../../core/api_constants/keys/storage_keys.dart';
import '../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../core/network_connection_checker/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/secure_stroage_service.dart';
import '../controller/localAuth_controller.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _breathingAnimation;
  final ConnectivityService _connectivityService = ConnectivityService();

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupBreathingAnimation();
    _schedulePostFrameInit();
  }

  void _setupBreathingAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.75, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _schedulePostFrameInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final hasInternet = await _connectivityService.hasInternet();
      if (!mounted) return;

      if (!hasInternet) {
        _showNoInternetPopup();
      } else {
        _triggerBiometrics();
      }
    });
  }

  void _triggerBiometrics() {
    // Not awaited intentionally here — biometrics runs in the background
    // while the PIN pad is visible. The result drives navigation internally
    // via loginUser (which IS awaited inside authenticateWithBiometrics).
    ref.read(localAuthProvider.notifier).authenticateWithBiometrics(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyStatusBarStyle();
  }

  void _applyStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Internet handling
  // ─────────────────────────────────────────────

  Future<void> _showNoInternetPopup() async {
    if (!mounted) return;
    showNoInternetPopup(
      context: context,
      onPressed: () async {
        Navigator.of(context).pop();
        if (!mounted) return;

        final hasInternet = await _connectivityService.hasInternet();
        if (!mounted) return;

        if (!hasInternet) {
          _showNoInternetPopup();
        } else {
          _triggerBiometrics();
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // PIN submission
  // ─────────────────────────────────────────────

  Future<void> _onPinCompleted() async {
    // ✅ ref.read — never ref.watch inside async callbacks.
    final authNotifier = ref.read(localAuthProvider.notifier);
    final authState = ref.read(localAuthProvider);
    final user = ref.read(userDataProvider);

    if (user == null) {
      // Credentials wiped — send user back to login.
      showSnackBar(
        context: context,
        content: 'User data cleared - please log in again.',
      );
      NavigationService.navigateRemoveUntil(
        context: context,
        screen: const LoginScreen(),
      );
      return;
    }

    // ── Lockout guard ────────────────────────────────────────────────
    if (authNotifier.isPinLocked) {
      _showPinLockedDialog();
      return;
    }

    if (authState.hasPin) {
      // ── Returning user: verify existing PIN ──────────────────────
      final isValid = await authNotifier.verifyPin(_pinController.text);
      if (!mounted) return; // Guard after every await.

      if (!isValid) {
        _pinController.clear();
        _showInvalidPinDialog(authNotifier.isPinLocked);
        return;
      }

      // PIN correct — authenticate against server.
      await ref
          .read(authControllerProvider.notifier)
          .loginUser(
            userName: user.userName,
            password: user.password,
            context: context,
            fromPinScreen: true,
          );
    } else {
      // ── First launch: create new PIN ─────────────────────────────
      await authNotifier.savePin(_pinController.text);
      if (!mounted) return;

      await ref
          .read(authControllerProvider.notifier)
          .loginUser(
            userName: user.userName,
            password: user.password,
            context: context,
            fromPinScreen: true,
          );
    }
  }

  // ─────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────

  void _showInvalidPinDialog(bool isNowLocked) {
    showCustomAlertBox(
      context,
      title: isNowLocked ? 'Account Locked'.tr() : 'invalidPin'.tr(),
      content:
          isNowLocked ? 'More than 10 attempts'.tr() : 'pleaseTryAgain'.tr(),
      type: AlertType.error,
      primaryButtonText: isNowLocked ? 'logOut'.tr() : 'retry'.tr(),
      onPrimaryPressed: () {
        Navigator.pop(context);
        if (isNowLocked) _logout();
      },
    );
  }

  void _showPinLockedDialog() {
    showCustomAlertBox(
      context,
      title: 'Account Locked'.tr(),
      content: 'More than 10 attempts'.tr(),
      type: AlertType.error,
      primaryButtonText: 'logOut'.tr(),
      onPrimaryPressed: () {
        Navigator.pop(context);
        _logout();
      },
    );
  }

  Future<void> _logout() async {
    await SecureStorageService.clearAll();
    ref.invalidate(userDataProvider);
    ref.invalidate(localAuthProvider);
    if (!mounted) return;
    NavigationService.navigateRemoveUntil(
      context: context,
      screen: const LoginScreen(),
    );
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ watch only what drives rebuilds — isLoading and the user display name.
    final isLoading = ref.watch(authControllerProvider);
    final user = ref.watch(userDataProvider);
    // ✅ read authState here — hasPin doesn't change while the screen is open.
    final authState = ref.read(localAuthProvider);

    _applyStatusBarStyle();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGreetingCard(user?.empName),
              30.heightBox,
              _buildHeadingCard(authState.hasPin),
              30.heightBox,
              isLoading
                  ? const Loader()
                  : CustomPinPutWidget(
                    controller: _pinController,
                    onCompleted: (_) => _onPinCompleted(),
                  ),
              40.heightBox,
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Sub-widgets
  // ─────────────────────────────────────────────

  Widget _buildGreetingCard(String? empName) {
    return ScaleTransition(
      scale: _breathingAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                child: Text(
                  '${greeting.tr()}, ${empName ?? "Employee"} 👋',
                  key: ValueKey(empName),
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
    );
  }

  Widget _buildHeadingCard(bool hasPin) {
    return Container(
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
              hasPin ? 'enterYourPin'.tr() : 'createYourPin'.tr(),
              key: ValueKey(hasPin),
              style: AppTextStyles.largeFont().copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          8.heightBox,
          Text(
            'enterPinForSafety'.tr(),
            style: AppTextStyles.smallFont().copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
        onPressed: _logout,
        icon: const Icon(Icons.logout, size: 18),
        label: Text('Log out'.tr(), style: AppTextStyles.mediumFont()),
      ),
    );
  }
}
