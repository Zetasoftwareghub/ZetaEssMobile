import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/auth/screens/createPin_screen.dart';

import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/controller/localAuth_controller.dart';
import '../../../auth/screens/widgets/customPinPut_widget.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final TextEditingController pinController = TextEditingController();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(localAuthProvider);
    final authNotifier = ref.read(localAuthProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('reset_your_pin'.tr(), style: AppTextStyles.largeFont()),
              Text("pin_description".tr(), style: AppTextStyles.smallFont()),
              30.heightBox,
              CustomPinPutWidget(controller: pinController),

              50.heightBox,
              CustomElevatedButton(
                onPressed: () async {
                  if (pinController.text.length < 3) {
                    showSnackBar(
                      context: context,
                      content: "enterPinToConfirm".tr(),
                      color: AppTheme.errorColor,
                    );
                    return;
                  }

                  showCustomAlertBox(
                    context,
                    title: 'change_pin_title'.tr(), // Change PIN?
                    content:
                        'change_pin_info'
                            .tr(), // You will need to enter this PIN from now on to open the app.
                    type: AlertType.info,
                    primaryButtonText: 'confirm'.tr(),
                    secondaryButtonText: 'cancel'.tr(),
                    onPrimaryPressed: () {
                      showSnackBar(
                        content: 'Pin updated successfully',
                        context: context,
                      );
                      authNotifier.savePin(pinController.text);
                      NavigationService.navigateRemoveUntil(
                        context: context,
                        screen: CreatePinScreen(),
                      );
                    },
                  );
                },
                child: Text("save".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
