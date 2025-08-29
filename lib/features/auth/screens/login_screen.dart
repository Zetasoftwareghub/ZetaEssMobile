import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/features/auth/controller/auth_controller.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/NavigationService.dart';
import '../../../core/theme/common_theme.dart';
import '../../../core/utils.dart';
import '../../../models/company_model.dart';
import 'forgetPassword_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final obscureTextProvider = StateProvider<bool>((ref) => true);

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final obscureText = ref.watch(obscureTextProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("loginNow".tr(), style: AppTextStyles.largeFont()),
                  10.heightBox,
                  Text(
                    "enterCredentials".tr(),
                    style: AppTextStyles.smallFont(),
                  ),
                  30.heightBox,

                  Text("userName".tr(), style: AppTextStyles.mediumFont()),
                  10.heightBox,
                  TextFormField(
                    controller: userNameController,
                    decoration: _inputDecoration("enterUsername".tr()),
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "userNameIsRequired".tr();
                      }
                      return null;
                    },
                  ),
                  20.heightBox,

                  Text("password".tr(), style: AppTextStyles.mediumFont()),
                  10.heightBox,
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscureText,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enterPassword".tr();
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "enterPassword".tr(),

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          ref.read(obscureTextProvider.notifier).state =
                              !obscureText;
                        },
                      ),
                    ),
                  ),
                  20.heightBox,

                  Text("company".tr(), style: AppTextStyles.mediumFont()),
                  10.heightBox,
                  ref
                      .watch(companyListProvider(context))
                      .when(
                        data: (companyList) {
                          return DropdownButtonFormField<CompanyModel>(
                            value: ref.watch(userCompanyProvider),
                            items:
                                companyList.map((e) {
                                  return DropdownMenuItem<CompanyModel>(
                                    value: e,
                                    child: Text(e.companyName),
                                  );
                                }).toList(),
                            onChanged: (selectedCompany) {
                              ref.read(userCompanyProvider.notifier).state =
                                  selectedCompany;
                            },
                            decoration: _inputDecoration("selectCompany".tr()),
                          );
                        },
                        error:
                            (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                        loading: () => Loader(),
                      ),
                  SizedBox(height: 8.h),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          () => NavigationService.navigateToScreen(
                            context: context,
                            screen: ForgetPasswordScreen(),
                          ),
                      child: Text(
                        "forgotPassword".tr(),
                        style: AppTextStyles.mediumFont(),
                      ),
                    ),
                  ),
                  15.heightBox,
                  if (isLoading) ...[
                    const Loader(),
                  ] else ...[
                    CustomElevatedButton(
                      onPressed: () {
                        if (ref.read(userCompanyProvider) == null) {
                          showSnackBar(
                            context: context,
                            content: 'Please select company',
                            color: AppTheme.errorColor,
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate() &&
                            ref.watch(userCompanyProvider) != null) {
                          ref
                              .read(authControllerProvider.notifier)
                              .loginUser(
                                userName: userNameController.text,
                                password: passwordController.text,
                                context: context,
                              );
                        } else {
                          showSnackBar(
                            content: "please_enter_valid_data".tr(),
                            context: context,
                            color: AppTheme.errorColor,
                          );
                        }
                      },
                      child: Text(
                        "logIn".tr(),
                        style: AppTextStyles.mediumFont(),
                      ),
                    ),
                    20.heightBox,
                    Center(
                      child: Text("or".tr(), style: AppTextStyles.mediumFont()),
                    ),
                    20.heightBox,
                    _buildSocialLoginButton(
                      icon: Constants.googlePath,
                      label: "google".tr(),
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .loginWithGoogle(context: context);
                        // ref.read(provider)
                      },
                    ),
                    // 10.heightBox,
                    // _buildSocialLoginButton(
                    //   icon: Constants.microsoftPath,
                    //   label: "microsoft".tr(),
                    //   onPressed: () {
                    //     ref
                    //         .read(authControllerProvider.notifier)
                    //         .loginWithMicrosoft(context: context);
                    //   },
                    // ),
                  ],
                  25.heightBox,

                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        NavigationService.navigateRemoveUntil(
                          context: context,
                          screen: ActivationUrlScreen(),
                        );
                        await SecureStorageService.delete(
                          key: StorageKeys.baseUrl,
                        );
                      },
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(
                        "backToActivation".tr(),
                        style: AppTextStyles.mediumFont(),
                      ),
                    ),
                  ),
                  40.heightBox,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(labelText: hint);
  }

  Widget _buildSocialLoginButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        icon: SvgPicture.asset(icon),
        label: Text(label, style: AppTextStyles.mediumFont()),
        onPressed: onPressed,
      ),
    );
  }
}
