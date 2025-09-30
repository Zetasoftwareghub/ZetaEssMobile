import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/controller/common_controller.dart';

import '../../../../core/theme/app_theme.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController oldController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }

    if (value != newController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText(label),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        16.heightBox,
      ],
    );
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(commonControllerProvider.notifier)
            .changePassword(
              oldPassword: oldController.text.trim(),
              newPassword: newController.text.trim(),
              context: context,
            );
      } catch (e) {
        // Handle error if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password'.tr())),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleHeaderText("Change Password".tr()),
                  8.heightBox,
                  Text(
                    "Enter your current password and choose a new one.".tr(),
                    style: AppTextStyles.smallFont().copyWith(
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  32.heightBox,

                  _buildPasswordField(
                    label: "Current Password".tr(),
                    hint: "Enter your current password".tr(),
                    controller: oldController,
                    obscureText: _obscureOldPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                    validator: _validateOldPassword,
                  ),

                  _buildPasswordField(
                    label: "New Password".tr(),
                    hint: "Enter your new password".tr(),
                    controller: newController,
                    obscureText: _obscureNewPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: _validateNewPassword,
                  ),

                  _buildPasswordField(
                    label: "Confirm New Password".tr(),
                    hint: "Confirm your new password".tr(),
                    controller: confirmController,
                    obscureText: _obscureConfirmPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: _validateConfirmPassword,
                  ),

                  90.heightBox,
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: AppPadding.screenBottomSheetPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomElevatedButton(
          onPressed: () => _isLoading ? null : _handleChangePassword(),
          child:
              _isLoading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      16.widthBox,
                      const Text('Changing Password...'),
                    ],
                  )
                  : Text('Change Password'.tr()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}

//
// class ChangePasswordScreen extends ConsumerStatefulWidget {
//   const ChangePasswordScreen({super.key});
//
//   @override
//   ConsumerState<ChangePasswordScreen> createState() =>
//       _ChangePasswordScreenState();
// }
//
// class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
//   final TextEditingController oldController = TextEditingController();
//   final TextEditingController newController = TextEditingController();
//   final TextEditingController confirmController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: SafeArea(
//         child: Padding(
//           padding: AppPadding.screenPadding,
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   titleHeaderText("Change Password"),
//                   Text(
//                     "Ensure your account security by updating your password regularly. Use a strong, unique password",
//                     style: AppTextStyles.smallFont(),
//                   ),
//                   25.heightBox,
//                   labelText("Old Password"),
//                   inputField(
//                     hint: "Enter Your Old Password",
//                     controller: oldController,
//                     isRequired: true,
//                   ),
//                   labelText("New Password"),
//                   inputField(
//                     hint: "Enter Your New Password",
//                     controller: newController,
//                     isRequired: true,
//                   ),
//                   labelText("Confirm Password"),
//                   inputField(
//                     hint: "EntEnter Confirm Password",
//                     controller: confirmController,
//
//                     isRequired: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomSheet: Padding(
//         padding: AppPadding.screenBottomSheetPadding,
//         child: CustomElevatedButton(
//           onPressed: () {
//             ref
//                 .read(commonControllerProvider.notifier)
//                 .changePassword(
//                   oldPassword: oldController.text,
//                   newPassword: newController.text,
//                   context: context,
//                 );
//           },
//           child: Text('Change password'),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     newController.dispose();
//     oldController.dispose();
//   }
// }
