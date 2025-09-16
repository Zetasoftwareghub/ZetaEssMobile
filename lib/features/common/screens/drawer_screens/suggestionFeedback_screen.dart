import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/common/controller/common_controller.dart';
import 'package:zeta_ess/features/common/models/suggestion_model.dart';

import '../../../../core/theme/common_theme.dart';

class SuggestionFeedbackScreen extends ConsumerStatefulWidget {
  const SuggestionFeedbackScreen({super.key});

  @override
  ConsumerState<SuggestionFeedbackScreen> createState() =>
      _SuggestionFeedbackScreenState();
}

class _SuggestionFeedbackScreenState
    extends ConsumerState<SuggestionFeedbackScreen> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? dropDownValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Suggestion & Feedback")),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Send suggestions and feedback to HR",
                style: AppTextStyles.largeFont(),
              ),
              labelText("Type"),
              CustomDropdown(
                hintText: "Select Type",
                items: [
                  DropdownMenuItem(value: "S", child: Text("Suggestion")),
                  DropdownMenuItem(value: "F", child: Text("Feedback")),
                ],
                onChanged: (v) => dropDownValue = v,
              ),
              labelText("Message"),
              inputField(
                hint: "enter".tr(),
                minLines: 4,
                controller: messageController,
              ),
              labelText("Description"),
              inputField(
                hint: "enter".tr(),
                minLines: 4,
                controller: descriptionController,
              ),
              15.heightBox,
              FileUploadButton(),
              100.heightBox,
            ],
          ),
        ),
      ),
      bottomSheet:
          ref.watch(commonControllerProvider)
              ? Loader()
              : Padding(
                padding: AppPadding.screenBottomSheetPadding,
                child: CustomElevatedButton(
                  onPressed: () {
                    if (dropDownValue == null) {
                      showSnackBar(
                        content: "Please select type",
                        context: context,
                        color: AppTheme.errorColor,
                      );
                      return;
                    }
                    if (messageController.text.isEmpty) {
                      showSnackBar(
                        content: "Please give message",
                        context: context,
                        color: AppTheme.errorColor,
                      );
                      return;
                    }
                    final user = ref.read(userContextProvider);
                    final filedData = ref.read(fileUploadProvider).value;
                    final suggestionModel = SuggestionModel(
                      sucode: user.companyCode,
                      suconn: user.companyConnection,
                      id: 0,
                      emcode: user.empCode,
                      dpDate: formatDate(DateTime.now()),
                      subject: messageController.text,
                      description: descriptionController.text,
                      drpType: dropDownValue,
                      baseDirectory: user.userBaseUrl,
                      mediafile: filedData?.base64 ?? '',
                      filename: generateUniqueFileName(filedData?.extension),
                    );
                    ref
                        .read(commonControllerProvider.notifier)
                        .saveSuggestion(
                          suggestionModel: suggestionModel,
                          context: context,
                        );
                  },
                  child: Text('Submit'.tr()),
                ),
              ),
    );
  }

  String generateUniqueFileName(String? extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return "file_${timestamp}_$random.${extension ?? 'txt'}";
  }
}
