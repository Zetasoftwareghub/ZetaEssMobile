import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/theme/common_theme.dart';
import '../controller/resumption_controller.dart';
import '../providers/resumption_provider.dart';

class ResumptionDetailsScreen extends ConsumerStatefulWidget {
  final bool? isLineManager;
  final int resumptionId;
  const ResumptionDetailsScreen({
    super.key,
    this.isLineManager,
    required this.resumptionId,
  });

  @override
  ConsumerState<ResumptionDetailsScreen> createState() =>
      _ResumptionDetailsScreenState();
}

class _ResumptionDetailsScreenState
    extends ConsumerState<ResumptionDetailsScreen> {
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final resumptionAsync = ref.watch(
      resumptionDetailProvider(widget.resumptionId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,

          child: resumptionAsync.when(
            data: (resumption) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleHeaderText('leave_details'.tr()),
                    detailInfoRow(
                      title: 'approved_no_of_days'.tr(),
                      subTitle: resumption.lsrndy,
                    ),
                    detailInfoRow(
                      title: 'leave_type'.tr(),
                      subTitle: resumption.leaveType,
                    ),
                    detailInfoRow(
                      title: 'leave'.tr(),
                      subTitle: resumption.dates,
                    ),

                    // -- section
                    titleHeaderText('resumption_details'.tr()),
                    detailInfoRow(
                      title: 'resumption_date'.tr(),
                      subTitle: resumption.redate,
                    ),
                    detailInfoRow(
                      title: 'Has the return to work meeting taken place',
                      subTitle: resumption.rewkmt,
                    ),

                    detailInfoRow(
                      title: 'note'.tr(),
                      belowValue: resumption.renote,
                    ),

                    // -- section
                    titleHeaderText('attachments'.tr()),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        // resumption.attachmentUrl?.isEmpty ?
                        '* No Attachments',
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
                    ),
                    titleHeaderText('employee_details'.tr()),
                    detailInfoRow(
                      title: 'employee_id'.tr(),
                      subTitle: resumption.eminid,
                    ),
                    detailInfoRow(
                      title: 'employee_name'.tr(),
                      subTitle: resumption.emname,
                    ),
                    detailInfoRow(
                      title: 'line_manager'.tr(),
                      subTitle: resumption.lnname,
                    ),
                    detailInfoRow(
                      title: 'department'.tr(),
                      subTitle: resumption.dpname,
                    ),
                    detailInfoRow(
                      title: 'division'.tr(),
                      subTitle: resumption.diname,
                    ),
                    detailInfoRow(
                      title: 'designation'.tr(),
                      subTitle: resumption.dename,
                    ),
                    detailInfoRow(
                      title: 'category'.tr(),
                      subTitle: resumption.dename,
                    ),
                    detailInfoRow(
                      title: 'date_of_joining'.tr(),
                      subTitle: resumption.emdojn,
                    ),
                    titleHeaderText('comment'.tr()),
                    Text(
                      resumption.appRejComment ?? '',
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    if (widget.isLineManager ?? false)
                      inputField(
                        hint: 'Approve/Reject Comment'.tr(),
                        controller: commentController,
                        minLines: 3,
                      ),
                    70.heightBox,
                  ],
                ),
              );
            },
            error: (error, _) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          ),
        ),
      ),
      bottomSheet:
          widget.isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    ref
                        .read(resumptionControllerProvider.notifier)
                        .approveRejectResumption(
                          note: commentController.text,
                          requestId: widget.resumptionId.toString(),
                          approveRejectFlag: 'A',
                          context: context,
                        );
                  },
                  onReject: () {
                    if (commentController.text.isEmpty) {
                      showCustomAlertBox(
                        context,
                        title: 'Please give reject comment',
                        type: AlertType.error,
                      );
                      return;
                    }
                    ref
                        .read(resumptionControllerProvider.notifier)
                        .approveRejectResumption(
                          note: commentController.text,
                          requestId: widget.resumptionId.toString(),
                          approveRejectFlag: 'R',
                          context: context,
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
