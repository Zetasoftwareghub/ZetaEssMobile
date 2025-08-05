import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loders/customScreen_loader.dart';
import '../controller/employee_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final employeeDetails = ref.watch(employeeProfileControllerProvider);

    return SafeArea(
      child: employeeDetails.when(
        data: (profile) {
          if (profile == null) {
            return Center(child: Text('No data found'.tr()));
          }
          return Column(
            children: [
              Container(
                height: 260.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/dashboardTopCard.png'),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 55.r,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          profile.profileImage != null
                              ? MemoryImage(profile.profileImage!)
                              : null,
                      child:
                          profile.profileImage == null
                              ? Icon(CupertinoIcons.person_alt, size: 55.sp)
                              : null,
                    ),
                    10.heightBox,
                    Text(
                      profile.employeeName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    5.heightBox,
                    Text(
                      profile.designation,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Text(
                      'EMP ID: ${profile.employeeId}',
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      employeeDetailHeader(
                        'employment_details'.tr(),
                        CupertinoIcons.briefcase_fill,
                      ),
                      employeeDetailTile(
                        'employee_id'.tr(),
                        profile.employeeId,
                      ),
                      employeeDetailTile(
                        'date_of_joining'.tr(),
                        profile.dateOfJoining,
                      ),
                      employeeDetailTile('department'.tr(), profile.department),
                      employeeDetailTile(
                        'designation'.tr(),
                        profile.designation,
                      ),
                      employeeDetailTile('category'.tr(), profile.categoryName),
                      if (profile.lineManagerName != null &&
                          (profile.lineManagerName ?? '').isNotEmpty)
                        employeeDetailTile(
                          'Line manager name'.tr(),
                          profile.lineManagerName ?? '',
                        ),
                      if (profile.gradeName != null &&
                          (profile.gradeName ?? '').isNotEmpty)
                        employeeDetailTile(
                          'Grade Name'.tr(),
                          profile.gradeName ?? '',
                        ),

                      20.heightBox,
                      if (profile.employeeSalary.isNotEmpty) ...[
                        employeeDetailHeader(
                          'salary_details'.tr(),
                          CupertinoIcons.money_dollar_circle_fill,
                        ),
                        ...profile.employeeSalary.map(
                          (item) => employeeDetailTile(
                            item.salaryName,
                            item.amount.toStringAsFixed(2),
                          ),
                        ),
                        employeeDetailTile(
                          'Total'.tr(),
                          profile.employeeSalary
                              .fold(0.0, (sum, item) => sum + item.amount)
                              .toStringAsFixed(2),
                        ),
                        20.heightBox,
                      ],

                      if (profile.employeeAllowance.isNotEmpty) ...[
                        employeeDetailHeader(
                          'allowance_details'.tr(),
                          CupertinoIcons.gift_fill,
                        ),
                        ...profile.employeeAllowance.map(
                          (item) => employeeDetailTile(
                            item.name,
                            item.amount.toStringAsFixed(2),
                          ),
                        ),
                        employeeDetailTile(
                          'Total'.tr(),
                          profile.employeeAllowance
                              .fold(0.0, (sum, item) => sum + item.amount)
                              .toStringAsFixed(2),
                        ),
                        20.heightBox,
                      ],

                      if (profile.employeeDeduction.isNotEmpty) ...[
                        employeeDetailHeader(
                          'deduction_details'.tr(),
                          CupertinoIcons.minus_circle_fill,
                        ),
                        ...profile.employeeDeduction.map(
                          (item) => employeeDetailTile(
                            item.name,
                            item.amount.toStringAsFixed(2),
                          ),
                        ),
                        employeeDetailTile(
                          'Total'.tr(),
                          profile.employeeDeduction
                              .fold(0.0, (sum, item) => sum + item.amount)
                              .toStringAsFixed(2),
                        ),
                        20.heightBox,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => CustomScreenLoader(loadingText: 'loading_profile'.tr()),
      ),
    );
  }

  Widget employeeDetailHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: AppTheme.primaryColor),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        /*TODO enabel  editing and bring this  Icon(
          CupertinoIcons.square_pencil_fill,
          color: AppTheme.primaryColor,
          size: 18.sp,
        ),*/
      ],
    );
  }

  Widget employeeDetailTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 14.sp, color: Colors.black)),
        ],
      ),
    );
  }

  /* TODO will do this later adding directory      /// Tab bar
            Container(
              margin: EdgeInsets.only(top: 15.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TabBar(
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: "employee_details".tr()),
                  Tab(text: "employee_directory".tr()),
                ],
              ),
            ),

            /// Tab views
            Expanded(
              child: TabBarView(
                children: [
                  /// Employee Details View
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        employeeDetailHeader(
                          'personal_information'.tr(),
                          Icons.person_2_outlined,
                        ),
                        employeeDetailTile(
                          'Email',
                          'ananthukrishnaasaa@gmail.com',
                        ),
                        employeeDetailTile('phone'.tr(), '+971 87868899'),
                        employeeDetailTile('Date of Birth', '10/10/2000'),
                        employeeDetailTile('address'.tr(), 'Manjeri, Kerala'),
                        20.heightBox,
                        employeeDetailHeader(
                          'employment_details'.tr(),
                          CupertinoIcons.briefcase_fill,
                        ),
                        employeeDetailTile('employee_id'.tr(), 'EMP1024'),
                        employeeDetailTile('employee_type'.tr(), 'Full Time'),
                        employeeDetailTile('joining_date', '10/10/2024'),
                        employeeDetailTile(
                          'address_name'.tr(),
                          'Manjeri, Kerala',
                        ),
                      ],
                    ),
                  ),

                  /// Employee Directory View (exactly as per image)
                  SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        directorySection("employee_passport_details".tr(), [
                          "Passport Copy - 1",
                          "Passport Copy - 2",
                          "Passport Copy - 3",
                          "Passport Copy - 4",
                          "Passport Copy - 5",
                        ]),
                        20.heightBox,
                        directorySection("employee_visa_details".tr(), [
                          "Visa Copy",
                        ]),
                        20.heightBox,
                        directorySection("other_documents".tr(), [
                          "Resume",
                          "Aadhaar Card",
                          "Pan Card",
                          "Hdfc details",
                          "10th Certificate",
                          "12th Certificate",
                          "Degree Certificate",
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),*/

  Widget directorySection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        10.heightBox,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.map((item) => fileUploadRow(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget fileUploadRow(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,

                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  side: BorderSide(color: Colors.black, width: .5),
                ),
              ),
              onPressed: () {},
              child: Text(
                "choose_file".tr(),
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "  ${"no_file_chosen".tr()}",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
