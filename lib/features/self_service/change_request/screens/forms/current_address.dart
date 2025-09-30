import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../../../../core/common/error_text.dart';
import '../../../../../core/common/loader.dart';
import '../../models/change_request_model.dart';
import '../../providers/change_request_providers.dart';
import '../../providers/form_provider.dart';
import '../widgets/country_list_dropdown.dart';
import '../widgets/input_phone_field.dart';
import '../widgets/utils.dart';

class CurrentAddressForm extends ConsumerStatefulWidget {
  final int? reqId;
  final bool? isLineManager;
  final String? employeeCode;

  const CurrentAddressForm({
    super.key,
    this.employeeCode,
    this.reqId,
    this.isLineManager,
  });

  @override
  ConsumerState<CurrentAddressForm> createState() => _CurrentAddressFormState();
}

class _CurrentAddressFormState extends ConsumerState<CurrentAddressForm> {
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postBoxController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();
  final TextEditingController officialEmailController = TextEditingController();
  String? countryCode, comment;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(changeRequestDetailsListProvider.notifier).state = [],
    );
    void addListener(TextEditingController c, String field) {
      c.addListener(() {
        updateField(ref, field, c.text);
      });
    }

    addListener(addressLine1Controller, "House No.");
    addListener(streetNameController, "Street.");
    addListener(cityController, "Town/City");
    addListener(stateController, "State");
    addListener(countryController, "Country");
    addListener(postBoxController, "Post box");
    addListener(phoneNumberController, "Phone No.");
    addListener(mobileNumberController, "Mobile");
    addListener(personalEmailController, "Personal Email id");
    addListener(officialEmailController, "Official Email id.");
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

    // Set all fields
    setController(addressLine1Controller, "House No.");
    setController(streetNameController, "Street.");
    setController(cityController, "Town/City");
    setController(stateController, "State");
    setController(countryController, "Country");
    setController(postBoxController, "Post box");
    setController(phoneNumberController, "Phone No.");
    setController(mobileNumberController, "Mobile");
    setController(personalEmailController, "Personal Email id");
    setController(officialEmailController, "Official Email id.");

    // After setting countryCode and comment
    setState(() => countryCode = getValueFromDetails(details, "Country"));
    updateField(ref, "Country", countryCode ?? '');

    setState(() => comment = changeRequest.comment);
    updateField(ref, "Comment", comment ?? '');
  }

  //TODO old code but the backend going logic was not implemented !!!!!!!!!!!!!!!!! IT IS IN ABOVE CODE

  // void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
  //   if (_isInitialized) return;
  //   final details = changeRequest.detail;
  //
  //   addressLine1Controller.text =
  //       getValueFromDetails(details, "House No.") ?? '';
  //   streetNameController.text = getValueFromDetails(details, "Street.") ?? '';
  //   cityController.text = getValueFromDetails(details, "Town/City") ?? '';
  //   stateController.text = getValueFromDetails(details, "State") ?? '';
  //   countryController.text = getValueFromDetails(details, "Country") ?? '';
  //   postBoxController.text = getValueFromDetails(details, "Post box") ?? '';
  //   phoneNumberController.text =
  //       getValueFromDetails(details, "Phone No.") ?? '';
  //   mobileNumberController.text = getValueFromDetails(details, "Mobile") ?? '';
  //   officialEmailController.text =
  //       getValueFromDetails(details, "Personal Email id") ?? '';
  //   personalEmailController.text =
  //       getValueFromDetails(details, "Official Email id.") ?? '';
  //   setState(() => countryCode = getValueFromDetails(details, "Country"));
  //   _isInitialized = true;
  //   setState(() => comment = changeRequest.comment);
  // }

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
        // current address
        if (widget.reqId == null) {
          addressLine1Controller.text = data.addressLine1 ?? '';
          streetNameController.text = data.streetName ?? '';
          cityController.text = data.townCityName ?? '';
          stateController.text = data.stateName ?? '';
          countryController.text = data.countryCode ?? '';
          postBoxController.text = data.postBox ?? '';
          phoneNumberController.text = data.phoneNumber ?? '';
          mobileNumberController.text = data.mobileNumber ?? '';
          personalEmailController.text = data.personalMailId ?? '';
          officialEmailController.text = data.emailId ?? '';
          countryCode ??= data.countryCode ?? 'IND';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleHeaderText('Old Value'),
            detailInfoRow(title: "House No.", subTitle: data.addressLine1),

            detailInfoRow(
              title: "Street Name",
              subTitle: data.streetName ?? "No value",
            ),
            detailInfoRow(
              title: "Town/City",
              subTitle: data.townCityName ?? "No value",
            ),
            detailInfoRow(title: "State", subTitle: data.stateName ?? ''),
            // TODO change this (special case with dropdown)
            Row(
              children: [
                Text("Country".tr(), style: TextStyle(color: Colors.black54)),
                8.widthBox,
                Expanded(
                  child: CustomCountryDropDown(data.countryCode ?? 'IND', null),
                ),
              ],
            ),
            detailInfoRow(title: "Post box", subTitle: data.postBox ?? ''),
            detailInfoRow(title: "Phone No.", subTitle: data.phoneNumber ?? ''),
            detailInfoRow(
              title: "Mobile",
              subTitle: data.mobileNumber ?? "No value",
            ),
            detailInfoRow(
              title: "Personal Email id",
              subTitle: data.personalMailId ?? '',
            ),
            detailInfoRow(
              title: "Official Email id",
              subTitle: data.emailId ?? '', //TODO issue in backend
            ),

            SizedBox(height: 16.h),
            _formSection(readOnly: widget.isLineManager ?? false),
            if ((widget.isLineManager ?? false) &&
                (comment?.isNotEmpty ?? false))
              Column(
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

  Widget _formSection({required bool readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHeaderText("New Value"),

        labelText("House No."),
        inputField(
          readOnly: readOnly,
          hint: 'House No.',
          controller: addressLine1Controller,
          onChanged: (val) => updateField(ref, "House No.", val),
        ),
        labelText("Street Name"),
        inputField(
          readOnly: readOnly,
          hint: 'Street',
          controller: streetNameController,
          onChanged: (val) => updateField(ref, "Street.", val),
        ),

        labelText("Town/City"),
        inputField(
          readOnly: readOnly,

          hint: "Town/City",
          controller: cityController,
          onChanged: (val) => updateField(ref, "Town/City", val),
        ),

        labelText("State"),
        inputField(
          readOnly: readOnly,

          hint: "State",
          controller: stateController,
          onChanged: (val) => updateField(ref, "State", val),
        ),

        labelText("Country"),
        CustomCountryDropDown(
          countryCode ?? "IND",
          (val) =>
              readOnly ? null : updateField(ref, "Country", val ?? "No value"),
        ), //TODO change this
        labelText("Post box"),
        inputField(
          readOnly: readOnly,
          hint: "Post box",
          controller: postBoxController,
          onChanged: (val) => updateField(ref, "Post box", val),
        ),
        labelText("Phone No."),
        inputPhoneField(
          hint: "Phone No.",
          readOnly: readOnly,
          controller: phoneNumberController,
          isRequired: true,
          onChanged: (val) {
            updateField(ref, "Phone No.", val);
          },
        ),
        labelText("Mobile"),
        inputPhoneField(
          hint: "Mobile",
          readOnly: readOnly,
          controller: mobileNumberController,
          isRequired: true,
          onChanged: (val) {
            updateField(ref, "Mobile", val);
          },
        ),
        labelText("Personal Email id"),
        inputField(
          readOnly: readOnly,
          hint: "Personal Email id",
          controller: personalEmailController,

          //TODO ESS THIS IS WRANNNG onChanged: (val) => updateField(ref, "Personal Email id", val),
          onChanged: (val) => updateField(ref, "Official Email id.", val),
        ),
        labelText("Official Email id"),
        inputField(
          readOnly: readOnly,
          hint: "Official Email id",
          controller: officialEmailController,
          onChanged: (val) => updateField(ref, "Personal Email id", val),

          //TODO ESS THIS IS WRANNNG onChanged: (val) => updateField(ref, "Official Email id.", val),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
  );
}
