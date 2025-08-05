import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/controller/common_controller.dart';

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

  // Password validation regex
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
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

  Widget _buildPasswordStrengthIndicator() {
    String password = newController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    String strengthText = '';
    Color strengthColor = Colors.red;

    switch (strength) {
      case 0:
      case 1:
        strengthText = 'Very Weak';
        strengthColor = Colors.red;
        break;
      case 2:
        strengthText = 'Weak';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = 'Fair';
        strengthColor = Colors.yellow;
        break;
      case 4:
        strengthText = 'Good';
        strengthColor = Colors.lightGreen;
        break;
      case 5:
        strengthText = 'Strong';
        strengthColor = Colors.green;
        break;
    }

    return password.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Password Strength: ', style: AppTextStyles.smallFont()),
                Text(
                  strengthText,
                  style: AppTextStyles.smallFont().copyWith(
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            8.heightBox,
            LinearProgressIndicator(
              value: strength / 5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
            16.heightBox,
          ],
        )
        : const SizedBox.shrink();
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: AppTextStyles.smallFont().copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          8.heightBox,
          _buildRequirementItem('At least 8 characters'),
          _buildRequirementItem('One uppercase letter (A-Z)'),
          _buildRequirementItem('One lowercase letter (a-z)'),
          _buildRequirementItem('One number (0-9)'),
          _buildRequirementItem('One special character (!@#\$%^&*)'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.grey),
          8.widthBox,
          Text(requirement, style: AppTextStyles.smallFont(color: Colors.grey)),
        ],
      ),
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
      appBar: AppBar(title: Text('Change Password')),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleHeaderText("Change Password"),
                  8.heightBox,
                  Text(
                    "Ensure your account security by updating your password regularly. Use a strong, unique password that you haven't used before.",
                    style: AppTextStyles.smallFont().copyWith(
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  32.heightBox,

                  _buildPasswordField(
                    label: "Current Password",
                    hint: "Enter your current password",
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
                    label: "New Password",
                    hint: "Enter your new password",
                    controller: newController,
                    obscureText: _obscureNewPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: _validatePassword,
                  ),

                  AnimatedBuilder(
                    animation: newController,
                    builder: (context, child) {
                      return _buildPasswordStrengthIndicator();
                    },
                  ),

                  _buildPasswordField(
                    label: "Confirm New Password",
                    hint: "Confirm your new password",
                    controller: confirmController,
                    obscureText: _obscureConfirmPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: _validateConfirmPassword,
                  ),

                  _buildPasswordRequirements(),

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
                  : const Text('Change Password'),
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
