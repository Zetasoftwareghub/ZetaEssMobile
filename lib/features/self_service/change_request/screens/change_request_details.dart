import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/change_request/models/change_request_model.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../approval_management/approve_change_request/controller/approve_change_request_controoler.dart';
import '../../../approval_management/approve_change_request/models/approve_change_req.dart';
import '../providers/change_request_providers.dart';
import 'forms/martial_status.dart';

class ChangeRequestDetailsScreen extends ConsumerWidget {
  final int reqId;
  final String title;
  final bool? isLineManager;
  const ChangeRequestDetailsScreen({
    super.key,
    required this.title,
    required this.reqId,
    this.isLineManager = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(changeRequestDetailsFetchProvider(reqId));
    ChangeRequestModel? changeRequestModel;
    return Scaffold(
      appBar: AppBar(title: Text(title, style: TextStyle(fontSize: 16.sp))),
      body: asyncData.when(
        data: (changeRequest) {
          changeRequestModel = changeRequest;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText('Request Date'),
                labelText(changeRequest.chrqdt ?? ""),

                12.heightBox,
                // Details Section
                if (changeRequest.chrqtp == "B")
                  _buildBankDetails(changeRequest)
                else if (changeRequest.chrqtp == "M")
                  Row(
                    children: [
                      labelText(changeRequest.detail.first.chtype ?? ""),
                      10.widthBox,
                      Expanded(
                        child: CustomDropdown(
                          items:
                              maritalStatusOptions
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e["value"],
                                      child: Text(e["text"]!),
                                    ),
                                  )
                                  .toList(),
                          hintText: 'Marital Status'.tr(),
                          value: changeRequest.detail.first.chvalu,
                        ),
                      ),
                    ],
                  )
                else
                  _buildDynamicDetails(changeRequest.detail),
                12.heightBox,
                if (changeRequest.comment?.isNotEmpty ?? false)
                  titleHeaderText('comment'.tr()),
                labelText(changeRequest.comment ?? ""),
                80.heightBox,
              ],
            ),
          );
        },
        loading: () => Loader(),
        error: (err, stack) => ErrorText(error: err.toString()),
      ),
      bottomSheet:
          isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    final userContext = ref.watch(userContextProvider);
                    final approveChangeRequestModel = ApproveChangeRequestModel(
                      suconn: userContext.companyConnection,
                      sucode: userContext.companyCode,
                      chRqCd: changeRequestModel?.chrqcd ?? 0,
                      chApBy: changeRequestModel?.chapby,
                      bcSlNo: '0',
                      chapnt: changeRequestModel?.comment,
                      emCode: userContext.empCode,
                      chtype: changeRequestModel?.chrqst, //TODO check with api
                      aprFlag: 'A',
                    );
                    ref
                        .read(approveChangeRequestControllerProvider.notifier)
                        .approveRejectChangeRequest(
                          approveChangeRequestModel: approveChangeRequestModel,
                          context: context,
                        );
                  },
                  onReject: () {
                    final userContext = ref.watch(userContextProvider);
                    final approveChangeRequestModel = ApproveChangeRequestModel(
                      suconn: userContext.companyConnection,
                      sucode: userContext.companyCode,
                      chRqCd: changeRequestModel?.chrqcd ?? 0,
                      chApBy: changeRequestModel?.chapby,
                      bcSlNo: '0',
                      chapnt: changeRequestModel?.comment,
                      emCode: userContext.empCode,
                      chtype: changeRequestModel?.chrqst, //TODO check with api
                      aprFlag: 'R',
                    );

                    ref
                        .read(approveChangeRequestControllerProvider.notifier)
                        .approveRejectChangeRequest(
                          approveChangeRequestModel: approveChangeRequestModel,
                          context: context,
                        );
                  },
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  /// Special handling for Bank Details (chrqtp == "B")
  Widget _buildBankDetails(ChangeRequestModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHeaderText('Bank Details'),
        8.heightBox,
        detailInfoRow(
          title: "Bank Name",
          subTitle: model.bankNameDetail.toString(),
        ),
        detailInfoRow(title: "Account No", subTitle: model.bcacno ?? "-"),
        detailInfoRow(title: "Account Name", subTitle: model.bcacnm ?? "-"),
      ],
    );
  }

  /// Generic rendering of detail list
  Widget _buildDynamicDetails(List<ChangeRequestDetailModel> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHeaderText('$title Details'),
        8.heightBox,
        ...details.map((d) {
          return detailInfoRow(
            title: d.chtype ?? "",
            subTitle:
                d.chtype?.toLowerCase() == 'issued country' ||
                        d.chtype?.toLowerCase() == 'nationality' ||
                        d.chtype?.toLowerCase() == 'country' ||
                        d.chtype?.toLowerCase() == 'passport holder'
                    ? d.chtext
                    : d.chvalu,
          );
        }),
      ],
    );
  }
}
