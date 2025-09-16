import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';

import '../../../../core/common/alert_dialog/custom_bottomSheets.dart';
import '../../../../core/common/loders/customScreen_loader.dart';
import '../../providers/common_ui_providers.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementProvider);
    return Scaffold(
      appBar: AppBar(title: Text("announcements".tr())),

      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,

          child: announcementsAsync.when(
            data:
                (announcements) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
                      child: InkWell(
                        onTap: () {
                          showCustomDraggableBottomSheet(
                            context: context,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40.w,
                                      height: 5.h,
                                      margin: EdgeInsets.only(bottom: 10.h),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    announcement.announcementTitle,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Divider(thickness: 1.5, height: 20.h),
                                  Text(
                                    announcement.announcementMessage,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          );
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE1F0FB), Color(0xFFB6E2F8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 70.w,
                                height: 90.h,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.campaign_rounded,
                                  size: 32.sp,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Container(
                                height: 70.h,
                                width: 1,
                                color: Colors.blue.shade100,
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        announcement.announcementTitle,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16.sp,
                                            color: Colors.grey.shade700,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy - h:mma',
                                            ).format(
                                              announcement
                                                  .announcementCreatedDate,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            loading:
                () => const CustomScreenLoader(
                  loadingText: 'Loading Announcements...',
                ),
            error: (err, stack) => ErrorText(error: err.toString()),
          ),
        ),
      ),
    );
  }
}
