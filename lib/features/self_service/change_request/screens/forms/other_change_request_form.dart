import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../models/change_request_model.dart';
import '../../providers/change_request_providers.dart';
import '../../providers/form_provider.dart';
import '../widgets/utils.dart';

class OtherChangeRequestForm extends ConsumerStatefulWidget {
  final int? reqId;
  final bool isLineManager;
  final String? employeeCode;
  const OtherChangeRequestForm({
    super.key,
    this.reqId,
    this.employeeCode,
    this.isLineManager = false,
  });

  @override
  ConsumerState<OtherChangeRequestForm> createState() =>
      _OtherChangeRequestFormState();
}

class _OtherChangeRequestFormState
    extends ConsumerState<OtherChangeRequestForm> {
  final TextEditingController otherChangeRequestCtrl = TextEditingController();
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

    otherChangeRequestCtrl.text =
        getValueFromDetails(changeRequest.detail, "Other Change Request") ?? '';

    _isInitialized = true;
    setState(() {
      comment = changeRequest.comment ?? '';
    });
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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Other Change Request",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          labelText("Request Details"),
          inputField(
            hint: "Request Details",
            readOnly: widget.isLineManager,
            minLines: 3,
            onChanged: (v) => updateField(ref, "Other Change Request", v),
            controller: otherChangeRequestCtrl,
          ),
          if (widget.isLineManager)
            Column(
              children: [titleHeaderText("Comment"), labelText(comment ?? '')],
            ),
        ],
      ),
    );
  }
}
