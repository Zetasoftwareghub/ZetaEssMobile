import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/change_request/providers/change_request_providers.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../models/change_request_model.dart';
import '../../providers/form_provider.dart';
import '../widgets/input_phone_field.dart';
import '../widgets/utils.dart';

class EmergencyContactForm extends ConsumerStatefulWidget {
  final int? reqId;
  final bool? isLineManager;
  final String? employeeCode;

  const EmergencyContactForm({
    super.key,
    this.employeeCode,
    this.reqId,
    this.isLineManager,
  });

  @override
  ConsumerState<EmergencyContactForm> createState() =>
      _EmergencyContactFormState();
}

class _EmergencyContactFormState extends ConsumerState<EmergencyContactForm> {
  // Controllers for new values
  final TextEditingController nameCtrl1 = TextEditingController();
  final TextEditingController relationCtrl1 = TextEditingController();
  final TextEditingController phoneCtrl1 = TextEditingController();
  final TextEditingController emailCtrl1 = TextEditingController();

  final TextEditingController nameCtrl2 = TextEditingController();
  final TextEditingController relationCtrl2 = TextEditingController();
  final TextEditingController phoneCtrl2 = TextEditingController();
  final TextEditingController emailCtrl2 = TextEditingController();

  final TextEditingController nameCtrl3 = TextEditingController();
  final TextEditingController relationCtrl3 = TextEditingController();
  final TextEditingController phoneCtrl3 = TextEditingController();
  final TextEditingController emailCtrl3 = TextEditingController();
  bool _isInitialized = false;
  String? comment;

  void addListener(TextEditingController controller, String fieldName) {
    controller.addListener(() {
      updateField(ref, fieldName, controller.text);
    });
  }

  @override
  void initState() {
    super.initState();

    // reset provider state
    Future.microtask(
      () => ref.read(changeRequestDetailsListProvider.notifier).state = [],
    );

    addListener(nameCtrl1, "Contact 1");
    addListener(relationCtrl1, "Relation 1");
    addListener(phoneCtrl1, "Phone No. 1");
    addListener(emailCtrl1, "Email Id 1");

    addListener(nameCtrl2, "Contact 2");
    addListener(relationCtrl2, "Relation 2");
    addListener(phoneCtrl2, "Phone No. 2");
    addListener(emailCtrl2, "Email Id 2");

    addListener(nameCtrl3, "Contact 3");
    addListener(relationCtrl3, "Relation 3");
    addListener(phoneCtrl3, "Phone No 3");
    addListener(emailCtrl3, "Email Id 3");
  }

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;
    final details = changeRequest.detail;

    // Helper function to set controller text and update the provider
    void setController(TextEditingController controller, String field) {
      final value = getValueFromDetails(details, field) ?? '';
      controller.text = value;
      updateField(ref, field, value); // ⚡ sync with provider
    }

    // Contact 1
    setController(nameCtrl1, "Contact 1");
    setController(relationCtrl1, "Relation 1");
    setController(phoneCtrl1, "Phone No. 1");
    setController(emailCtrl1, "Email Id 1");

    // Contact 2
    setController(nameCtrl2, "Contact 2");
    setController(relationCtrl2, "Relation 2");
    setController(phoneCtrl2, "Phone No. 2");
    setController(emailCtrl2, "Email Id 2");

    // Contact 3
    setController(nameCtrl3, "Contact 3");
    setController(relationCtrl3, "Relation 3");
    setController(phoneCtrl3, "Phone No 3");
    setController(emailCtrl3, "Email Id 3");

