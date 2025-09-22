import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';

class SchoolingAllowanceDetailScreen extends StatelessWidget {
  final bool? isLineManager;

  const SchoolingAllowanceDetailScreen({super.key, this.isLineManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- section
                titleHeaderText('employee_details'.tr()),
                detailInfoRow(
                  title: 'employee_id'.tr(),
                  subTitle: '10/10/2025',
                ),
                detailInfoRow(
                  title: 'employee_name'.tr(),
                  subTitle: 'Mohammed',
                ),
                detailInfoRow(title: 'no_of_days'.tr(), subTitle: '10 Days'),
                detailInfoRow(
                  title: 'designation'.tr(),
                  subTitle: '06/10/2025',
                ),
                detailInfoRow(
                  title: 'category'.tr(),
                  subTitle: 'Ananthu Krishna',
                ),
                detailInfoRow(
                  title: 'date_of_joining'.tr(),
                  subTitle: '12/12/1220',
                ),

                titleHeaderText('submitted_details'.tr()),
                detailInfoRow(
                  title: 'request_type'.tr(),
                  subTitle: 'Schooling Allowance',
                ),
                detailInfoRow(
                  title: 'requested_date'.tr(),
                  subTitle: '20/10/2025',
                ),
                detailInfoRow(
                  title: 'payment_release_month'.tr(),
                  subTitle: 'October',
                ),
                detailInfoRow(title: 'child_name'.tr(), subTitle: 'Ananthu'),
                detailInfoRow(title: 'grade'.tr(), subTitle: 'A Grade'),
                detailInfoRow(
                  title: 'school_name'.tr(),
                  subTitle: 'GHSS Pandikkad',
                ),
                detailInfoRow(title: 'curriculum'.tr(), subTitle: 'Sports'),
                detailInfoRow(
                  title: 'academic_year'.tr(),
                  subTitle: '2016 - 2017',
                ),
                detailInfoRow(
                  title: 'academic_term'.tr(),
                  subTitle: '1st Term',
                ),
                detailInfoRow(
                  title: 'academic_month_from'.tr(),
                  subTitle: 'januvary',
                ),
                detailInfoRow(
                  title: 'academic_month_to'.tr(),
                  subTitle: 'December',
                ),
                detailInfoRow(
                  title: 'requested_amount'.tr(),
                  subTitle: '10,000',
                ),
                detailInfoRow(title: 'status'.tr(), subTitle: 'Pending'),

                detailInfoRow(
                  title: 'note'.tr(),

                  belowValue:
                      "Lorem Ipsum is simply dummy  text of the printing and  dh typesetting industry.",
                ),

                // -- section
                titleHeaderText('attachments'.tr()),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Text(
                    '* No Attachments',
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                ),

                titleHeaderText('comment'.tr()),
                Text('Approval level 3', style: TextStyle(fontSize: 15.sp)),
                30.heightBox,
              ],
            ),
          ),
        ),
      ),
      bottomSheet:
          isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(onApprove: () {},            onReject: () {   }),
              )
              : const SizedBox.shrink(),
    );
  }
}
