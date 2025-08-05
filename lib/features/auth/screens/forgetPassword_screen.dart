import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/theme/common_theme.dart';
import '../../../core/utils.dart';
import '../../../models/company_model.dart';
import '../controller/auth_controller.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final TextEditingController userNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: ListView(
            children: [
              30.heightBox,

              Text("forgot_password".tr(), style: AppTextStyles.largeFont()),
              10.heightBox,
              Text("no_worries".tr(), style: AppTextStyles.smallFont()),
              30.heightBox,
              Text("userName".tr(), style: AppTextStyles.mediumFont()),
              10.heightBox,
              TextFormField(
                decoration: _inputDecoration("enterUsername".tr()),
                controller: userNameController,
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
              SizedBox(height: 10.h),
              ref.watch(authControllerProvider)
                  ? Loader()
                  : CustomElevatedButton(
                    onPressed: () {
                      if (userNameController.text.isEmpty) {
                        showSnackBar(
                          context: context,
                          content: 'Please enter user name',
                          color: AppTheme.errorColor,
                        );
                        return;
                      }
                      ref
                          .read(authControllerProvider.notifier)
                          .forgotPassword(
                            context: context,
                            userId: userNameController.text.trim(),
                          );
                    },
                    child: Text("send_reset_link".tr()),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(hintText: hint);
  }
}
