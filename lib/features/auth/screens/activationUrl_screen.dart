import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/auth/screens/widgets/activationUrl_textField.dart';

import '../../../core/common/loader.dart';
import '../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/common_theme.dart';
import '../controller/auth_controller.dart';

class ActivationUrlScreen extends ConsumerWidget {
  final TextEditingController _activationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ActivationUrlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This forces the widget to rebuild when locale changes
    context.locale;
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   actions: [_buildLanguageDropdown(context), 12.widthBox],
      // ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("welcomeTo".tr(), style: AppTextStyles.largeFont()),

                Text(
                  "ZETA HRMS",
                  style: AppTextStyles.largeFont(color: AppTheme.primaryColor),
                ),
                10.heightBox,

                Flexible(
                  child: Text(
                    "enterActivationLink".tr(),
                    style: AppTextStyles.smallFont(fontSize: 14.sp),
                  ),
                ),
                15.heightBox,

                ActivationUrlTextField(
                  labelText: "activationURL".tr(),
                  controller: _activationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'plsEnterUrl'.tr();
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print('Text changed: $value');
                  },
                ),
                30.heightBox,

                isLoading
                    ? Loader()
                    : CustomElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          showSnackBar(
                            content: 'plsEnterUrl'.tr(),
                            context: context,
                            color: AppTheme.errorColor,
                          );
                          return;
                        }

                        //THIS is for api calling without the https
                        final rawUrl = _activationController.text.trim();
                        final selectedProtocol = ref.read(
                          selectedProtocolProvider,
                        );

                        final cleanedUrl =
                            rawUrl.endsWith('/')
                                ? rawUrl.substring(0, rawUrl.length - 1)
                                : rawUrl;

                        final url =
                            (cleanedUrl.startsWith('http://') ||
                                    cleanedUrl.startsWith('https://'))
                                ? cleanedUrl
                                : '$selectedProtocol://$cleanedUrl';

                        ref
                            .read(authControllerProvider.notifier)
                            .activateUrl(url: url, context: context);
                      },
                      child: Text("activate".tr()),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          margin: EdgeInsets.only(top: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            color: AppTheme.primaryColor.withOpacity(0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 18, color: AppTheme.primaryColor),
              DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 3,
                  value:
                      ref.watch(localeLanguageProvider) ?? const Locale('en'),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      ref
                          .read(localeLanguageProvider.notifier)
                          .setLocale(newLocale);
                      context.setLocale(newLocale);
                    }
                  },

                  items: [
                    customDropdownMenuItem('en', 'English'),
                    customDropdownMenuItem('ar', 'العربية'),
                    customDropdownMenuItem('hi', 'हिन्दी'),
                    customDropdownMenuItem('ml', 'മലയാളം'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DropdownMenuItem<Locale> customDropdownMenuItem(
    String languageCode,
    String label,
  ) {
    return DropdownMenuItem(
      value: Locale(languageCode),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
