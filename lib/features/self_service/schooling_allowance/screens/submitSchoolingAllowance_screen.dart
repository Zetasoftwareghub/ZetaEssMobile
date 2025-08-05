import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/customDatePicker_widget.dart';
import '../../../../core/common/widgets/customDropDown_widget.dart';
import '../../../../core/common/widgets/customFilePicker_widget.dart';

class SubmitSchoolingAllowanceScreen extends StatelessWidget {
  const SubmitSchoolingAllowanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${submitText.tr()} ' + "approve_schooling_allowance".tr()),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelText("requested_date".tr(), isRequired: true),
            CustomDateField(hintText: "select_date".tr()),
            labelText("request_type".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['Schooling Allowance']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select_type".tr(),
            ),
            labelText("payment_release_month".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['October', 'November', 'December']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select".tr(),
            ),
            labelText("child_name".tr(), isRequired: true),
            inputField(hint: "enter"),
            labelText("grade".tr(), isRequired: true),
            inputField(hint: "enter"),
            labelText("school_name".tr(), isRequired: true),
            inputField(hint: "enter"),
            labelText("curriculum".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['Sports', 'Science', 'Arts']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select".tr(),
            ),
            labelText("academic_year".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['2016 - 2017', '2017 - 2018', '2018 - 2019']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select".tr(),
            ),
            labelText("academic_term".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['1st Term', '2nd Term', '3rd Term']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select".tr(),
            ),
            labelText("academic_month_from".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['January', 'February', 'March']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select".tr(),
            ),
            labelText("academic_month_to".tr(), isRequired: true),
            CustomDropdown(
              items:
                  ['October', 'November', 'December']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              hintText: "select".tr(),
            ),
            labelText("requested_amount".tr(), isRequired: true),
            inputField(hint: "enter_amount".tr()),
            labelText("note".tr()),
            inputField(hint: "enter_your_note".tr(), minLines: 3),

            16.heightBox,
            const FileUploadButton(),

            labelText("disclaimer".tr(), isRequired: true),
            Text(
              "by_checking_the_below_box".tr(),
              style: TextStyle(fontSize: 12.sp),
            ),

            50.heightBox,
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: AppPadding.screenBottomSheetPadding,
          child: CustomElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '${submitText.tr()} ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
