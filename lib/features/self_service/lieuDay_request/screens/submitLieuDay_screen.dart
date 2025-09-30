import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/controller/lieuDay_notifier.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/controller/lieuday_controller.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/models/lieuDay_details_model.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../core/common/widgets/customTimePicker.dart';
import '../../../../core/theme/common_theme.dart';
import '../models/lieuDay_type.dart';
import '../models/submit_lieuDay_model.dart';

class SubmitLieuDayScreen extends ConsumerStatefulWidget {
  final String? lieuDayId;
  const SubmitLieuDayScreen({super.key, this.lieuDayId});

  @override
  ConsumerState<SubmitLieuDayScreen> createState() =>
      _SubmitLieuDayScreenState();
}

class _SubmitLieuDayScreenState extends ConsumerState<SubmitLieuDayScreen> {
  final List<LieuDayTypeModel> lieuDayTypes = [
    LieuDayTypeModel(name: "Half Day", value: "0.5"),
    LieuDayTypeModel(name: "Full Day", value: "1"),
    LieuDayTypeModel(name: "Full Day + Half Day", value: "1.5"),
    LieuDayTypeModel(name: "Full Day + Full Day", value: "2"),
  ];

  final _remarkController = TextEditingController();

  final lieuDateProvider = StateProvider<String?>((ref) => null);
  final selectedLieuDayTypeProvider = StateProvider<String?>((ref) => null);
  final selectedFromTimeProvider = StateProvider<String?>((ref) => null);
  final selectedToTimeProvider = StateProvider<String?>((ref) => null);

