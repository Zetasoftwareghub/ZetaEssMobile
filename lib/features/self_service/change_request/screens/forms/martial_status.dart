import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../models/change_request_model.dart';
import '../../providers/change_request_providers.dart';
import '../../providers/form_provider.dart';
import '../widgets/utils.dart';

final List<Map<String, String>> maritalStatusOptions = [
  {"text": "Married", "value": "M"},
  {"text": "Single", "value": "S"},
  {"text": "Divorced", "value": "D"},
  {"text": "Widow", "value": "W"},
  {"text": "Widower", "value": "X"},
];

class MaritalStatusForm extends ConsumerStatefulWidget {
  final bool? isLineManager;
  final int? reqId;
  final String? employeeCode;

  const MaritalStatusForm({
    super.key,
    this.employeeCode,
    this.isLineManager,
    this.reqId,
  });

  @override
  ConsumerState<MaritalStatusForm> createState() => _MaritalStatusFormState();
}

class _MaritalStatusFormState extends ConsumerState<MaritalStatusForm> {
  final newMaritalStatusProvider = StateProvider<String?>((ref) => null);
  String? comment;
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(changeRequestDetailsListProvider.notifier).state = [],
    );
  }

  bool _isInitialized = false;

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;

    final value =
        getValueFromDetails(changeRequest.detail, "Marital Status") ?? '';

    updateField(ref, "Marital Status", value, oldChvalu: value);

    ref.read(newMaritalStatusProvider.notifier).state = value;

    _isInitialized = true;

    setState(() => comment = changeRequest.comment ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reqId != null) {
      final changeRequestAsync = ref.watch(
        changeRequestDetailsFetchProvider(widget.reqId!),
      );

      // Initialize from change request when data is available
      changeRequestAsync.whenData((changeRequest) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeFromChangeRequest(changeRequest);
        });
      });
    }
    final maritalStatusAsync = ref.watch(
      maritalStatusProvider(widget.employeeCode),
    );
    final newStatus = ref.watch(newMaritalStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        maritalStatusAsync.when(
          data: (maritalStatus) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleHeaderText('Old Value'),
                SizedBox(height: 6.h),
                labelText("Marital Status"),

                CustomDropdown<String>(
                  value: maritalStatus, // <-- from API
                  hintText: "Select",
                  items:
                      maritalStatusOptions
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e["value"],
                              child: Text(e["text"]!),
                            ),
                          )
                          .toList(),
                ),

                titleHeaderText("New Value"),
                SizedBox(height: 6.h),
                labelText("Marital Status"),
                CustomDropdown<String>(
                  value: newStatus ?? maritalStatus, // <-- from provider
                  hintText: "Select",
                  items:
                      maritalStatusOptions
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e["value"],
                              child: Text(e["text"]!),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (widget.isLineManager ?? false)
                          ? null
                          : (value) {
                            updateField(ref, "Marital Status", value ?? '');
                            ref.read(newMaritalStatusProvider.notifier).state =
                                value;
                          },
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
              ],
            );
          },
          loading: () => const Loader(),
          error: (error, _) => ErrorText(error: error.toString()),
        ),
      ],
    );
  }
}
