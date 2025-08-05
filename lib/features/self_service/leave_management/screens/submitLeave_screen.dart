import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/leave_management/controller/old_hrms_configuration_stuffs.dart';
import 'package:zeta_ess/features/self_service/leave_management/screens/widgets/editConfiguration_old_code.dart';
import 'package:zeta_ess/features/self_service/leave_management/screens/widgets/oldHRMS_leaveConfiguratation.dart';

import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/customDatePicker_widget.dart';
import '../../../../core/common/widgets/customDropDown_widget.dart';
import '../../../../core/common/widgets/customFilePicker_widget.dart';
import '../../resumption_request/models/submit_resumption_model.dart';
import '../controller/leave_controller.dart';
import '../models/leaveSubmission_model.dart';
import '../models/leave_model.dart';
import '../providers/leave_providers.dart';

class SubmitLeaveScreen extends ConsumerStatefulWidget {
  final String? leaveId;
  final String? fromDateResumption, toDateResumption;
  final SubmitResumptionModel? submitResumptionModel;
  const SubmitLeaveScreen({
    super.key,
    this.leaveId,
    this.fromDateResumption,
    this.toDateResumption,
    this.submitResumptionModel,
  });

  @override
  ConsumerState<SubmitLeaveScreen> createState() => _SubmitLeaveScreenState();
}

class _SubmitLeaveScreenState extends ConsumerState<SubmitLeaveScreen> {
  final dateFromProvider = StateProvider<String?>((ref) => null);

  final dateToProvider = StateProvider<String?>((ref) => null);
  final selectedLeaveTypeProvider = StateProvider<String?>((ref) => null);
  final TextEditingController contactDetailsController =
      TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  List<LeaveTypeModel>? leaveTypeList;
  LeaveTypeModel? initialLeaveType;

  bool isEditMode = false;
  bool hasPrefilled = false;

  String? editFileUrl;
  //FROM old code
  List<LeaveConfigurationEditData> leaveConfigData = [];
  List<LeaveConfigurationEditData> leaveConfigDataSub = [];
  List<LeaveConfigurationEditData> leaveConfigDataCan = [];

  @override
  void initState() {
    super.initState();
    isEditMode = widget.leaveId != null;

    Future.microtask(() {
      ref.read(dateToProvider.notifier).state = widget.toDateResumption;
      ref.read(dateFromProvider.notifier).state = widget.fromDateResumption;
    });
  }

