import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/controller/salary_certificate_controller.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/models/submit_salary_certificate_model.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/providers/salary_certificate_notifiers.dart';

import '../../../../core/common/common_text.dart';
import '../../../../core/common/customDateTime_pickers/month_and_year_picker.dart';
import '../models/salary_certificate_detail_model.dart';

class SubmitSalaryCertificateScreen extends ConsumerStatefulWidget {
  final String? certificateId;
  const SubmitSalaryCertificateScreen({super.key, this.certificateId});

  @override
  ConsumerState<SubmitSalaryCertificateScreen> createState() =>
      _SubmitSalaryCertificateScreenState();
}

class _SubmitSalaryCertificateScreenState
    extends ConsumerState<SubmitSalaryCertificateScreen> {
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController addressNameController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  final TextEditingController dateFromController = TextEditingController();
  final TextEditingController dateToController = TextEditingController();

  bool isEditMode = false;
  bool hasPrefilled = false;
  String? submittedDate;
  @override
  void initState() {
    super.initState();
    isEditMode = widget.certificateId != null;
  }

  void prefillIfEdit(SalaryCertificateDetailsModel model) {
    if (!isEditMode || hasPrefilled) return;

    dateFromController.text = convertMonthYearToMMYYYY(model.fromMonth);
    dateToController.text = convertMonthYearToMMYYYY(model.toMonth);

    purposeController.text = model.purpose ?? '';
    remarkController.text = model.remarks ?? '';
    addressNameController.text = model.accountName ?? '';

    hasPrefilled = true;
    setState(() {
      submittedDate = model.submissionDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue =
        isEditMode
            ? ref.watch(
              salaryCertificateDetailsProvider(
                int.parse(widget.certificateId ?? '0'),
              ),
            )
            : null;

    final details = asyncValue?.maybeWhen(data: (d) => d, orElse: () => null);
    if (details != null && !hasPrefilled) {
      Future.microtask(() => prefillIfEdit(details));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? '${'Edit'.tr()} ${'salary_certificate'.tr()}'
              : '${submitText.tr()} ${'salary_certificate'.tr()}',
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            submittedDate == null
                ? labelText(
                  "${"submitting_date".tr()} ${formatDate(DateTime.now())}",
                )
                : labelText('Submitted Date $submittedDate'.tr()),
            10.heightBox,
            Row(
              children: [
                Expanded(
                  child: MonthYearPickerField(
                    controller: dateFromController,
                    label: '${'date_from'.tr()} *',
                  ),
                ),
                10.widthBox,
                Expanded(
                  child: MonthYearPickerField(
                    controller: dateToController,
                    label: '${'date_to'.tr()} *',
                  ),
                ),
              ],
            ),
            labelText("purpose".tr() + ' *'),
            // isRequired: true),
            inputField(
              hint: "enter".tr(),
              minLines: 3,
              controller: purposeController,
            ),

            labelText("remarks".tr()),
            inputField(
              hint: "enter".tr(),
              minLines: 3,
              controller: remarkController,
            ),

            labelText("address_name".tr()),
            inputField(
              hint: "enter".tr(),
              minLines: 3,
              controller: addressNameController,
            ),

            90.heightBox,
          ],
        ),
      ),

      bottomSheet: SafeArea(
        child: Padding(
          padding: AppPadding.screenBottomSheetPadding,
          child: CustomElevatedButton(
            onPressed: () {
              final user = ref.watch(userContextProvider);
              if (dateToController.text.isEmpty ||
                  purposeController.text.isEmpty) {
                showCustomAlertBox(
                  context,
                  title: "pleaseFillRequiredFields".tr(),
                  type: AlertType.error,
                );

                return;
              }

              final submitModel = SubmitSalaryCertificateModel(
                suconn: user.companyConnection,
                emcode: int.parse(user.empCode),
                username: user.empName,
                iSrid: isEditMode ? int.parse(widget.certificateId ?? '0') : 0,
                frommonth: dateFromController.text,
                tomonth: dateToController.text,
                purpose: purposeController.text,
                reqdate: formatDate(DateTime.now()),
                rmrks: remarkController.text,
                addressname: addressNameController.text,
                url: '',
                cocode: 0,
                baseDirectory:
                    ref.watch(userContextProvider).baseDirectory ?? '',
              );

              ref
                  .read(salaryCertificateControllerProvider.notifier)
                  .submitSalaryCertificate(
                    submitModel: submitModel,
                    context: context,
                  );
            },
            child: Text(
              isEditMode ? 'update'.tr() : submitText.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
