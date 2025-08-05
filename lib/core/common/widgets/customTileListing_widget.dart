import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../theme/app_theme.dart';

class CustomTileListingWidget extends StatelessWidget {
  final String? text1, subText1;
  final String text2, subText2;
  final ListRightsModel? listRights;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomTileListingWidget({
    super.key,
    this.text1,
    this.subText1,
    this.listRights,
    required this.text2,
    required this.subText2,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool showMenuIcon =
        listRights != null &&
        ((listRights?.canEdit ?? false) || (listRights?.canDelete ?? false));

    return Container(
      height: 80.h,
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: text1 == null ? 5.w : 14.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                topLeft: Radius.circular(12.r),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text1 == 'null' ? '-' : text1 ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                if (subText1 != null)
                  Text(
                    subText1 == 'null' ? '-' : subText1 ?? "",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
              ],
            ),
          ),
          10.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text2 == 'null' ? '-' : text2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.heightBox,
                if (subText2.isNotEmpty)
                  Text(
                    subText2 == 'null' ? '-' : subText2,
                    style: TextStyle(color: Colors.black54, fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          showMenuIcon
              ? PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20.sp),
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      onView?.call();
                      break;
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(value: 'view', child: Text('View'.tr())),
                    if (listRights?.canEdit ?? false)
                      PopupMenuItem(value: 'edit', child: Text('Edit'.tr())),
                    if (listRights?.canDelete ?? false)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'.tr()),
                      ),
                  ];
                },
              )
              : Icon(Icons.arrow_forward_ios, size: 16.sp),
          10.widthBox,
        ],
      ),
    );
  }
}
