import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/attachment_viewer.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/comment_section_widget.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/services/validator_services.dart';
import '../../../approval_management/approveLieuDay_request/controller/approve_lieu_day_controller.dart';
import '../controller/lieuDay_notifier.dart';

class LieuDayDetailScreen extends ConsumerStatefulWidget {
  final bool isLineManager, isSelf;
  final String lieuDayId;

  const LieuDayDetailScreen({
    super.key,
    required this.lieuDayId,
    this.isLineManager = false,
    this.isSelf = false,
  });

  @override
  ConsumerState<LieuDayDetailScreen> createState() =>
      _LieuDayDetailScreenState();
}

class _LieuDayDetailScreenState extends ConsumerState<LieuDayDetailScreen> {
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lieuDayDetailsFutureProvider(widget.lieuDayId));

    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body:
          ref.watch(approveLieuDayControllerProvider)
              ? Loader()
              : SafeArea(
                child: Padding(
                  padding: AppPadding.screenPadding,
                  child: result.when(
                    loading: () => const Loader(),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (lieuDay) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleHeaderText('lieu_day_details'.tr()),
                            detailInfoRow(
                              title: 'lieu_day_date'.tr(),
                              subTitle: lieuDay.lieuDate,
                            ),
                            detailInfoRow(
                              title: 'leave_type'.tr(),
                              subTitle: lieuDay.type,
                            ),
                            detailInfoRow(
                              title: 'time'.tr(),
                              subTitle:
                                  "${lieuDay.fromTime} - ${lieuDay.toTime}",
                            ),
                            detailInfoRow(
                              title: 'remarks'.tr(),
                              subTitle:
                                  lieuDay.remark.isNotEmpty
                                      ? lieuDay.remark
                                      : '-',
                            ),
                            titleHeaderText('attachments'.tr()),

                            AttachmentWidget(
                              attachmentUrl:
                                  lieuDay.attachmentUrl.isEmpty
                                      ? null
                                      : '${ref.watch(userContextProvider).userBaseUrl ?? ''}/CustomerReports/LieuDayFiles/${lieuDay.attachmentUrl}',

                              height: 200.h,
                            ),

                            // -- Employee Details section
                            titleHeaderText('employee_details'.tr()),
                            detailInfoRow(
                              title: 'employee_id'.tr(),
                              subTitle: lieuDay.employeeId,
                            ),
                            detailInfoRow(
                              title: 'employee_name'.tr(),
                              subTitle: lieuDay.employeeName,
                            ),
                            detailInfoRow(
                              title: 'department'.tr(),
                              subTitle: lieuDay.department,
                            ),
                            detailInfoRow(
                              title: 'designation'.tr(),
                              subTitle: lieuDay.designation,
                            ),
                            detailInfoRow(
                              title: 'category'.tr(),
                              subTitle: lieuDay.category,
                            ),
                            detailInfoRow(
                              title: 'date_of_joining'.tr(),
                              subTitle: lieuDay.dateOfJoining,
                            ),
                            detailInfoRow(
                              title: 'remark'.tr(),
                              subTitle: lieuDay.remark,
                            ),
                            // if (lieuDay.previousComment.isNotEmpty) ...[
                            //   titleHeaderText('Comment'),
                            //   Text(lieuDay.previousComment),
                            // ],
                            CommentSection(
                              isApproveTab: widget.isLineManager,
                              isLineManagerSelfTab:
                                  !widget.isLineManager || !widget.isSelf,
                              isSelf: widget.isSelf,
                              lmComment: lieuDay.lineManagerComment,
                              prevComment: lieuDay.previousComment,
                              finalComment: lieuDay.approvalRejectionComment,
                            ),
                            10.heightBox,
                            if (widget.isLineManager ?? false)
                              inputField(
                                hint: 'Approve/Reject Comment'.tr(),
                                controller: commentController,
                              ),

                            // if (!(widget.isLineManager ?? false)) ...[

                            // ],
                            100.heightBox,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      bottomSheet:
          ref.watch(approveLieuDayControllerProvider)
              ? Loader()
              : (widget.isLineManager ?? false)
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    ref
                        .read(approveLieuDayControllerProvider.notifier)
                        .approveRejectLieu(
                          note: commentController.text,
                          requestId: widget.lieuDayId,
                          approveRejectFlag: 'A',
                          context: context,
                        );
                  },
                  onReject: () {
                    /*  onReject: () {
                        ValidatorServices.validateCommentAndShowAlert(
                          context: context,
                          controller: commentController,
                        );
                    if (isInvalid) return; */
                    ref
                        .read(approveLieuDayControllerProvider.notifier)
                        .approveRejectLieu(
                          note: commentController.text,
                          requestId: widget.lieuDayId,
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
    super.dispose();
    commentController.dispose();
  }
}
