import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/leave_management/screens/submitLeave_screen.dart';
import 'package:zeta_ess/features/self_service/resumption_request/models/resumption_leave_model.dart';
import 'package:zeta_ess/features/self_service/resumption_request/providers/resumption_provider.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/customDropDown_widget.dart';
import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../controller/resumption_controller.dart';
import '../models/submit_resumption_model.dart';

class SubmitResumptionScreen extends ConsumerStatefulWidget {
  final int? resumptionId;
  const SubmitResumptionScreen({super.key, this.resumptionId});

  @override
  ConsumerState<SubmitResumptionScreen> createState() =>
      _SubmitResumptionScreenState();
}

class _SubmitResumptionScreenState
    extends ConsumerState<SubmitResumptionScreen> {
  final TextEditingController noteController = TextEditingController();
  String? selectedMeetingStatus = 'Yes';

  final selectedResumptionLeaveTypeProvider =
      StateProvider<ResumptionLeaveModel?>((ref) => null);

  final newlySelectedDate = StateProvider<String?>((ref) => null);

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resumptionControllerProvider);

    final selectedLeave = ref.watch(selectedResumptionLeaveTypeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('${submitText.tr()} ${'resumption_request'.tr()}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText('leave'.tr(), isRequired: true),
                ref
                    .watch(resumptionLeavesProvider)
                    .when(
                      data:
                          (leaves) => CustomDropdown<ResumptionLeaveModel>(
                            value:
                                selectedLeave != null
                                    ? leaves.firstWhere(
                                      (e) => e.lsslno == selectedLeave.lsslno,
                                    )
                                    : null,

                            onChanged:
                                (v) =>
                                    ref
                                        .read(
                                          selectedResumptionLeaveTypeProvider
                                              .notifier,
                                        )
                                        .state = v,
                            items:
                                leaves
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.dates ?? 'no type'),
                                      ),
                                    )
                                    .toList(),

                            hintText: "leave_type".tr(),
                          ),
                      error:
                          (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                      loading: () => Loader(),
                    ),

                SizedBox(height: 16.h),
                labelText('approved_no_of_days'.tr()),
                Text(
                  ref.watch(selectedResumptionLeaveTypeProvider)?.noOfDays ??
                      '0',
                ),

                SizedBox(height: 16.h),
                labelText('leave_type'.tr()),
                Text(
                  ref.watch(selectedResumptionLeaveTypeProvider)?.leavetype ??
                      '',
                ),
                SizedBox(height: 16.h),
                // labelText('resumption_date'.tr()),
                CustomDateField(
                  hintText: 'resumption_date'.tr(),
                  notBeforeInitialDate: true,
                  initialDate:
                      ref
                          .watch(selectedResumptionLeaveTypeProvider)
                          ?.dtNxtWrkDay,

                  onDateSelected: (dateString) {
                    if (dateString !=
                        ref
                            .watch(selectedResumptionLeaveTypeProvider)
                            ?.dtNxtWrkDay) {
                      final modifiedDate = DateFormat(
                        'dd/MM/yyyy',
                      ).parse(dateString).subtract(const Duration(days: 1));

                      final formattedDate = DateFormat(
                        'dd/MM/yyyy',
                      ).format(modifiedDate);

                      ref.read(newlySelectedDate.notifier).state =
                          formattedDate;
                    }
                  },
                ),
                SizedBox(height: 16.h),
                labelText('note'.tr()),
                inputField(
                  hint: 'enter_your_note'.tr(),
                  controller: noteController,
                  minLines: 3,
                ),
                SizedBox(height: 16.h),
                FileUploadButton(),
                SizedBox(height: 24.h),
                Text(
                  'Has return to work meeting taken place?',
                  style: TextStyle(fontSize: 14.sp),
                ),

                8.heightBox,
                Row(
                  children: [
                    _buildRadio('yes'.tr()),
                    SizedBox(width: 20.w),
                    _buildRadio('no'.tr()),
                  ],
                ),
                70.heightBox,
              ],
            ),
          ),
        ),
      ),
      bottomSheet:
          isLoading
              ? Loader()
              : SafeArea(
                child: Padding(
                  padding: AppPadding.screenBottomSheetPadding,
                  child: CustomElevatedButton(
                    onPressed: () {
                      final user = ref.watch(userContextProvider);
                      if (selectedLeave == null) {
                        showCustomAlertBox(
                          context,
                          title: requiredFieldsText.tr(),
                          type: AlertType.error,
                        );
                        return;
                      }

                      final filedData = ref.watch(fileUploadProvider).value;

                      final submitResumptionModel = SubmitResumptionModel(
                        reslno: 0,
                        suconn: user.companyConnection ?? '',
                        emcode: user.empCode,
                        micode: '0',
                        selectedValue: selectedLeave.lsslno ?? '',
                        selectedText: selectedLeave.dates ?? '',
                        resDate:
                            selectedLeave.dtNxtWrkDay?.replaceAll('/', '-') ??
                            '',
                        note: noteController.text,
                        mediafile: filedData?.base64 ?? '',
                        mediaExtension: filedData?.extension ?? '',
                        selectedMeetingValue:
                            selectedMeetingStatus == 'Yes' ? 'Y' : 'N',
                        laslno: selectedLeave.laslno ?? '',
                        lvtype: selectedLeave.lvtype ?? '',
                        baseDirectory:
                            ref.watch(userContextProvider).baseDirectory ?? '',
                      );
                      if (ref.watch(newlySelectedDate) != null) {
                        if (ref.watch(newlySelectedDate) !=
                            ref
                                .watch(selectedResumptionLeaveTypeProvider)
                                ?.dtNxtWrkDay) {
                          NavigationService.navigateToScreen(
                            context: context,
                            screen: SubmitLeaveScreen(
                              submitResumptionModel: submitResumptionModel,
                              fromDateResumption:
                                  ref
                                      .watch(
                                        selectedResumptionLeaveTypeProvider,
                                      )
                                      ?.dtNxtWrkDay,
                              toDateResumption: ref.watch(newlySelectedDate),
                            ),
                          );
                        }
                      }
                      //todo need to submit leave if newlySelectedDate != resu date  do it correctlyyyy !
                      else {
                        ref
                            .read(resumptionControllerProvider.notifier)
                            .submitResumptionLeave(
                              submitResumptionModel: submitResumptionModel,
                              context: context,
                              isEditMode: false,
                            );
                      }
                    },
                    child: Text(
                      '${submitText.tr()} ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedMeetingStatus,
          onChanged: (val) {
            setState(() {
              selectedMeetingStatus = val;
            });
          },
        ),
        Text(value),
      ],
    );
  }
}

