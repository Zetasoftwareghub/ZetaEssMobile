import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/theme/common_theme.dart';

class SuggestionFeedbackScreen extends StatelessWidget {
  const SuggestionFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Suggestion & Feedback")),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Send suggestions and feedback to HR",
                style: AppTextStyles.largeFont(),
              ),
              labelText("Type"),
              CustomDropdown(hintText: "Select Type"),
              labelText("Message"),
              inputField(hint: "enter".tr(), minLines: 4),
              labelText("Description"),
              inputField(hint: "enter".tr(), minLines: 4),
              15.heightBox,
              FileUploadButton(),
            ],
          ),
        ),
      ),
    );
  }
}
