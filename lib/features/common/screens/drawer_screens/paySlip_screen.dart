import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';

import '../../controller/common_controller.dart';
import '../../providers/common_ui_providers.dart';

class PayslipScreen extends ConsumerStatefulWidget {
  const PayslipScreen({super.key});

  @override
  ConsumerState<PayslipScreen> createState() => _PaySlipsState();
}

class _PaySlipsState extends ConsumerState<PayslipScreen> {
  final List<String> items = [];
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year.toString();

    items.add(now.year.toString());
    for (var k = 1; k <= 10; k++) {
      items.add((now.year - k).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final payslipData = ref.watch(paySlipsListProvider(selectedYear ?? ''));
    final theme = Theme.of(context);
    final isLoading = ref.watch(commonControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "payslips".tr(),
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Year Selector
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Year",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.primaryColor,
                        ),
                        isExpanded: true,
                        hint: Text(
                          "Select Year",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        items:
                            items
                                .map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        value: selectedYear,
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? Loader()
                : Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: payslipData.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _buildPayslipList(data, theme);
                      },
                      loading: () => _buildLoadingState(),
                      error: (e, _) => _buildErrorState(e.toString()),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            "No payslips found",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "No payslips available for the selected year",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            "Loading payslips...",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red[400]),
          SizedBox(height: 16.h),
          Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipList(List<dynamic> data, ThemeData theme) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = data[index];
        return _buildPayslipCard(item, theme);
      },
    );
  }

  Widget _buildPayslipCard(dynamic item, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Month Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: theme.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fileName ?? 'Unknown Month',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.description ?? 'No amount specified',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Download Button
            Consumer(
              builder: (context, ref, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ref
                            .read(commonControllerProvider.notifier)
                            .launchPayslipDownloadUrl(
                              context: context,
                              monthName: item.fileKey,
                              year: selectedYear ?? '',
                            );
                      },
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        child: Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/*
FIGMA CODE UI
class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payslips")),

      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              labelText("Select Year"),
              CustomDropdown(hintText: "Select Year"),
              SizedBox(height: 12.h),
              labelText("Select Month"),
              CustomDropdown(hintText: "Select Month"),
              SizedBox(height: 24.h),
              _buildPayslipCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayslipCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ananthu Krishna", style: AppTextStyles.largeFont()),
          detailInfoRow(
            title: "Flutter Developer\nAdministration",
            subTitle: "EMP20230045",
          ),

          Divider(height: 12.h, color: Colors.grey.shade400),
          titleHeaderText("April 2024"),
          SizedBox(height: 8.h),
          detailInfoRow(title: "Basic Salary", subTitle: "45,000"),
          detailInfoRow(title: "Allowances", subTitle: "1,200"),
          detailInfoRow(title: "Deductions", subTitle: "500"),
          detailInfoRow(title: "Net Salary", subTitle: "44,700"),
          detailInfoRow(title: "Payment Date", subTitle: "28/10/2024"),
          detailInfoRow(title: "Payment Method", subTitle: "Bank Transfer"),
          detailInfoRow(title: "Account Number", subTitle: "******8989"),
          SizedBox(height: 16.h),
          CustomElevatedButton(onPressed: () {}, child: Text("Download PDF")),
        ],
      ),
    );
  }
}
*/
