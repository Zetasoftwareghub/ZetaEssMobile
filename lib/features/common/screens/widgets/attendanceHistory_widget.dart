import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/models/punch_model.dart';

import '../../../../core/theme/app_theme.dart';

class AttendanceHistoryCard extends StatelessWidget {
  final PunchModel punchModel;
  const AttendanceHistoryCard({super.key, required this.punchModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 75.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(12.r)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    punchModel.punchDate.toString(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Wed',
                    style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAttendanceTitle(
                        'check_in'.tr(),
                        punchModel.punchTime.toString(),
                      ),
                      _buildAttendanceTitle(
                        'check_out'.tr(),
                        punchModel.punchTime.toString(),
                      ),
                      _buildAttendanceTitle(
                        'total_hours'.tr(),
                        punchModel.punchTime.toString(),
                      ),
                    ],
                  ),
                  5.heightBox,

                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          punchModel.punchLocation ?? "No Location",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  10.heightBox,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAttendanceTitle(String title, String subTitle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.h),
      child: Column(
        children: [
          SizedBox(
            width: 75.w,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
