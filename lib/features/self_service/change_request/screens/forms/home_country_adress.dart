import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/change_request/providers/change_request_providers.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../models/address_model.dart';
import '../../models/change_request_model.dart';
import '../../providers/form_provider.dart';
import '../widgets/country_list_dropdown.dart';
import '../widgets/input_phone_field.dart';
import '../widgets/utils.dart';

class HomeCountryAddressForm extends ConsumerStatefulWidget {
  final int? reqId;

  final bool? isLineManager;
  final String? employeeCode;

  const HomeCountryAddressForm({
    super.key,
    this.employeeCode,
    this.isLineManager,
    this.reqId,
  });

  @override
  ConsumerState<HomeCountryAddressForm> createState() =>
      _HomeCountryAddressFormState();
}

class _HomeCountryAddressFormState
    extends ConsumerState<HomeCountryAddressForm> {
  final TextEditingController addressLine1Ctrl = TextEditingController();
  final TextEditingController streetNameCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController countryCtrl = TextEditingController();
  final TextEditingController postBoxCtrl = TextEditingController();
  final TextEditingController nexOfKinCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController phoneNumberCtrl = TextEditingController();
  final TextEditingController nexOfKinPhoneNumberCtrl = TextEditingController();

  bool _isInitialized = false;
  String? countryCode, comment;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(changeRequestDetailsListProvider.notifier).state = [],
    );

    void addListener(TextEditingController controller, String fieldName) {
      controller.addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          updateField(ref, fieldName, controller.text);
        });
      });
    }

    // attach listeners once
    addListener(addressLine1Ctrl, "House No.");
    addListener(streetNameCtrl, "Street.");
    addListener(cityCtrl, "Town/City");
    addListener(stateCtrl, "State");
    addListener(countryCtrl, "Country");
    addListener(postBoxCtrl, "Post box");
    addListener(phoneNumberCtrl, "Phone No.");
    addListener(mobileCtrl, "Mobile");
  }

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;
    final details = changeRequest.detail;
    //TODO evan scene ann
    // Helper function to set controller text and update the provider
    void setController(TextEditingController controller, String field) {
      final value = getValueFromDetails(details, field) ?? '';
      controller.text = value;
      updateField(ref, field, value); // ⚡ sync with provider
    }

    // Set all address fields
    setController(addressLine1Ctrl, "House No.");
    setController(streetNameCtrl, "Street.");
    setController(cityCtrl, "Town/City");
    setController(stateCtrl, "State");
    setController(countryCtrl, "Country");
    setController(postBoxCtrl, "Post box");
    setController(phoneNumberCtrl, "Phone No.");
    setController(mobileCtrl, "Mobile");
    setController(nexOfKinCtrl, "Next of kin");
    setController(nexOfKinPhoneNumberCtrl, "Next of kin phone");

    // Update local state
    setState(() => countryCode = getValueFromDetails(details, "Country"));
    updateField(ref, "Country", countryCode ?? '', oldChvalu: countryCode);
    setState(() => comment = changeRequest.comment);
    updateField(ref, "Comment", comment ?? '', oldChtext: comment);
    _isInitialized = true;
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
    final detailsAsync = ref.watch(
      addressContactDetailsProvider(widget.employeeCode),
    );

    return detailsAsync.when(
      loading: () => const Loader(),
      error: (err, _) => ErrorText(error: err.toString()),
      data: (data) {
        // home address
        if (widget.reqId == null) {
          addressLine1Ctrl.text = data.homeAddressLine1 ?? '';
          streetNameCtrl.text = data.homeStreetName ?? '';
          cityCtrl.text = data.homeTownCityName ?? '';
          stateCtrl.text = data.homeStateName ?? '';
          countryCtrl.text = data.homeCountryCode ?? '';
          postBoxCtrl.text = data.homePostBox ?? '';
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            titleHeaderText('Old Value'),
            detailInfoRow(title: 'House No', subTitle: data.homeAddressLine1),
            detailInfoRow(title: 'Street', subTitle: data.homeStreetName),
            detailInfoRow(title: 'Town/City', subTitle: data.homeTownCityName),
            detailInfoRow(title: 'State', subTitle: data.homeStateName),
            Row(
              children: [
                Text("Country".tr(), style: TextStyle(color: Colors.black54)),
                8.widthBox,
                Expanded(
                  child: CustomCountryDropDown(
                    countryCode: data.countryCode ?? 'IND',
                  ),
                ),
              ],
            ),
            detailInfoRow(title: 'Post box', subTitle: data.homePostBox),
            detailInfoRow(title: 'Phone No', subTitle: data.phoneNumber),
            detailInfoRow(title: 'Mobile', subTitle: data.mobileNumber),
            detailInfoRow(title: 'Next Of Kin', subTitle: data.nextOfKinName),
            detailInfoRow(
              title: 'Next Of Kin Phone No',
              subTitle: data.nextOfKinPhone,
            ),
            16.heightBox,
            _formSection(
              title: 'New Value',
              readOnly: widget.isLineManager ?? false,
              countryCode: (countryCode ?? data.countryCode) ?? 'IND',
              data: data,
            ),
            if ((widget.isLineManager ?? false) &&
                (comment?.isNotEmpty ?? false))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  titleHeaderText("Comment"),
                  labelText(comment ?? ''),
                ],
              ),
            80.heightBox,
          ],
        );
      },
    );
  }

  Widget _formSection({
    required String countryCode,
    required String title,
    required bool readOnly,
    required AddressContactModel data,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleHeaderText(title),

          labelText("House No."),
          inputField(
            hint: "House No.",
            controller: addressLine1Ctrl,
            readOnly: readOnly,
            onChanged:
                (val) => updateField(
                  ref,
                  "House No.",
                  val,
                  oldChtext: data.homeAddressLine1,
                ),
          ),

          labelText("Street"),
          inputField(
            hint: "Street",
            controller: streetNameCtrl,
            readOnly: readOnly,
            onChanged:
                (val) => updateField(
                  ref,
                  "Street.",
                  val,
                  oldChtext: data.homeStreetName,
                ),
          ),

          labelText("Town/City"),
          inputField(
            hint: "Town/City",
            controller: cityCtrl,
            readOnly: readOnly,
            onChanged:
                (val) => updateField(
                  ref,
                  "Town/City",
                  val,
                  oldChtext: data.homeTownCityName,
                ),
          ),

          labelText("State"),
          inputField(
            hint: "State",
            controller: stateCtrl,
            readOnly: readOnly,
            onChanged:
                (val) => updateField(
                  ref,
                  "State",
                  val,
                  oldChtext: data.homeStateName,
                ),
          ),

          labelText("Country"),
          CustomCountryDropDown(
            countryCode: countryCode,
            onChanged: (
              countryCode,
              countryName,
              oldCountryName,
              oldCountryCode,
            ) {
              readOnly
                  ? null
                  : updateField(
                    ref,
                    "Country",
                    countryCode ?? "No value",
                    chtext: countryName,
                    oldChtext:
                        oldCountryName, //TODO need the oldCountry name here
                    oldChvalu: oldCountryCode,
                  );
            },
            // onChanged: (val) => updateField(ref, "Country", val ?? ''),
          ), //TODO change this

          labelText("Post box"),
          inputField(
            hint: "Post box",
            controller: postBoxCtrl,
            readOnly: readOnly,
            onChanged:
                (val) => updateField(
                  ref,
                  "Post box",
                  val,
                  oldChtext: data.homePostBox,
                ),
          ),
          labelText("Phone No."),

          inputPhoneField(
            hint: "Phone No.",
            readOnly: readOnly,
            controller: phoneNumberCtrl,
            isRequired: true,
            onChanged: (val) {
              updateField(ref, "Phone No.", val, oldChtext: data.phoneNumber);
            },
          ),
          labelText("Mobile"),
          inputPhoneField(
            hint: "Mobile",
            readOnly: readOnly,
            controller: mobileCtrl,
            isRequired: true,
            onChanged: (val) {
              updateField(ref, "Mobile", val, oldChvalu: data.mobileNumber);
            },
          ),
          labelText("Next Of Kin"),
          inputField(
            hint: "Next Of Kin",
            controller: nexOfKinCtrl,
            readOnly: readOnly,
            onChanged:
                (val) => updateField(
                  ref,
                  "Next of kin",
                  val,
                  oldChtext: data.nextOfKinName,
                ),
          ),
          labelText("Next Of Kin Phone No."),
          inputPhoneField(
            hint: "Next Of Kin Phone No.",
            readOnly: readOnly,
            controller: nexOfKinPhoneNumberCtrl,
            isRequired: true,
            onChanged: (val) {
              updateField(
                ref,
                "Next of kin phone",
                val,
                oldChtext: data.nextOfKinPhone,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    addressLine1Ctrl.dispose();
    streetNameCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    countryCtrl.dispose();
    postBoxCtrl.dispose();
    phoneNumberCtrl.dispose();
    mobileCtrl.dispose();
    super.dispose();
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
  );
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../../../core/common/common_ui_stuffs.dart';
// import '../../../../../core/common/widgets/customDropDown_widget.dart';
//
// class HomeCountryAddressForm extends StatelessWidget {
//   const HomeCountryAddressForm({super.key});
//
//   Widget sectionTitle(String title) => Padding(
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
//         _formSection("Old Value"),
//         SizedBox(height: 16.h),
//         _formSection("New Value"),
//       ],
//     );
//   }
//
//   Widget _formSection(String title) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: _boxDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           sectionTitle(title),
//           labelText("Address Line 1"),
//           inputField(hint: "Enter address line 1"),
//           labelText("Address Line 2"),
//           inputField(hint: "Enter address line 2"),
//           labelText("City"),
//           inputField(hint: "Enter city"),
//           labelText("State"),
//           inputField(hint: "Enter state"),
//           labelText("Country"),
//           CustomDropdown(hintText: "Select country"),
//           labelText("Postal Code"),
//           inputField(hint: "Enter postal code"),
//         ],
//       ),
//     );
//   }
//
//   BoxDecoration _boxDecoration() => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(12.r),
//     boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
//   );
// }
