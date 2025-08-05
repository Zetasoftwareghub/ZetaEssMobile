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
import '../../../core/theme/app_theme.dart';
import '../../../services/secure_stroage_service.dart';
import '../../common/screens/main_screen.dart';
import '../controller/localAuth_controller.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final TextEditingController pinController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localAuthProvider.notifier).authenticateWithBiometrics(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(localAuthProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      radius: 24.r,
                      child: Icon(
                        Icons.person_sharp,
                        size: 24.r,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    12.widthBox,
                    Flexible(
                      child: Text(
                        ref.watch(userDataProvider)?.empName ?? "",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    12.widthBox,
                  ],
                ),
              ),
              20.heightBox,
              Text(
                authState.hasPin ? "enterYourPin".tr() : "createYourPin".tr(),
                style: AppTextStyles.largeFont(),
              ),
              Text("enterPinForSafety".tr(), style: AppTextStyles.smallFont()),
              20.heightBox,
              CustomPinPutWidget(
                controller: pinController,
                onCompleted: (pin) => _confirmPin(),
              ),
              25.heightBox,

              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await SecureStorageService.clearAll();
                    ref.invalidate(userDataProvider);
                    ref.invalidate(localAuthProvider);
                    NavigationService.navigateRemoveUntil(
                      context: context,
                      screen: LoginScreen(),
                    );
                  },
                  icon: const Icon(Icons.arrow_back, size: 16),
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
        Future.delayed(Duration.zero, () {
          NavigationService.navigateRemoveUntil(
            context: context,
            screen: const MainScreen(),
          );
        });
      } else {
        showCustomAlertBox(
          context,
          title: 'invalidPin'.tr(),
          content: 'pleaseTryAgain'.tr(),
          type: AlertType.error,
          primaryButtonText: 'retry'.tr(),
          onPrimaryPressed: () => Navigator.pop(context),
        );
      }
    } else {
      await authNotifier.savePin(pinController.text);
      Future.delayed(Duration.zero, () {
        NavigationService.navigateRemoveUntil(
          context: context,
          screen: const MainScreen(),
        );
      });
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}
