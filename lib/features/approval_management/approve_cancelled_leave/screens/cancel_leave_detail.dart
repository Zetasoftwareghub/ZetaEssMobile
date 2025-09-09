import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../controller/approve_cacncel_leave_controller.dart';
import '../controller/approve_reject.dart';
import '../models/cancel_leave_model.dart';
import '../models/cancel_leave_params.dart';

class CancelLeaveDetailsScreen extends ConsumerStatefulWidget {
  final bool showCommentField;
  final String? lsslno, laslno, clslno;

  const CancelLeaveDetailsScreen({
    super.key,
    this.lsslno,
    this.laslno,
    this.clslno,
    this.showCommentField = false,
  });

  @override
  ConsumerState<CancelLeaveDetailsScreen> createState() =>
      _CancelLeaveDetailsScreenState();
}

class _CancelLeaveDetailsScreenState
    extends ConsumerState<CancelLeaveDetailsScreen> {
  final TextEditingController commentController = TextEditingController();
  CancelLeaveModel? leaveModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: ref
                .watch(
                  cancelLeaveDetailsProvider(
                    CancelLeaveParams(
                      userContext: ref.watch(userContextProvider),
                      lsslno: widget.lsslno,
                      laslno: widget.laslno,
                      clslno: widget.clslno,
                    ),
                  ),
                )
                .when(
                  data: (leave) {
                    leaveModel = leave;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleHeaderText('employee_details'),
                        detailInfoRow(
                          title: 'employee_id',
                          subTitle: leave?.employeeId ?? '-',
                        ),
                        detailInfoRow(
                          title: 'employee_name',
                          subTitle: leave?.employeeName ?? '-',
                        ),
                        titleHeaderText('submitted_leave_details'),
                        detailInfoRow(
                          title: 'date_from',
                          subTitle: leave?.leaveDateFrom ?? '-',
                        ),
                        detailInfoRow(
                          title: 'date_to',
                          subTitle: leave?.leaveDateTo ?? '-',
                        ),
                        detailInfoRow(
                          title: 'no_of_days',
                          subTitle: '${leave?.totalLeaves ?? '-'} Days',
                        ),
                        detailInfoRow(
                          title: 'submitted_date',
                          subTitle: leave?.submittedDate ?? '-',
                        ),
                        detailInfoRow(
                          title: 'Approved Date',
                          subTitle: leave?.approvedDate ?? '-',
                        ),
                        detailInfoRow(
                          title: 'comment',
                          subTitle:
                              (leave?.prevComment.isEmpty ?? true)
                                  ? leave?.lmComment
                                  : leave?.prevComment ?? '-',
                        ),
                        10.heightBox,
                        if (widget.showCommentField)
                          inputField(
                            hint: 'Approve/Reject Comment'.tr(),
                            controller: commentController,
                          ),
                        100.heightBox,
                      ],
                    );
                  },
                  loading: () => Loader(),
                  error:
                      (error, _) =>
                          Center(child: Text("Error: ${error.toString()}")),
                ),
          ),
        ),
      ),
      bottomSheet:
          widget.showCommentField
              ? SafeArea(
                child: Consumer(
                  builder: (context, ref, child) {
                    return ApproveRejectButtons(
                      onApprove: () {
                        print(leaveModel?.employeeCode);
                        print(
                          "leaveModel?.employeeCode check approveee empcode says saru",
                        );
                        if (leaveModel != null) {
                          ref
                              .read(approveRejectCancelLeaveProvider.notifier)
                              .approveOrReject(
                                ApproveRejectCancelLeaveParams(
                                  userContext: ref.watch(userContextProvider),
                                  strapprflg:
                                      "A", // "A" for Approve, "R" for Reject
                                  lsslno: widget.lsslno ?? "",
                                  strEmcode:
                                      ref.watch(userContextProvider).empCode,
                                  username:
                                      ref.watch(userContextProvider).empName,
                                  strNote: commentController.text,
                                  strlaslno: widget.laslno ?? "",
                                  suconn:
                                      ref
                                          .watch(userContextProvider)
                                          .companyConnection ??
                                      '',
                                  emcode: leaveModel?.employeeCode ?? '',
                                  ltcode: leaveModel?.leaveTypeCode,
                                  baseDirectory: "",
                                ),
                                context,
                              );
                        }
                      },
                      onReject: () {
                        if (leaveModel != null) {
                          ref
                              .read(approveRejectCancelLeaveProvider.notifier)
                              .approveOrReject(
                                ApproveRejectCancelLeaveParams(
                                  userContext: ref.watch(userContextProvider),
                                  strapprflg:
                                      "R", // "A" for Approve, "R" for Reject
                                  lsslno: widget.lsslno ?? "",
                                  strEmcode:
                                      ref.watch(userContextProvider).empCode,
                                  username:
                                      ref.watch(userContextProvider).empName,
                                  strNote: commentController.text,
                                  strlaslno: widget.laslno ?? "",
                                  suconn:
                                      ref
                                          .watch(userContextProvider)
                                          .companyConnection ??
                                      '',
                                  emcode: leaveModel?.employeeCode ?? '',
                                  ltcode: leaveModel?.leaveTypeCode, // optional
                                  baseDirectory: "",
                                ),
                                context,
                              );
                        }
                      },
                    );
                  },
                ),
              )
              : SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    commentController.dispose();
  }
}
