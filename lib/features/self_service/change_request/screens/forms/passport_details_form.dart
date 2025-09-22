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
  String? issuedCountryCode, nationalityCode, comment;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(changeRequestDetailsListProvider.notifier).state = [],
    );
  }

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;
    final details = changeRequest.detail;

    passportNumberController.text =
        getValueFromDetails(details, "Number") ?? '';
    placeOfIssueController.text =
        getValueFromDetails(details, "Place of Issue") ?? '';
    setState(() {
      issuedCountryCode = getValueFromDetails(details, "Issued Country");
      nationalityCode = getValueFromDetails(details, "Nationality");
    });
    _isInitialized = true;
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
                    "Passport Details",
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
                    passport.issuedCountry,
                    (s) {},
                  ), //TODO change this
                  labelText("Nationality"),
                  CustomCountryDropDown(
                    passport.nationality,
                    (s) {},
                  ), //TODO change this
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
                    onChanged: (v) => updateField(ref, " ", v),
                  ),
                  labelText("Issued Date"),
                  CustomDateField(
                    hintText: 'Issued Date',
                    initialDate: formatDate(
                      passport.issuedDate ?? DateTime.now(),
                    ),
                    onDateSelected:
                        widget.isLineManager
                            ? null
                            : (v) => updateField(ref, "Issued Date", v),
                  ),
                  labelText("Expiry Date"),
                  CustomDateField(
                    hintText: 'Expiry Date',
                    initialDate: formatDate(
                      passport.expiryDate ?? DateTime.now(),
                    ),
                    onDateSelected:
                        widget.isLineManager
                            ? null
                            : (v) => updateField(ref, "Expiry Date", v),
                  ),
                  labelText("Issued Country"),
                  CustomCountryDropDown(
                    issuedCountryCode ?? passport.issuedCountry,
                    widget.isLineManager
                        ? null
                        : (s) {
                          updateField(ref, "Issued Country", s ?? '');
                        },
                  ), //TODO change this
                  labelText("Nationality"),
                  CustomCountryDropDown(
                    nationalityCode ?? passport.nationality,
                    widget.isLineManager
                        ? null
                        : (s) {
                          updateField(ref, "Nationality", s ?? '');
                        },
                  ), //TODO change this

                  labelText("Passport Holder"),
                  CustomDropdown<String>(
                    hintText: "Select",
                    // value: selectedValue,
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
                  if ((widget.isLineManager) &&
                      (comment?.isNotEmpty ?? false))
                    Column(
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

// class PassportDetailsForm extends StatelessWidget {
//   const PassportDetailsForm({super.key});
//
//   Widget titleHeaderText(String title) => Padding(
//     padding: EdgeInsets.symmetric(vertical: 8.h),
//     child: Text(
//       title,
//       style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
//     ),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.all(12.w),
//           decoration: _boxDecoration(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Passport Details",
//                 style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 12.h),
//               titleHeaderText("Old Value"),
//               labelText("Number"),
//               inputField(hint: "Enter Passport Number"),
//               labelText("Place of Issue"),
//               inputField(hint: "Enter place of issue"),
//               labelText("Issued Date"),
//               CustomDateField(hintText: 'issue date'),
//               labelText("Expiry Date"),
//               CustomDateField(hintText: 'issue date'),
//
//               labelText("Issued Country"),
//               CustomDateField(hintText: 'issue date'),
//               labelText("Nationality"),
//               CustomDateField(hintText: 'issue date'),
//               labelText("Passport Holder"),
//               CustomDateField(hintText: 'issue date'),
//             ],
//           ),
//         ),
//         SizedBox(height: 16.h),
//         Container(
//           padding: EdgeInsets.all(12.w),
//           decoration: _boxDecoration(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               titleHeaderText("New Value"),
//               labelText("Number"),
//               inputField(hint: "Enter Passport Number"),
//               labelText("Place of Issue"),
//               inputField(hint: "Enter place of issue"),
//               labelText("Issued Date"),
//               CustomDateField(hintText: 'issue date'),
//               labelText("Expiry Date"),
//               CustomDateField(hintText: 'issue date'),
//               labelText("Issued Country"),
//               CustomDropdown(hintText: "Select"),
//               labelText("Nationality"),
//               CustomDropdown(hintText: "Select"),
//               labelText("Passport Holder"),
//               CustomDropdown(hintText: "Select"),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   BoxDecoration _boxDecoration() => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(12.r),
//     boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
//   );
// }
