import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../theme/common_theme.dart';
import '../widgets/customElevatedButton_widget.dart';

class ApproveRejectButtons extends StatelessWidget {
  final void Function() onApprove, onReject;

  const ApproveRejectButtons({
    super.key,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.screenBottomSheetPadding,
      child: Row(
        children: [
          Flexible(
            child: CustomElevatedButton(
              onPressed: onApprove,
              child: Text("approve".tr()),
            ),
          ),
          12.widthBox,
          Flexible(
            child: CustomElevatedButton(
              onPressed: onReject,
              backgroundColor: Colors.red,
              child: Text("reject".tr()),
            ),
          ),
        ],
      ),
    );
  }
}
