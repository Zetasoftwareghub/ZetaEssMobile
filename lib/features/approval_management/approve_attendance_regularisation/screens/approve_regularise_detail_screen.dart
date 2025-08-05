import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../controller/approve_attendance_regularisation_controller.dart';
import '../models/approve_attendanceRegularise_details.dart';
import '../repository/approve_attendance_regularisation_repository.dart';

class AttendanceRegularizationApprove extends ConsumerStatefulWidget {
  AttendanceRegularizationApprove({super.key, this.id, this.isApproveTab});
  final bool? isApproveTab;
  final String? id;

  @override
  ConsumerState<AttendanceRegularizationApprove> createState() =>
      _AttendanceRegularizationApproveState();
}

class _AttendanceRegularizationApproveState
    extends ConsumerState<AttendanceRegularizationApprove>
    with TickerProviderStateMixin {
  TextEditingController noteController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  LMAttendanceRegularizationApproveDetails? sdetails;
  List<LMAttendanceRegularizationApproveDetails> canLst = [];
  List<LMAttendanceRegularizationApproveDetails> rejLst = [];

  final _formKey = GlobalKey<FormState>();
  FocusNode? _focusNode;

  String prevComment = "";
  String lmComment = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    Future.microtask(() => _getDetails());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode?.dispose();
    noteController.dispose();
    super.dispose();
  }

  Widget buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
      margin: EdgeInsets.only(bottom: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8F4FD), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xFF0BA4DB), size: 20.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF8B8B8B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF2A2A2A),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0BA4DB), Color(0xFF10A0DB)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0BA4DB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22.w),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentSection(String title, String comment, Color accentColor) {
    if (comment.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,

            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Text(
              comment,
              style: TextStyle(
                color: const Color(0xFF2A2A2A),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEnhancedDataTable({
    required List<DataRow> rows,
    bool showNoData = false,
    String? title,
  }) {
    if (showNoData && rows.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48.w,
              color: const Color(0xFFCCCCCC),
            ),
            SizedBox(height: 16.h),
            Text(
              "No Data Available",
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: DataTable(
          columnSpacing: 20.w,
          horizontalMargin: 20.w,
          dividerThickness: 0,
          showBottomBorder: false,
          headingRowHeight: 50.h,
          dataRowHeight: 60.h,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => const Color(0xFFF8FCFE),
          ),
          columns: [
            DataColumn(
              label: Text(
                "Check Date",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF0BA4DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Check Time",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF0BA4DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Type",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF0BA4DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          rows: rows,
        ),
      ),
    );
  }

  List<DataRow> buildEnhancedDataRows(
    List<LMAttendanceRegularizationApproveDetails> items, {
    bool withBorder = false,
  }) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isEven = index % 2 == 0;

      return DataRow(
        color: MaterialStateColor.resolveWith(
          (states) => isEven ? const Color(0xFFFAFCFF) : Colors.white,
        ),
        cells: [
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration:
                  withBorder
                      ? BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF0BA4DB).withOpacity(0.3),
                        ),
                      )
                      : null,
              child: Text(
                item.dLsrdtf ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ),
          ),
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration:
                  withBorder
                      ? BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF0BA4DB).withOpacity(0.3),
                        ),
                      )
                      : null,
              child: Text(
                item.empName ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ),
          ),
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration:
                  withBorder
                      ? BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF0BA4DB).withOpacity(0.3),
                        ),
                      )
                      : null,
              child: Text(
                item.lsnote ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  bool validateEmoji(String text) {
    final regex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return regex.hasMatch(text);
  }

  Future<void> _getDetails() async {
    setState(() => _isLoading = true);

    try {
      final response = await getLMAttendanceRegularizationDetails(
        widget.id.toString(),
        ref.watch(userContextProvider),
      ).timeout(const Duration(seconds: 60));

      List<LMAttendanceRegularizationApproveDetails> sub = [];
      List<LMAttendanceRegularizationApproveDetails> can = [];
      List<LMAttendanceRegularizationApproveDetails> rej = [];

      if (response["subLst"] != null) {
        for (var item in response["subLst"]) {
          sub.add(LMAttendanceRegularizationApproveDetails.fromJson(item));
        }
      }
      if (response["canLst"] != null) {
        for (var item in response["canLst"]) {
          can.add(LMAttendanceRegularizationApproveDetails.fromJson(item));
        }
      }
      if (response["rejLst"] != null) {
        for (var item in response["rejLst"]) {
          rej.add(LMAttendanceRegularizationApproveDetails.fromJson(item));
        }
      }

      setState(() {
        sdetails = sub.isNotEmpty ? sub.first : null;
        if (sub.isNotEmpty) {
          prevComment = sub.first.prevComment ?? '';
          lmComment = sub.first.lmComment ?? '';
        }
        canLst = can;
        rejLst = rej;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _navigateToNoServer();
    }
  }

  void _navigateToNoServer() {
    showSnackBar(context: context, content: 'Error loading data');
  }

  void _showAlertDialog(String message) {
    showCupertinoModalPopup<void>(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            title: Text(
              "Success",
              style: TextStyle(
                color: const Color(0xFF0BA4DB),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Color(0xFF0BA4DB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Approval"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0BA4DB),
              size: 18.w,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading) Loader(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: AppPadding.screenPadding,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Employee Details Section
                            buildSectionHeader(
                              "Employee Details",
                              Icons.person_outline,
                            ),

                            buildDetailCard(
                              "Alternate ID",
                              sdetails?.dLsrdtf ?? '',
                              Icons.badge_outlined,
                            ),
                            buildDetailCard(
                              "Employee Name",
                              sdetails?.empName ?? '',
                              Icons.person_outline,
                            ),
                            buildDetailCard(
                              "Attendance Date",
                              sdetails?.dLsdate ?? '',
                              Icons.calendar_today_outlined,
                            ),

                            SizedBox(height: 10.h),

                            // Current Attendance Section
                            buildSectionHeader(
                              "Current Attendance",
                              Icons.schedule_outlined,
                            ),
                            buildEnhancedDataTable(
                              rows: buildEnhancedDataRows(
                                canLst,
                                withBorder: true,
                              ),
                            ),

                            // Employee Remarks Section
                            buildSectionHeader(
                              "Employee Remarks",
                              Icons.comment_outlined,
                            ),
                            Container(
                              width: double.infinity,

                              margin: EdgeInsets.only(bottom: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                sdetails?.subname ?? 'No remarks provided',
                                style: TextStyle(
                                  color: const Color(0xFF2A2A2A),
                                  fontSize: 14.sp,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            // Previous Comments
                            buildCommentSection(
                              "Previous Comment",
                              prevComment,
                              const Color(0xFFFF9500),
                            ),

                            buildCommentSection(
                              "Line Manager Comment",
                              lmComment,
                              const Color(0xFF34C759),
                            ),

                            // Approve/Reject Comment Section
                            buildSectionHeader(
                              "Your Comment",
                              Icons.rate_review_outlined,
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 15.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length > 500) {
                                      return "Maximum 500 characters allowed";
                                    }
                                    if (validateEmoji(value)) {
                                      return "Emojis are not supported";
                                    }
                                  }
                                  return null;
                                },
                                controller: noteController,
                                maxLines: 4,
                                minLines: 1,
                                keyboardType: TextInputType.multiline,
                                focusNode: _focusNode,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF2A2A2A),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your comment here...",
                                  hintStyle: TextStyle(
                                    color: const Color(0xFFCCCCCC),
                                    fontSize: 14.sp,
                                  ),
                                  contentPadding: EdgeInsets.all(16.w),
                                ),
                              ),
                            ),

                            // Old Attendance Section
                            buildSectionHeader(
                              "Previous Attendance",
                              Icons.history_outlined,
                            ),
                            buildEnhancedDataTable(
                              rows: buildEnhancedDataRows(rejLst),
                              showNoData: true,
                            ),

                            SizedBox(height: 50.h), // Space for action buttons
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet:
          (widget.isApproveTab ?? false)
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    ref
                        .read(approveRegulariseControllerProvider.notifier)
                        .approveRejectRegularise(
                          note: noteController.text,
                          requestId: widget.id ?? '0',
                          approveRejectFlag: 'A',
                          context: context,
                          strEmailId: sdetails?.dLsrdtf ?? '',
                        );
                  },
                  onReject: () {
                    if (noteController.text.isEmpty) {
                      showCustomAlertBox(
                        context,
                        title: 'Please give reject comment',
                        type: AlertType.error,
                      );

                      return;
                    }
                    ref
                        .read(approveRegulariseControllerProvider.notifier)
                        .approveRejectRegularise(
                          note: noteController.text,
                          requestId: widget.id ?? '0',
                          approveRejectFlag: 'R',
                          context: context,
                          strEmailId: sdetails?.dLsrdtf ?? '',
                        );
                  },
                ),
              )
              : null,
    );
  }
}

