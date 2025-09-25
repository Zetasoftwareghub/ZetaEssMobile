import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/validator_services.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/models/salary_certificate_detail_model.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/widgets/comment_section_widget.dart';
import '../controller/salary_certificate_controller.dart';
import '../providers/salary_certificate_notifiers.dart';

class SalaryCertificateDetailsScreen extends ConsumerStatefulWidget {
  final bool isLineManager, isSelf;
  final String? id;

  SalaryCertificateDetailsScreen({
    super.key,
    this.isLineManager = false,
    this.isSelf = false,
    this.id,
  });

  @override
  ConsumerState<SalaryCertificateDetailsScreen> createState() =>
      _SalaryCertificateDetailsScreenState();
}

class _SalaryCertificateDetailsScreenState
    extends ConsumerState<SalaryCertificateDetailsScreen> {
  SalaryCertificateDetailsModel? salaryModel;

  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificateId = int.tryParse(widget.id ?? '');
    if (certificateId == null) {
      return const Scaffold(
        body: Center(child: Text("Invalid Certificate ID")),
      );
    }

    final asyncValue = ref.watch(
      salaryCertificateDetailsProvider(certificateId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body:
          ref.watch(salaryCertificateControllerProvider)
              ? Loader()
              : asyncValue.when(
                loading: () => const Loader(),
                error: (err, _) => ErrorText(error: "Error: ${err.toString()}"),
                data: (details) {
                  salaryModel = details;
                  return SafeArea(
                    child: Padding(
                      padding: AppPadding.screenPadding,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // -- section: Employee Details
                            titleHeaderText("employee_details".tr()),
                            detailInfoRow(
                              title: "employee_id".tr(),
                              subTitle: details.employeeCode ?? "-",
                            ),
                            detailInfoRow(
                              title: "employee_name".tr(),
                              subTitle: details.employeeName ?? "-",
                            ),

                            // -- section: Submitted Details
                            titleHeaderText("submitted_details".tr()),
                            detailInfoRow(
                              title: "requested_date".tr(),
                              subTitle: details.submissionDate ?? "-",
                            ),
                            detailInfoRow(
                              title: "requested_month_and_year_from".tr(),
                              subTitle: details.fromMonth ?? "-",
                            ),
                            detailInfoRow(
                              title: "requested_month_and_year_to".tr(),
                              subTitle: details.toMonth ?? "-",
                            ),
                            detailInfoRow(
                              title: "salary_certificate_purpose".tr(),
                              subTitle: details.purpose ?? "-",
                            ),
                            detailInfoRow(
                              title: "remarks".tr(),
                              subTitle: details.remarks ?? "-",
                            ),
                            detailInfoRow(
                              title: "address_name".tr(),
                              subTitle: details.accountName ?? "-",
                            ),

                            CommentSection(
                              isApproveTab: widget.isLineManager,
                              isLineManagerSelfTab:
                                  !widget.isLineManager || !widget.isSelf,
                              isSelf: widget.isSelf,
                              lmComment: details.lineManagerComment,
                              prevComment: details.previousComment,
                              finalComment: details.approvalOrRejectionComment,
                            ),

                            10.heightBox,
                            if (widget.isLineManager ?? false)
                              inputField(
                                hint: 'Approve/Reject Comment'.tr(),
                                controller: commentController,
                                minLines: 3,
                              ),
                            100.heightBox,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      bottomSheet:
          ref.watch(salaryCertificateControllerProvider)
              ? Loader()
              : widget.isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    if (salaryModel != null) {
                      ref
                          .read(salaryCertificateControllerProvider.notifier)
                          .approveRejectSalary(
                            context: context,
                            certificateId: certificateId.toString(),
                            note: commentController.text.trim(),
                            salaryModel: salaryModel!,
                            approveRejectFlag: 'A',
                          );
                    }
                  },
                  onReject: () {
                    /*  onReject: () {
                        ValidatorServices.validateCommentAndShowAlert(
                          context: context,
                          controller: commentController,
                        );
                    if (isInvalid) return; */

                    ref
                        .read(salaryCertificateControllerProvider.notifier)
                        .approveRejectSalary(
                          context: context,
                          certificateId: certificateId.toString(),
                          note: commentController.text.trim(),
                          salaryModel: salaryModel!,
                          approveRejectFlag: 'R',
                        );
                  },
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
