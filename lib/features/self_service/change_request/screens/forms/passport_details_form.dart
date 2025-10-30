import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../models/change_request_model.dart';
import '../../providers/change_request_providers.dart';
import '../../providers/form_provider.dart';
import '../widgets/country_list_dropdown.dart';
import '../widgets/utils.dart';

class PassportDetailsForm extends ConsumerStatefulWidget {
  final bool isLineManager;
  final int? reqId;
  final String? employeeCode;

  const PassportDetailsForm({
    super.key,
    this.employeeCode,
    this.isLineManager = false,
    this.reqId,
  });

  @override
  ConsumerState<PassportDetailsForm> createState() =>
      _PassportDetailsFormState();
}

class _PassportDetailsFormState extends ConsumerState<PassportDetailsForm> {
  final TextEditingController passportNumberController =
      TextEditingController();
  final TextEditingController placeOfIssueController = TextEditingController();
  String? issuedCountryCode,
      nationalityCode,
      comment,
      issuedDate,
      expiryDate,
      passportHolder;

  bool _isInitialized = false;

  void addListener(TextEditingController controller, String fieldName) {
    controller.addListener(() {
      updateField(ref, fieldName, controller.text);
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(changeRequestDetailsListProvider.notifier).state = [],
    );

    addListener(passportNumberController, "Number");
    addListener(placeOfIssueController, "Place of Issue");
  }

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;
    final details = changeRequest.detail;

    // Helper to set controller text and update the provider
    void setController(TextEditingController controller, String field) {
      final value = getValueFromDetails(details, field) ?? '';
      controller.text = value;
      updateField(ref, field, value); // ⚡ sync with provider
    }

    // Set Passport fields
    setController(passportNumberController, "Number");
    setController(placeOfIssueController, "Place of Issue");

    // Keep issuedCountryCode and nationalityCode in local state
    setState(() {
      issuedCountryCode = getValueFromDetails(details, "Issued Country");
      nationalityCode = getValueFromDetails(details, "Nationality");
      issuedDate = getValueFromDetails(details, "Issued Date");
      expiryDate = getValueFromDetails(details, "Expiry Date");
      passportHolder = getValueFromDetails(details, "Passport Holder");
    });
    _isInitialized = true;

    // Keep comment in local state for UI
    setState(() => comment = changeRequest.comment);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reqId != null) {
      final changeRequestAsync = ref.watch(
        changeRequestDetailsFetchProvider(widget.reqId!),
      );

      changeRequestAsync.whenData((changeRequest) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeFromChangeRequest(changeRequest);
        });
      });
    }

    final passportAsync = ref.watch(
      passportDetailsNotifierProvider(widget.employeeCode),
    );

    return passportAsync.when(
      data: (passport) {
        print(passport.passportHolder);
        print("passport.passportHolder");
        print(passportHolder);
        return Column(
          children: [
            // Old Value Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Passport Details".tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  titleHeaderText("Old Value"),
                  labelText("Number"),
                  labelText(passport.passportNumber),
                  labelText("Place of Issue"),
                  labelText(passport.placeOfIssue),
                  labelText("Issued Date"),
                  if (passport.issuedDate != null)
                    labelText(
                      formatDate(passport.issuedDate ?? DateTime.now()),
                    ),
                  labelText("Expiry Date"),
                  if (passport.expiryDate != null)
                    labelText(
                      formatDate(passport.expiryDate ?? DateTime.now()),
                    ),
                  labelText("Issued Country"),
                  CustomCountryDropDown(
                    countryCode: passport.issuedCountry,
                  ), //TODO change this
                  labelText("Nationality"),
                  CustomCountryDropDown(countryCode: passport.nationality),
                  // labelText(passport.nationality),
                  labelText("Passport Holder"),
                  CustomDropdown<String>(
                    hintText: "Select",
                    value:
                        passport.passportHolder == '0'
                            ? null
                            : passport.passportHolder.isEmpty
                            ? null
                            : passport.passportHolder,
                    items:
                        [
                              {"value": "R", "text": "Employer"},
                              {"value": "E", "text": "Employee"},
                            ]
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e["value"]!,
                                child: Text(e["text"]!),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),

            // New Value Section
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleHeaderText("New Value"),
                  labelText("Number"),
                  inputField(
                    readOnly: widget.isLineManager,
                    hint: "Enter Passport Number",
                    controller: passportNumberController,
                    onChanged: (v) => updateField(ref, "Number", v),
                  ),
                  labelText("Place of issue"),
                  inputField(
                    readOnly: widget.isLineManager,
                    hint: "Place of Issue",
                    controller: placeOfIssueController,
                    onChanged: (v) => updateField(ref, "Place of Issue", v),
                  ),
                  labelText("Issued Date"),
                  CustomDateField(
                    hintText: 'Issued Date',
                    initialDate:
                        issuedDate ??
                        formatDate(passport.issuedDate ?? DateTime.now()),
                    onDateSelected:
                        widget.isLineManager
                            ? null
                            : (v) => updateField(ref, "Issued Date", v),
                  ),
                  labelText("Expiry Date"),
                  CustomDateField(
                    hintText: 'Expiry Date',
                    initialDate:
                        expiryDate ??
                        formatDate(passport.expiryDate ?? DateTime.now()),
                    onDateSelected:
                        widget.isLineManager
                            ? null
                            : (v) => updateField(ref, "Expiry Date", v),
                  ),
                  //TODO change this !
                  labelText("Issued Country"),
                  CustomCountryDropDown(
                    countryCode: issuedCountryCode ?? passport.issuedCountry,
                    onChanged:
                        widget.isLineManager
                            ? null
                            : (
                              countryCode,
                              countryName,
                              oldCountryName,
                              oldCountryCode,
                            ) {
                              updateField(
                                ref,
                                "Issued Country",
                                countryCode ?? '',
                                chtext: countryName,
                                oldChtext: oldCountryName,
                                oldChvalu: oldCountryCode,
                              );
                            },
                  ),
                  labelText("Nationality"),
                  CustomCountryDropDown(
                    countryCode: nationalityCode ?? passport.nationality,
                    onChanged:
                        widget.isLineManager
                            ? null
                            : (
                              countryCode,
                              countryName,
                              oldCountryName,
                              oldCountryCode,
                            ) {
                              updateField(
                                ref,
                                "Nationality",
                                countryCode ?? '',
                                chtext: countryName,
                                oldChtext: oldCountryName,
                                oldChvalu: oldCountryCode,
                              );
                            },
                  ),

                  labelText("Passport Holder"),
                  CustomDropdown<String>(
                    hintText: "Select",
                    value:
                        passportHolder ??
                        (passport.passportHolder == '0'
                            ? null
                            : passport.passportHolder.isEmpty
                            ? null
                            : passport.passportHolder),
                    items:
                        [
                              {"value": "R", "text": "Employer"},
                              {"value": "E", "text": "Employee"},
                            ]
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e["value"]!,
                                child: Text(e["text"]!),
                              ),
                            )
                            .toList(),
                    onChanged:
                        widget.isLineManager
                            ? null
                            : (value) {
                              updateField(ref, "Passport Holder", value ?? '');

                              // ref.read(passportHolderValueProvider.notifier).state = value;
                            },
                  ),
                  if ((widget.isLineManager) && (comment?.isNotEmpty ?? false))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleHeaderText("Comment"),
                        labelText(comment ?? ''),
                      ],
                    ),
                  100.heightBox,
                ],
              ),
            ),
          ],
        );
      },
      error: (err, _) => ErrorText(error: err.toString()),
      loading: () => const Loader(),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
  );
}