/*
*
class AttendanceRegularizationApprove extends ConsumerStatefulWidget {
  AttendanceRegularizationApprove({super.key, this.id});

  final String? id;

  @override
  ConsumerState<AttendanceRegularizationApprove> createState() =>
      _AttendanceRegularizationApproveState();
}

class _AttendanceRegularizationApproveState
    extends ConsumerState<AttendanceRegularizationApprove> {
  TextEditingController noteController = TextEditingController();

  LMAttendanceRegularizationApproveDetails? sdetails;
  List<LMAttendanceRegularizationApproveDetails> canLst = [];
  List<LMAttendanceRegularizationApproveDetails> rejLst = [];

  final _formKey = GlobalKey<FormState>();
  FocusNode? _focusNode;

  String prevComment = "";
  String lmComment = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _getDetails());
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    noteController.dispose();
    super.dispose();
  }

  Widget buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(color: const Color(0xFF565656), fontSize: 14.sp),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: const Color(0xFF565656),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  bool validateEmoji(String text) {
    final regex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return regex.hasMatch(text);
  }

  Future<void> _getDetails() async {
    //.show();
    print('a');
    try {
      final response = await getLMAttendanceRegularizationDetails(
        widget.id.toString(),
        ref.watch(userContextProvider),
      ).timeout(const Duration(seconds: 60));

      // if (response == null) {
      //   _navigateToNoServer();
      //   return;
      // }

      List<LMAttendanceRegularizationApproveDetails> sub = [];
      List<LMAttendanceRegularizationApproveDetails> can = [];
      List<LMAttendanceRegularizationApproveDetails> rej = [];

      if (response["subLst"] != null) {
        for (var item in response["subLst"]) {
          sub.add(LMAttendanceRegularizationApproveDetails.fromJson(item));
        }
      }
      if (response["canLst"] != null) {
        for (var item in response["canLst"]) {
          can.add(LMAttendanceRegularizationApproveDetails.fromJson(item));
        }
      }
      if (response["rejLst"] != null) {
        for (var item in response["rejLst"]) {
          rej.add(LMAttendanceRegularizationApproveDetails.fromJson(item));
        }
      }

      setState(() {
        sdetails = sub.isNotEmpty ? sub.first : null;
        if (sub.isNotEmpty) {
          prevComment = sub.first.prevComment ?? '';
          lmComment = sub.first.lmComment ?? '';
        }
        canLst = can;
        rejLst = rej;
      });
    } catch (e) {
      _navigateToNoServer();
    } finally {
      //.hide();
    }
  }

  void _navigateToNoServer() {
    print('1233');
    showSnackBar(context: context, content: 'ERORORO');
  }

  Future<void> _approve() async {
    //.show();

    try {
      String response = 'ads';

      // String response = await approveRegularization(
      //     widget.id ?? '',
      //     "A",
      //     noteController.text,
      //     sdetails?.dLsrdtf ?? ''
      // ).timeout(const Duration(seconds: 60));

      if (response ==
          "Attendance regularization request approved successfully") {
        response = "Approved Successfully";
      }

      _showAlertDialog(response);
    } catch (e) {
      _navigateToNoServer();
    } finally {
      //.hide();
    }
  }

  Future<void> _reject() async {
    //.show();

    try {
      String response = 'ads';
      // String response = await approveRegularization(
      //     widget.id ?? '',
      //     "R",
      //     noteController.text,
      //     sdetails?.dLsrdtf ?? ''
      // ).timeout(const Duration(seconds: 60));

      if (response ==
          "Attendance regularization request rejected successfully") {
        response = "Rejected Successfully";
      }

      _showAlertDialog(response);
    } catch (e) {
      _navigateToNoServer();
    } finally {
      //.hide();
    }
  }

  void _showAlertDialog(String message) {
    showCupertinoModalPopup<void>(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            content: Text(message),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Color(0xFF0BA4DB)),
                ),
              ),
            ],
          ),
    );
  }

  List<DataRow> buildDataRows(
    List<LMAttendanceRegularizationApproveDetails> items, {
    bool withBorder = false,
  }) {
    return items.map((item) {
      return DataRow(
        color: MaterialStateColor.resolveWith(
          (states) => const Color(0xFFF3F3F3),
        ),
        cells: [
          DataCell(
            withBorder
                ? Container(
                  width: 100,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    item.dLsrdtf ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                )
                : Text(
                  item.dLsrdtf ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
          ),
          DataCell(
            withBorder
                ? Container(
                  width: 100,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    item.empName ?? '',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                )
                : Text(item.empName ?? '', style: TextStyle(fontSize: 12.sp)),
          ),
          DataCell(
            withBorder
                ? Container(
                  width: 100,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    item.lsnote ?? '',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                )
                : Text(item.lsnote ?? '', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      );
    }).toList();
  }

  Widget buildDataTable({
    required List<DataRow> rows,
    bool showNoData = false,
  }) {
    if (showNoData && rows.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 0, 0),
          child: Text(
            "No Data Available",
            style: TextStyle(color: const Color(0xFF565656), fontSize: 14.sp),
          ),
        ),
      );
    }

    return DataTable(
      columnSpacing: 2,
      dividerThickness: 0,
      showBottomBorder: false,
      headingRowColor: MaterialStateColor.resolveWith(
        (states) => const Color(0xFFD5F2FA),
      ),
      columns: const [
        DataColumn(
          label: Text(
            "Check Date",
            style: TextStyle(fontSize: 13, color: Color(0xFF2A2A2A)),
          ),
        ),
        DataColumn(
          label: Text(
            "Check Time",
            style: TextStyle(fontSize: 13, color: Color(0xFF2A2A2A)),
          ),
        ),
        DataColumn(
          label: Text(
            "Type",
            style: TextStyle(fontSize: 13, color: Color(0xFF2A2A2A)),
          ),
        ),
      ],
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5F2FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF000000),
        ),
        backgroundColor: const Color(0xFFD5F2FA),
        title: Text(
          "Attendance Regularization Approve",
          style: TextStyle(
            fontSize: 17.sp,
            color: const Color(0xFF09A5D9),
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0E6D9B),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(top: 8.0.h),
            child: Material(
              color: const Color(0xFFFFFFFF),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              shadowColor: const Color(0xFFF1F1F1).withOpacity(.9),
              elevation: 15.0,
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),

                        // Employee Details Section
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Employee Details",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: const Color(0xFF10A0DB),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(28.h),
                          child: Column(
                            children: [
                              buildDetailRow(
                                "Alternate ID",
                                sdetails?.dLsrdtf ?? '',
                              ),
                              SizedBox(height: 30.h),
                              buildDetailRow(
                                "Employee Name",
                                sdetails?.empName ?? '',
                              ),
                              SizedBox(height: 30.h),
                              buildDetailRow(
                                "Attendance Date",
                                sdetails?.dLsdate ?? '',
                              ),
                              SizedBox(height: 30.h),
                            ],
                          ),
                        ),

                        // Data Table for CanLst
                        SizedBox(
                          width: double.infinity,
                          child: buildDataTable(
                            rows: buildDataRows(canLst, withBorder: true),
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // Employee Remarks Section
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Employee Remarks",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: const Color(0xFF10A0DB),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            sdetails?.subname ?? '',
                            style: TextStyle(
                              color: const Color(0xFF565656),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),

                        // Previous Comment Section
                        if (prevComment.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              "Previous Comment",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: const Color(0xFF10A0DB),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 20,
                              left: 25,
                            ),
                            child: Text(
                              prevComment,
                              style: TextStyle(
                                color: const Color(0xFF565656),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],

                        // Line Manager Comment Section
                        if (lmComment.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              "Comment",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: const Color(0xFF10A0DB),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 20,
                              left: 25,
                            ),
                            child: Text(
                              lmComment,
                              style: TextStyle(
                                color: const Color(0xFF565656),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],

                        // Approve/Reject Comment Section
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Approve/Reject Comment",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: const Color(0xFF10A0DB),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: TextFormField(
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length > 500) {
                                  return "Maximum 500 characters";
                                }
                                if (validateEmoji(value)) {
                                  return "Emojis not supported";
                                }
                              }
                              return null;
                            },
                            controller: noteController,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            focusNode: _focusNode,
                            onEditingComplete: () => _focusNode?.unfocus(),
                            style: TextStyle(
                              fontSize: 14.0.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Comment",
                              hintStyle: TextStyle(
                                color: const Color(0xFFD6D6D6),
                                fontSize: 14.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0.r),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0E6D9B),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0E6D9B),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Old Attendance Section
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Old Attendance",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: const Color(0xFF10A0DB),
                            ),
                          ),
                        ),

                        SizedBox(height: 30.h),

                        SizedBox(
                          width: double.infinity,
                          child: buildDataTable(
                            rows: buildDataRows(rejLst),
                            showNoData: true,
                          ),
                        ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

* */
