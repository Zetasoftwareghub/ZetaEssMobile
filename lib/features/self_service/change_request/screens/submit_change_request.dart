import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/change_request/models/change_request_model.dart';

import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/change_request_controller.dart';
import '../models/request_types.dart';
import '../providers/change_request_providers.dart';
import '../providers/form_provider.dart';
import 'forms/bank_details.dart';
import 'forms/current_address.dart';
import 'forms/emergency_contact.dart';
import 'forms/home_country_adress.dart';
import 'forms/martial_status.dart';
import 'forms/other_change_request_form.dart';
import 'forms/passport_details_form.dart';

final changeRequestProvider = StateProvider<String?>((ref) => null);

class SubmitChangeRequestScreen extends ConsumerStatefulWidget {
  const SubmitChangeRequestScreen({super.key});

  @override
  ConsumerState<SubmitChangeRequestScreen> createState() =>
      _SubmitChangeRequestScreenState();
}

class _SubmitChangeRequestScreenState
    extends ConsumerState<SubmitChangeRequestScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController dateController = TextEditingController();
  RequestType selectedType = RequestType.none;
  bool isExpanded = false;
  int hoveredIndex = -1;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestTypesAsync = ref.watch(getRequestTypesListProvider);

    return GestureDetector(
      onTap: () {
        if (isExpanded) {
          setState(() => isExpanded = false);
          _controller.reverse();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            "Submit Change Request",
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
        body: requestTypesAsync.when(
          data: (list) {
            final requestTypes = {
              for (final e in list) _mapApiValueToEnum(e.value): e.requestName,
            }..removeWhere((key, value) => key == RequestType.none);

            return SingleChildScrollView(
              padding: AppPadding.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelText("Requested Date".tr(), isRequired: true),
                  labelText(formatDate(DateTime.now())),
                  // const CustomDateField(hintText: "Select Date"),
                  SizedBox(height: 16.h),
                  labelText("Request Type".tr(), isRequired: true),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: _toggleDropdown,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                                  isExpanded
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade300,
                              width: isExpanded ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isExpanded
                                        ? AppTheme.primaryColor
                                        : Colors.black12)
                                    .withOpacity(0.1),
                                blurRadius: isExpanded ? 12 : 4,
                                offset: Offset(0, isExpanded ? 4 : 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedType != RequestType.none
                                      ? requestTypes[selectedType]!.tr()
                                      : "Select Request Type".tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        selectedType != RequestType.none
                                            ? Colors.black87
                                            : Colors.grey.shade600,
                                    fontWeight:
                                        selectedType != RequestType.none
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color:
                                      isExpanded
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Align(
                              heightFactor: _animation.value,
                              child: Container(
                                margin: EdgeInsets.only(top: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children:
                                      requestTypes.entries.map((entry) {
                                        final index = requestTypes.keys
                                            .toList()
                                            .indexOf(entry.key);
                                        final isSelected =
                                            selectedType == entry.key;
                                        final isHovered = hoveredIndex == index;

                                        return MouseRegion(
                                          onEnter:
                                              (_) => setState(
                                                () => hoveredIndex = index,
                                              ),
                                          onExit:
                                              (_) => setState(
                                                () => hoveredIndex = -1,
                                              ),
                                          child: GestureDetector(
                                            onTap: () => _selectType(entry.key),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              margin: EdgeInsets.all(4.w),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 12.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isHovered
                                                        ? AppTheme.primaryColor
                                                            .withOpacity(0.1)
                                                        : isSelected
                                                        ? AppTheme.primaryColor
                                                            .withOpacity(0.05)
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border:
                                                    isSelected
                                                        ? Border.all(
                                                          color: AppTheme
                                                              .primaryColor
                                                              .withOpacity(0.3),
                                                        )
                                                        : null,
                                              ),
                                              child: Row(
                                                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 150,
                                                    ),
                                                    width: 3.w,
                                                    height: 18.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (isHovered ||
                                                                  isSelected)
                                                              ? AppTheme
                                                                  .primaryColor
                                                              : Colors
                                                                  .transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2.r,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.w),
                                                  Expanded(
                                                    child: Text(
                                                      entry.value,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color:
                                                            (isHovered ||
                                                                    isSelected)
                                                                ? AppTheme
                                                                    .primaryColor
                                                                : Colors
                                                                    .black87,
                                                        fontWeight:
                                                            isSelected
                                                                ? FontWeight
                                                                    .w600
                                                                : FontWeight
                                                                    .w400,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Icon(
                                                      Icons.check_circle,
                                                      size: 16.sp,
                                                      color:
                                                          AppTheme.primaryColor,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  if (selectedType != RequestType.none)
                    Container(
                      height: 35.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        requestTypes[selectedType]?.tr() ??
                            "Request Details".tr(),
                        style: AppTextStyles.mediumFont(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Dynamic forms
                  if (selectedType == RequestType.otherChangeRequest)
                    const OtherChangeRequestForm(),
                  if (selectedType == RequestType.passportDetails)
                    const PassportDetailsForm(),
                  if (selectedType == RequestType.emergencyContact)
                    const EmergencyContactForm(),
                  if (selectedType == RequestType.homeCountryAddress)
                    const HomeCountryAddressForm(),
                  if (selectedType == RequestType.currentAddress)
                    const CurrentAddressForm(),
                  if (selectedType == RequestType.bankDetails)
                    const BankDetailsForm(),
                  if (selectedType == RequestType.maritalStatus)
                    MaritalStatusForm(),
                  80.heightBox,
                ],
              ),
            );
          },
          error: (err, _) => ErrorText(error: err.toString()),
          loading: () => Loader(),
        ),

        bottomSheet:
            selectedType != RequestType.none
                ? ref.watch(changeRequestControllerProvider)
                    ? Loader()
                    : Padding(
                      padding: AppPadding.screenBottomSheetPadding,
                      child: CustomElevatedButton(
                        child: Text(submitText.tr()),
                        onPressed: () {
                          final requestType = ref.watch(changeRequestProvider);
                          final requestDetailsList = ref.watch(
                            changeRequestDetailsListProvider,
                          );
                          if (requestType == null) return;
                          final user = ref.watch(userContextProvider);
                          final saveModel = ChangeRequestModel(
                            suconn: user.companyConnection ?? '',
                            sucode: user.companyCode,
                            oldBaName: ref.watch(oldBankNameProvider),
                            oldBaCode: ref.watch(oldBankCodeProvider),
                            oldBcAcNm: oldBankModel?.accountName,
                            oldBcAcNo: oldBankModel?.accountNumber,
                            bankNameDetail: ref.watch(
                              bankNameProvider,
                            ), //NEW BANK NAME !!
                            chrqcd: 0,
                            chrqtp: requestType,
                            emcode: int.parse(user.empCode),
                            chrqdt: convertDateToYYmmDD(DateTime.now()),
                            bacode: ref.watch(bankCodeProvider) ?? 0,
                            bcacno: ref.watch(bankAccNoProvider),
                            bcacnm: ref.watch(bankAccNameProvider),
                            chrqst: requestType,
                            detail: requestDetailsList,
                            chrqtpText: "",
                          );
                          print(saveModel.toJson());
                          print('saveModel.toJson');
                          if (selectedType == RequestType.bankDetails &&
                              (saveModel.bacode == 0 ||
                                  saveModel.bcacno == null ||
                                  saveModel.bcacnm == null)) {
                            showCustomAlertBox(
                              context,
                              title: 'Fill bank details',
                              type: AlertType.error,
                            );
                          } else {
                            if (selectedType != RequestType.bankDetails &&
                                requestDetailsList.isEmpty) {
                              showCustomAlertBox(
                                context,
                                title: 'Fill the request details',
                                type: AlertType.error,
                              );
                              return;
                            }
                            ref
                                .read(changeRequestControllerProvider.notifier)
                                .submitChangeRequest(
                                  context: context,
                                  saveModel: saveModel,
                                );
                          }
                        },
                      ),
                    )
                : null,
      ),
    );
  }

  void _toggleDropdown() {
    setState(() => isExpanded = !isExpanded);
    isExpanded ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    dateController.dispose();
    super.dispose();
  }

  /// Helper: Map API value to RequestType enum
  // keep this pure: only mapping
  RequestType _mapApiValueToEnum(String value) {
    switch (value) {
      case "B":
        return RequestType.bankDetails;
      case "E":
        return RequestType.emergencyContact;
      case "H":
        return RequestType.homeCountryAddress;
      case "C":
        return RequestType.currentAddress;
      case "P":
        return RequestType.passportDetails;
      case "M":
        return RequestType.maritalStatus;
      case "O":
        return RequestType.otherChangeRequest;
      default:
        return RequestType.none;
    }
  }

  // when user selects from dropdown
  void _selectType(RequestType type) {
    setState(() {
      selectedType = type;
      isExpanded = false;
      hoveredIndex = -1;
    });
    _controller.reverse();

    // here push the corresponding case value (B/E/H/...)
    final apiValue = _mapEnumToApiValue(type);
    ref.read(changeRequestProvider.notifier).state = apiValue;
  }

  // helper to reverse-map enums back to their API code
  String _mapEnumToApiValue(RequestType type) {
    switch (type) {
      case RequestType.bankDetails:
        return "B";
      case RequestType.emergencyContact:
        return "E";
      case RequestType.homeCountryAddress:
        return "H";
      case RequestType.currentAddress:
        return "C";
      case RequestType.passportDetails:
        return "P";
      case RequestType.maritalStatus:
        return "M";
      case RequestType.otherChangeRequest:
        return "O";
      case RequestType.none:
        return "";
    }
  }
}