/*
TODO i have seen no edit in resumption request screen OLD APP
class SubmitResumptionScreen extends ConsumerStatefulWidget {
  final int? resumptionId;
  const SubmitResumptionScreen({super.key, this.resumptionId});

  @override
  ConsumerState<SubmitResumptionScreen> createState() =>
      _SubmitResumptionScreenState();
}

class _SubmitResumptionScreenState
    extends ConsumerState<SubmitResumptionScreen> {
  final TextEditingController noteController = TextEditingController();
  String? selectedMeetingStatus = 'Yes';

  final selectedResumptionLeaveTypeProvider =
      StateProvider<ResumptionLeaveModel?>((ref) => null);

  bool isEditMode = false;
  bool hasPrefilled = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.resumptionId != null;
  }

  void prefillIfEdit(ResumptionDetailModel model) {
    if (hasPrefilled || !isEditMode) return;
print(model.rewkmt)
    noteController.text = model.renote ?? '';
    selectedMeetingStatus = model.rewkmt;
    print(model.laslno);
    print('model.laslno');
    // Set leave object into provider
    final refLeave = ResumptionLeaveModel(
      lsslno: model.laslno,
      laslno: model.laslno,
      lvtype: model.leaveType,
      dates: model.dates,
      dtNxtWrkDay: model.redate,
      noOfDays: model.lsrndy,
      leavetype: model.leaveType,
    );

    ref.read(selectedResumptionLeaveTypeProvider.notifier).state = refLeave;

    hasPrefilled = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resumptionControllerProvider);
    final selectedLeave = ref.watch(selectedResumptionLeaveTypeProvider);

    final resumptionDetails =
        isEditMode
            ? ref.watch(resumptionDetailProvider(widget.resumptionId!))
            : null;

    final detail = resumptionDetails?.maybeWhen(
      data: (d) => d,
      orElse: () => null,
    );

    if (detail != null && !hasPrefilled) {
      Future.microtask(() => prefillIfEdit(detail));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? '${'edit'.tr()} ${'resumption_request'.tr()}'
              : '${submitText.tr()} ${'resumption_request'.tr()}',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText('leave'.tr(), isRequired: true),
                ref
                    .watch(resumptionLeavesProvider)
                    .when(
                      data: (leaves) {
                        print(leaves.first.laslno);
                        print('leaves.first.laslno');
                        return CustomDropdown<ResumptionLeaveModel>(
                          value:
                              selectedLeave != null
                                  ? leaves.firstWhere((e) {
                                    return e.laslno == selectedLeave.laslno;
                                  })
                                  : null,
                          onChanged:
                              (v) =>
                                  ref
                                      .read(
                                        selectedResumptionLeaveTypeProvider
                                            .notifier,
                                      )
                                      .state = v,
                          items:
                              leaves
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.dates ?? 'no type'),
                                    ),
                                  )
                                  .toList(),
                          hintText: "leave_type".tr(),
                        );
                      },
                      error: (error, _) => ErrorText(error: error.toString()),
                      loading: () => Loader(),
                    ),
                16.heightBox,
                labelText('approved_no_of_days'.tr()),
                Text(selectedLeave?.noOfDays ?? '0'),
                16.heightBox,
                labelText('leave_type'.tr()),
                Text(selectedLeave?.leavetype ?? ''),
                16.heightBox,
                labelText('resumption_date'.tr()),
                Text(selectedLeave?.dtNxtWrkDay ?? ''),
                16.heightBox,
                labelText('note'.tr()),
                inputField(
                  hint: 'enter_your_note'.tr(),
                  controller: noteController,
                  minLines: 3,
                ),
                16.heightBox,
                FileUploadButton(),
                24.heightBox,
                Text(
                  'Has the return to work meeting taken place?',
                  style: TextStyle(fontSize: 14.sp),
                ),
                8.heightBox,
                Row(
                  children: [
                    _buildRadio('yes'.tr()),
                    20.widthBox,
                    _buildRadio('no'.tr()),
                  ],
                ),
                70.heightBox,
              ],
            ),
          ),
        ),
      ),
      bottomSheet:
          isLoading
              ? Loader()
              : Padding(
                padding: AppPadding.screenBottomSheetPadding,
                child: CustomElevatedButton(
                  onPressed: () {
                    final user = ref.watch(userContextProvider);

                    if (selectedLeave == null) {
                      showSnackBar(
                        context: context,
                        content: 'pleaseFillRequiredFields'.tr(),
                        color: AppTheme.errorColor,
                      );
                      return;
                    }

                    final submitModel = SubmitResumptionModel(
                      reslno: isEditMode ? widget.resumptionId ?? 0 : 0,
                      suconn: user.companyConnection ?? '',
                      emcode: user.empCode,
                      micode: '0',
                      selectedValue: selectedLeave.lsslno ?? '',
                      selectedText: selectedLeave.dates ?? '',
                      resDate:
                          selectedLeave.dtNxtWrkDay?.replaceAll('/', '-') ?? '',
                      note: noteController.text,
                      mediafile: '',
                      mediaExtension: '',
                      selectedMeetingValue:
                          selectedMeetingStatus == 'Yes' ? 'Y' : 'N',
                      laslno: selectedLeave.laslno ?? '',
                      lvtype: selectedLeave.lvtype ?? '',
                      baseDirectory: '',
                    );

                    ref
                        .read(resumptionControllerProvider.notifier)
                        .submitResumptionLeave(
                          resumptionModel: submitModel,
                          context: context,
                          isEditMode: isEditMode,
                        );
                  },
                  child: Text(
                    isEditMode ? 'update'.tr() : submitText.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
    );
  }

  Widget _buildRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedMeetingStatus,
          onChanged: (val) {
            setState(() {
              selectedMeetingStatus = val;
            });
          },
        ),
        Text(value),
      ],
    );
  }
}
*/