  @override
  void dispose() {
    contactDetailsController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void prefillIfEdit(LeaveEditResponse model) {
    if (!isEditMode || hasPrefilled) return;

    editFileUrl =
        (model.subLst.first.leaveName?.isNotEmpty ?? false)
            ? '${ref.watch(userContextProvider).userBaseUrl ?? ''}/${model.subLst.first.leaveName ?? ''}'
            : null;

    reasonController.text = model.subLst.first.lsnote ?? '';
    contactDetailsController.text = model.subLst.first.lscont ?? '';
    ref.read(dateFromProvider.notifier).state = model.subLst.first.dLsrdtf;
    ref.read(dateToProvider.notifier).state = model.subLst.first.dLsrdtt;
    ref.read(selectedLeaveTypeProvider.notifier).state =
        model.subLst.first.leaveCode;
    ref.read(totalLeaveDaysStateProvider.notifier).state =
        model.subLst.first.llsrndy ?? '0';
    leaveConfigData = model.appLst;
    leaveConfigDataSub = model.subLst;
    leaveConfigDataCan = model.canLst;

    leaveController.setDataEdit(leaveConfigData);

    try {
      for (var element in leaveConfigDataCan) {
        var item =
            model.appLst
                .where((i) => i.luslno.toString() == element.iLsslno)
                .toList();
        if (item.isNotEmpty) {
          var cnt = 0.00;
          if (item.first.dayFlag == "F") {
            cnt = 1.00;
          } else if (item.first.dayFlag == "H") {
            cnt = 0.50;
          }
          var item1 = element.dLsdate ?? '';
          if (item != '') {
            var arr = item1.split('(');
            var arr1 = arr[1].split(')');
            var val = arr1[0];
            double val1 = double.parse(val);
            String str = (val1 + cnt).toStringAsFixed(2);
            element.dLsdate = "${arr[0]}($str)";
          }
        }
      }
    } catch (e) {
      print(e.toString() + 'werrror in edit leave ');
    }
    hasPrefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(leaveControllerProvider);
    final AsyncValue<LeaveEditResponse?>? details =
        isEditMode
            ? ref.watch(getSelfLeaveDetailsProvider(widget.leaveId ?? '0'))
            : null;

    final data = details?.maybeWhen(data: (d) => d, orElse: () => null);
    if (data != null && !hasPrefilled) {
      Future.microtask(() => prefillIfEdit(data));
    }

    final selectedLeaveType = ref.watch(selectedLeaveTypeProvider);
    final dateFrom = ref.watch(dateFromProvider);
    final dateTo = ref.watch(dateToProvider);
    final submitState = ref.watch(submitLeaveNotifierProvider);
    final isSubmitting = submitState.isLoading;
    return Scaffold(
      appBar: AppBar(title: Text('submit_leave'.tr())),
      body: SingleChildScrollView(
        padding: AppPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelText(
              "${("submitting_date".tr())}: ${formatDate(DateTime.now())}",
            ),
            CustomDateRangePickerField(
              readOnly: widget.submitResumptionModel != null,
              fromDate: dateFrom,
              toDate: dateTo,
              hintText: "select_duration",
              onDateRangeSelected: (dateFrom, dateTo) {
                isEditMode = false;
                leaveController.setData([]);
                leaveController.isSubmitted = false;

                ref.read(dateFromProvider.notifier).state = dateFrom;
                ref.read(dateToProvider.notifier).state = dateTo;
                if (ref.watch(selectedLeaveTypeProvider) != null) {
                  ref
                      .read(leaveControllerProvider.notifier)
                      .getLeaveDays(
                        dateFrom: dateFrom,
                        dateTo: dateTo,
                        leaveCode: selectedLeaveType ?? '',
                      );
                }
              },
            ),
            labelText("leave_type".tr(), isRequired: true),
            Row(
              children: [
                Expanded(
                  child: ref
                      .watch(leaveTypesProvider)
                      .when(
                        data: (leaveTypes) {
                          leaveTypeList = leaveTypes;
                          return CustomDropdown(
                            value: selectedLeaveType,
                            onChanged: (leaveTypeId) {
                              isEditMode = false;

                              leaveController.setData([]);
                              leaveController.isSubmitted = false;
                              ref
                                  .read(selectedLeaveTypeProvider.notifier)
                                  .state = leaveTypeId;

                              if (dateFrom != null &&
                                  dateTo != null &&
                                  leaveTypeId != null) {
                                ref
                                    .read(leaveControllerProvider.notifier)
                                    .getLeaveDays(
                                      dateFrom: dateFrom,
                                      dateTo: dateTo,
                                      leaveCode: leaveTypeId,
                                    );
                              }
                            },
                            items:
                                leaveTypes
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e.leaveTypeId,
                                        child: Text(e.leaveType ?? ''),
                                      ),
                                    )
                                    .toList(),
                            hintText: "leave_type".tr(),
                          );
                        },
                        error:
                            (error, stackTrace) =>
                                Center(child: Text('$error')),
                        loading: () => const Loader(),
                      ),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedLeaveType != null &&
                        dateFrom != null &&
                        dateTo != null) {
                      if (isEditMode) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LeaveConfigurationEdit(
                                  dateFrom: dateFrom,
                                  dateTo: dateTo,
                                  leaveCode: ref.watch(
                                    selectedLeaveTypeProvider,
                                  ),
                                  isLieuDay:
                                      false, //TODO find if its lieu or not
                                  showSubmit: "true",
                                  fromAppTab: false,
                                  selectedLeaveType: leaveTypeList?.firstWhere(
                                    (element) =>
                                        element.leaveTypeId ==
                                        selectedLeaveType,
                                  ),
                                  initialLeaveType: initialLeaveType,
                                  selectedSameValues:
                                      leaveTypeList?.firstWhere(
                                        (element) =>
                                            element.leaveTypeId ==
                                            selectedLeaveType,
                                      ) ==
                                      initialLeaveType,
                                  // selectedLeaveType == initialLeaveType,
                                  data: leaveConfigData,
                                  dataSub: leaveConfigDataSub,
                                  dataCan: leaveConfigDataCan,
                                  lssNo: widget.leaveId ?? '0',
                                  dCanLst: [], //NOt needed
                                ),
                          ),
                        ).then((v) {
                          if (leaveController
                              .leaveConfigurationData
                              .isNotEmpty) {
                            final first =
                                leaveController.leaveConfigurationData.first;
                            final last =
                                leaveController.leaveConfigurationData.last;
                            ref.read(dateFromProvider.notifier).state =
                                (first.dayFlag != ''
                                    ? first.dLsdate
                                    : last.dLsdate) ??
                                '';

                            ref.read(dateToProvider.notifier).state =
                                (last.dayFlag != ''
                                    ? last.dLsdate
                                    : first.dLsdate) ??
                                '';
                          }
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LeaveConfiguration(
                                  dateFrom: dateFrom,
                                  dateTo: dateTo,
                                  leaveCode: ref.watch(
                                    selectedLeaveTypeProvider,
                                  ),
                                ),
                          ),
                        ).then((v) {
                          if (leaveController
                              .leaveConfigurationData
                              .isNotEmpty) {
                            final first =
                                leaveController.leaveConfigurationData.first;
                            final last =
                                leaveController.leaveConfigurationData.last;
                            ref.read(dateFromProvider.notifier).state =
                                (first.dayFlag != ''
                                    ? first.dLsdate
                                    : last.dLsdate) ??
                                '';

                            ref.read(dateToProvider.notifier).state =
                                (last.dayFlag != ''
                                    ? last.dLsdate
                                    : first.dLsdate) ??
                                '';
                          }
                        });
                      }
                    } else {
                      showSnackBar(
                        context: context,
                        color: AppTheme.errorColor,
                        content: 'Select date and leave type first',
                      );
                    }
                  },
                  child: Text("${"configure".tr()} *"),
                ),
              ],
            ),
            Center(
              child: titleHeaderText(
                '${'Total leave days'.tr()}: ${ref.watch(totalLeaveDaysStateProvider)} ',
              ),
            ),
            labelText("reason_for_leave".tr()),
            inputField(hint: "enter".tr(), controller: reasonController),

            labelText("contact_details".tr()),
            inputField(hint: "enter", controller: contactDetailsController),

            16.heightBox,
            FileUploadButton(editFileUrl: editFileUrl),

            50.heightBox,
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: AppPadding.screenBottomSheetPadding,
          child:
              isSubmitting
                  ? Loader()
                  : CustomElevatedButton(
                    onPressed: () async {
                      if (dateFrom == null ||
                          dateTo == null ||
                          selectedLeaveType == null) {
                        showCustomAlertBox(
                          context,
                          title: 'Please select date and leave type',
                          type: AlertType.error,
                        );

                        return;
                      }

                      //TODO this is must done from and to from configure
                      if (!isEditMode) {
                        if (leaveController.leaveConfigurationData.isEmpty ||
                            leaveController.isSubmitted == false ||
                            leaveController.isBlankLieu == true) {
                          showCustomAlertBox(
                            context,
                            title: 'Please configure leave to submit',
                            type: AlertType.error,
                          );
                          return;
                        }
                      }

                      final fileData = ref.read(fileUploadProvider).value;
                      final leaveNotifier = ref.read(
                        submitLeaveNotifierProvider.notifier,
                      );

                      final leaveRequest = LeaveSubmissionRequest(
                        leaveCode: selectedLeaveType ?? '',
                        fromDate: dateFrom ?? '',
                        toDate: dateTo ?? '',
                        dtldata:
                            isEditMode &&
                                    leaveController
                                        .leaveConfigurationData
                                        .isEmpty
                                ? leaveController.leaveConfigurationEditData
                                : leaveController.leaveConfigurationData,
                        dtsub: formatDate(DateTime.now()),
                        note: reasonController.text,
                        contact: contactDetailsController.text,
                        days: ref.watch(totalLeaveDaysStateProvider),
                        file: fileData?.base64,
                        fileExt: fileData?.extension ?? '',
                        allowance: "N",
                        leaveId: widget.leaveId ?? '0',
                        baseDirectory:
                            ref.watch(userContextProvider).userBaseUrl ?? '',
                      );

                      final response = await leaveNotifier.submitLeave(
                        leaveSubmitModel: leaveRequest,
                        context: context,
                        submitResumptionModel: widget.submitResumptionModel,
                      );

                      if (response == null) {
                        showCustomAlertBox(
                          context,
                          title: 'Could not submit leave',
                          type: AlertType.error,
                        );

                        return;
                      }
                    },

                    child: Text(
                      widget.leaveId == null
                          ? '${submitText.tr()} '
                          : updateText.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
        ),
      ),
    );
  }
}
