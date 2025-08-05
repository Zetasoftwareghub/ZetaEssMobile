import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/leave_management/controller/leave_controller.dart';
import 'package:zeta_ess/features/self_service/leave_management/models/leave_model.dart';
import 'package:zeta_ess/features/self_service/leave_management/screens/widgets/oldHRMS_leave_more_details.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/attachment_viewer.dart';
import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/leave_providers.dart';

class LeaveDetailsScreen extends StatefulWidget {
  final bool? isLineManager;
  final String leaveId;
  const LeaveDetailsScreen({
    super.key,
    this.isLineManager,
    required this.leaveId,
  });

  @override
  State<LeaveDetailsScreen> createState() => _LeaveDetailsScreenState();
}

class _LeaveDetailsScreenState extends State<LeaveDetailsScreen> {
  final TextEditingController commentController = TextEditingController();
  LeaveModel? leaveModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Consumer(
              builder: (context, ref, _) {
                return ref
                    .watch(getApproveLeaveDetailsProvider(widget.leaveId))
                    .when(
                      data: (leave) {
                        leaveModel = leave;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleHeaderText('employee_details'),
                            detailInfoRow(
                              title: 'employee_id',
                              subTitle: leave.employeId ?? '-',
                            ),
                            detailInfoRow(
                              title: 'employee_name',
                              subTitle: leave.employeName ?? '-',
                            ),
                            titleHeaderText('submitted_leave_details'),
                            detailInfoRow(
                              title: 'date_from',
                              subTitle: leave.leaveFrom ?? '-',
                            ),
                            detailInfoRow(
                              title: 'date_to',
                              subTitle: leave.leaveTo ?? '-',
                            ),
                            detailInfoRow(
                              title: 'no_of_days',
                              subTitle: '${leave.leaveDays ?? '-'} Days',
                            ),
                            detailInfoRow(
                              title: 'submitted_date',
                              subTitle: leave.submitted ?? '-',
                            ),
                            detailInfoRow(
                              title: 'requested_by',
                              subTitle: leave.employeName ?? '-',
                            ),
                            detailInfoRow(
                              title: 'leave_type',
                              subTitle: leave.leaveType ?? '-',
                            ),

                            titleHeaderText('attachments'),
                            // leave.lRTPAC == null || leave.lRTPAC == ''
                            //     ? Padding(
                            //       padding: EdgeInsets.symmetric(vertical: 4.h),
                            //       child: Text(
                            //         '*${'no_attachments'.tr()}',
                            //         style: TextStyle(
                            //           color: Colors.red,
                            //           fontWeight: FontWeight.w600,
                            //           fontSize: 14.sp,
                            //         ),
                            //       ),
                            //     )
                            //     :
                            AttachmentWidget(
                              attachmentUrl:
                                  leave.lRTPAC == null || leave.lRTPAC == ''
                                      ? null
                                      : '${ref.watch(userContextProvider).userBaseUrl ?? ''}/${leave.lRTPAC ?? ''}',
                            ),

                            titleHeaderText('contact_details'),
                            Text(
                              leave.emergencyContact?.isNotEmpty == true
                                  ? leave.emergencyContact!
                                  : 'N/A',
                              style: TextStyle(fontSize: 15.sp),
                            ),

                            titleHeaderText('reason_for_leave'),
                            Text(
                              leave.note == '' ? 'N/A' : leave.note ?? 'N/A',
                            ),

                            if (!(widget.isLineManager ?? false)) ...[
                              titleHeaderText('comment'),
                              Text(
                                leave.appRejComment?.isNotEmpty == true
                                    ? leave.appRejComment!
                                    : leave.lmComment?.isNotEmpty == true
                                    ? leave.lmComment!
                                    : leave.prevComment?.isNotEmpty == true
                                    ? leave.prevComment!
                                    : leave.cancelComment?.isNotEmpty == true
                                    ? leave.cancelComment!
                                    : 'No comments',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                            if (widget.isLineManager ?? false)
                              inputField(
                                hint: 'Approve/Reject Comment'.tr(),
                                minLines: 3,
                                controller: commentController,
                              ),
                            10.heightBox,

                            //TODO ! THIS IS ONLY FOR LINE MANAGERS YOU IDIOT
                            if (widget.isLineManager ?? false)
                              CustomElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(leaveControllerProvider.notifier)
                                      .cancelLeave(
                                        context: context,
                                        lsslno: leave.leaveId ?? '',
                                        dateFrom: leave.leaveFrom ?? '',
                                      );
                                },
                                child: Text("cancel_request".tr()),
                              ),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  NavigationService.navigateToScreen(
                                    context: context,
                                    screen: LeaveMoreDetailsScreen(
                                      fromAppTab: true,
                                      showSubmit: 'true',
                                      leaveCode:
                                          leave.leaveId
                                              .toString(), //todo leave code ind
                                      lssNo: leave.leaveId.toString(),
                                      dateFrom: leave.leaveFrom,
                                      dateTo: leave.leaveTo,
                                    ),
                                  );
                                },
                                child: Text(
                                  "view_more_details".tr(),
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            100.heightBox,
                          ],
                        );
                      },
                      loading: () => Loader(),
                      error:
                          (error, _) =>
                              Center(child: Text("Error: ${error.toString()}")),
                    );
              },
            ),
          ),
        ),
      ),
      bottomSheet:
          widget.isLineManager ?? false
              ? SafeArea(
                child: Consumer(
                  builder: (context, ref, child) {
                    return ApproveRejectButtons(
                      onApprove: () {
                        if (leaveModel != null) {
                          ref
                              .read(leaveControllerProvider.notifier)
                              .approveLeave(
                                comment: commentController.text,
                                leaveDetails: leaveModel!,
                                context: context,
                              );
                        }
                      },
                      onReject: () {
                        if (leaveModel != null) {
                          ref
                              .read(leaveControllerProvider.notifier)
                              .rejectLeave(
                                comment: commentController.text,
                                leaveDetails: leaveModel!,
                                context: context,
                              );
                        }
                      },
                    );
                  },
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    commentController.dispose();
  }
}