    _isInitialized = true;
    setState(() => comment = changeRequest.comment);
  }

  /*

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;
    final details = changeRequest.detail;
    nameCtrl1.text = getValueFromDetails(details, "Contact 1") ?? '';
    relationCtrl1.text = getValueFromDetails(details, "Relation 1") ?? '';
    phoneCtrl1.text = getValueFromDetails(details, "Phone No. 1") ?? '';
    emailCtrl1.text = getValueFromDetails(details, "Email Id 1") ?? '';

    nameCtrl2.text = getValueFromDetails(details, "Contact 2") ?? '';
    relationCtrl2.text = getValueFromDetails(details, "Relation 2") ?? '';
    phoneCtrl2.text = getValueFromDetails(details, "Phone No. 2") ?? '';
    emailCtrl2.text = getValueFromDetails(details, "Email Id 2") ?? '';

    nameCtrl3.text = getValueFromDetails(details, "Contact 3") ?? '';
    relationCtrl3.text = getValueFromDetails(details, "Relation 3") ?? '';
    phoneCtrl3.text = getValueFromDetails(details, "Phone No 3") ?? '';
    emailCtrl3.text = getValueFromDetails(details, "Email Id 3") ?? '';
    _isInitialized = true;
    setState(() => comment = changeRequest.comment);
  }
*/

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
        if (widget.reqId == null) {
          nameCtrl1.text = data.emergencyPerson ?? '';
          relationCtrl1.text = data.emergencyRelation ?? '';
          phoneCtrl1.text = data.emergencyPhone ?? '';

          nameCtrl2.text = data.emergencyPerson1 ?? '';
          relationCtrl2.text = data.emergencyRelation1 ?? '';
          phoneCtrl2.text = data.emergencyPhone1 ?? '';

          nameCtrl3.text = data.emergencyPerson2 ?? '';
          relationCtrl3.text = data.emergencyRelation2 ?? '';
          phoneCtrl3.text = data.emergencyPhone2 ?? '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleHeaderText('Old Value'),
            for (int i = 0; i < data.persons.length; i++) ...[
              detailInfoRow(
                title: "Contact ${i + 1}",
                subTitle: data.persons[i],
              ),
              detailInfoRow(
                title: "Relation ${i + 1}",
                subTitle: data.relations[i],
              ),
              detailInfoRow(
                title: "Phone No ${i + 1}",
                subTitle: data.phones[i],
              ),
              detailInfoRow(title: "Email ${i + 1}", subTitle: data.emails[i]),
              SizedBox(height: 12),
            ],

            SizedBox(height: 16.h),
            _formSection(readOnly: widget.isLineManager ?? false),
            if ((widget.isLineManager ?? false) &&
                (comment?.isNotEmpty ?? false))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  titleHeaderText("comment"),
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

        // Emergency 1
        _singleEmergencyCard(
          index: 1,
          nameController: nameCtrl1,
          relationController: relationCtrl1,
          phoneController: phoneCtrl1,
          emailController: emailCtrl1,
          readOnly: readOnly,
        ),
        SizedBox(height: 12.h),

        // Emergency 2
        _singleEmergencyCard(
          index: 2,
          nameController: nameCtrl2,
          relationController: relationCtrl2,
          phoneController: phoneCtrl2,
          emailController: emailCtrl2,

          readOnly: readOnly,
        ),
        SizedBox(height: 12.h),

        // Emergency 3
        _singleEmergencyCard(
          index: 3,
          nameController: nameCtrl3,
          relationController: relationCtrl3,
          phoneController: phoneCtrl3,
          emailController: emailCtrl3,

          readOnly: readOnly,
        ),
      ],
    );
  }

  Widget _singleEmergencyCard({
    required int index,
    required TextEditingController nameController,
    required TextEditingController relationController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
    required bool readOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText('Contact $index'),
        inputField(
          hint: 'Contact $index',
          controller: nameController,
          readOnly: readOnly,
          onChanged: (val) => updateField(ref, "Contact $index", val),
        ),
        labelText('Relation $index'),
        inputField(
          hint: 'Relation $index',
          controller: relationController,
          readOnly: readOnly,
          onChanged: (val) => updateField(ref, "Relation $index", val),
        ),
        labelText('Phone No. $index'),
        inputPhoneField(
          hint: "Phone No. $index",
          readOnly: readOnly,
          controller: phoneController,
          isRequired: true,
          onChanged: (val) {
            updateField(
              ref,
              index == 3 ? "Phone No $index" : "Phone No. $index",
              val,
            );
          },
        ),
        labelText('Email Id $index'),
        inputField(
          hint: 'Email Id  $index',
          controller: emailController,
          readOnly: readOnly,
          onChanged: (val) => updateField(ref, "Email Id $index", val),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameCtrl1.dispose();
    relationCtrl1.dispose();
    phoneCtrl1.dispose();

    nameCtrl2.dispose();
    relationCtrl2.dispose();
    phoneCtrl2.dispose();

    nameCtrl3.dispose();
    relationCtrl3.dispose();
    phoneCtrl3.dispose();
    super.dispose();
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
  );
}