  bool isEditMode = false;
  bool hasPrefilled = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.lieuDayId != null;
  }

  void prefillIfEdit(LieuDayDetailsModel model) {
    if (!isEditMode || hasPrefilled) return;

    _remarkController.text = model.remark ?? '';
    if (model.lieuDate.isNotEmpty) {
      final parsedDate = DateFormat(
        "dd MMM yyyy",
        "en_US",
      ).parse(model.lieuDate.trim());
      ref.read(lieuDateProvider.notifier).state = DateFormat(
        "dd/MM/yyyy",
      ).format(parsedDate);
    }

    ref.read(selectedFromTimeProvider.notifier).state = model.fromTime ?? '';
    ref.read(selectedToTimeProvider.notifier).state = model.toTime ?? '';
    ref.read(selectedLieuDayTypeProvider.notifier).state =
        lieuDayTypes
            .firstWhere(
              (e) => e.name == model.type,
              orElse: () => LieuDayTypeModel(name: '', value: ''),
            )
            .value;

    hasPrefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(lieuDayControllerProvider);

    final detailsProvider =
        isEditMode
            ? ref.watch(lieuDayDetailsFutureProvider(widget.lieuDayId ?? '0'))
            : const AsyncValue<LieuDayDetailsModel?>.data(null);

    return detailsProvider.when(
      data: (data) {
        if (data != null && !hasPrefilled) {
          Future.microtask(() => prefillIfEdit(data));
        }

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(
              isEditMode
                  ? '${'Edit'.tr()} ${'lieu_day_request'.tr()}'
                  : '${submitText.tr()} ${'lieu_day_request'.tr()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          body: SafeArea(
            child:
                isSubmitting
                    ? const Loader()
                    : Padding(
                      padding: AppPadding.screenPadding,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode) ...[
                              labelText('submitted_date'.tr()),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 14.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  data?.lieuDate ?? formatDate(DateTime.now()),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                              12.heightBox,
                            ],
                            labelText('date'.tr(), isRequired: true),
                            CustomDateField(
                              hintText: 'lieu_day_date'.tr(),
                              onDateSelected:
                                  (date) =>
                                      ref
                                          .read(lieuDateProvider.notifier)
                                          .state = date,
                              initialDate: ref.watch(lieuDateProvider),
                            ),
                            _buildFromToPicker(),
                            12.heightBox,
                            labelText('type'.tr(), isRequired: true),
                            _buildTypeDropdown(),
                            12.heightBox,
                            labelText('remarks'.tr()),
                            _buildRemarksField(),
                            16.heightBox,
                            FileUploadButton(
                              editFileUrl:
                                  (data?.attachmentUrl ?? '').isEmpty
                                      ? null
                                      : '${ref.watch(userContextProvider).userBaseUrl ?? ''}/CustomerReports/LieuDayFiles/${data?.attachmentUrl}',
                            ),
                            80.heightBox,
                          ],
                        ),
                      ),
                    ),
          ),
          bottomSheet: SafeArea(
            child: Padding(
              padding: AppPadding.screenBottomSheetPadding,
              child: CustomElevatedButton(
                onPressed: () => _submitForm(data),
                child: Text(
                  isEditMode ? 'update'.tr() : submitText.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Loader()),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildFromToPicker() {
    return Consumer(
      builder: (context, ref, _) {
        final fromTime = ref.watch(selectedFromTimeProvider);
        final toTime = ref.watch(selectedToTimeProvider);

        return CustomFromToTimePicker(
          fromTime: fromTime,
          toTime: toTime,
          onFromTimeChanged: (newFrom) {
            ref.read(selectedFromTimeProvider.notifier).state = newFrom;
            ref.read(selectedToTimeProvider.notifier).state = null;
          },
          onToTimeChanged: (newTo) {
            ref.read(selectedToTimeProvider.notifier).state = newTo;
          },
        );
      },
    );
  }

  Widget _buildTypeDropdown() {
    return Consumer(
      builder: (context, ref, _) {
        final selectedType = ref.watch(selectedLieuDayTypeProvider);

        return CustomDropdown<String?>(
          value: selectedType,
          hintText: "select_type".tr(),
          onChanged:
              (type) =>
                  ref.read(selectedLieuDayTypeProvider.notifier).state = type,
          items:
              lieuDayTypes
                  .map(
                    (t) =>
                        DropdownMenuItem(value: t.value, child: Text(t.name)),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: _remarkController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'enter'.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Future<void> _submitForm(LieuDayDetailsModel? data) async {
    final user = ref.read(userContextProvider);

    final fromTime = ref.read(selectedFromTimeProvider);
    final toTime = ref.read(selectedToTimeProvider);
    final date = ref.read(lieuDateProvider);
    final lieuDayType = ref.read(selectedLieuDayTypeProvider);

    if (date == null || date.isEmpty) {
      showCustomAlertBox(
        context,
        title: 'Please select date',
        type: AlertType.error,
      );
      return;
    }
    if (fromTime == null || fromTime.isEmpty) {
      showCustomAlertBox(
        context,
        title: 'Please select from time',
        type: AlertType.error,
      );
      return;
    }
    if (toTime == null || toTime.isEmpty) {
      showCustomAlertBox(
        context,
        title: 'Please select to time',
        type: AlertType.error,
      );
      return;
    }
    if (lieuDayType == null || lieuDayType.isEmpty) {
      showCustomAlertBox(
        context,
        title: 'Please select Lieu Day Type',
        type: AlertType.error,
      );
      return;
    }

    final fileData = ref.read(fileUploadProvider).value;
    final request = SubmitLieuDayRequest(
      rqldcode: isEditMode ? widget.lieuDayId ?? '0' : '0',
      suconn: user.companyConnection,
      sucode: user.companyCode,
      emcode: user.empCode,
      micode: '',
      lieuDayDate: date,
      fromTime: fromTime,
      toTime: toTime,
      lieuDayType: lieuDayType,
      remarks: _remarkController.text.trim(),
      mediafile: fileData?.base64 ?? '',
      mediaExtension: fileData?.extension ?? '',
      mediaName: fileData?.extension ?? '',
      baseDirectory: user.userBaseUrl ?? '',
      fileDelete: fileData?.isCleared,
    );

    await ref
        .read(lieuDayControllerProvider.notifier)
        .submitLieuDay(submitModel: request, context: context);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
}
