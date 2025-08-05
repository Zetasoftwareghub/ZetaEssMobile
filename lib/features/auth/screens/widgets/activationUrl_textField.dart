import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';

final selectedProtocolProvider = StateProvider<String>((ref) {
  return 'https';
});

class ActivationUrlTextField extends ConsumerStatefulWidget {
  final String? labelText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const ActivationUrlTextField({
    super.key,
    this.labelText,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  ConsumerState<ActivationUrlTextField> createState() =>
      _ActivationUrlTextFieldState();
}

class _ActivationUrlTextFieldState
    extends ConsumerState<ActivationUrlTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: widget.labelText ?? "activationURL".tr(),
        contentPadding: EdgeInsets.all(3),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: ref.watch(selectedProtocolProvider),
              isDense: true,
              icon: Icon(Icons.arrow_drop_down, size: 16.sp),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              items: [
                DropdownMenuItem(
                  value: 'https',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 13.sp,
                        color: Colors.green.shade600,
                      ),
                      SizedBox(width: 3.w),
                      Text('HTTPS', style: AppTextStyles.smallFont()),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'http',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_open,
                        size: 13.sp,
                        color: Colors.orange.shade600,
                      ),
                      SizedBox(width: 3.w),
                      Text('HTTP', style: AppTextStyles.smallFont()),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(selectedProtocolProvider.notifier).state = newValue;
                }
              },
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(maxWidth: 100.w),
      ),
    );
  }
}
