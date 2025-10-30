import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' as getX;
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/leave_management/repository/leave_repository.dart';

import '../../../../../core/api_constants/dio_headers.dart';
import '../../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../../core/common/no_server_screen.dart';
import '../../../../../core/providers/userContext_provider.dart';
import '../../controller/old_hrms_configuration_stuffs.dart';

class LeaveMoreDetailsScreen extends ConsumerStatefulWidget {
  final String? dateFrom;
  final String? dateTo;
  final String? leaveCode;
  final String lssNo;
  const LeaveMoreDetailsScreen({
    Key? key,
    this.dateFrom,
    this.dateTo,
    this.leaveCode,
    required this.lssNo,
  }) : super(key: key);

  @override
  ConsumerState<LeaveMoreDetailsScreen> createState() =>
      _LeaveMoreDetailsScreenState();
}

class _LeaveMoreDetailsScreenState
    extends ConsumerState<LeaveMoreDetailsScreen> {
  bool dateChanged = false;
  bool isLoading = false;
  List<LeaveConfigurationEditData> leaveConfigData = [];
  List<LeaveConfigurationEditData> leaveConfigDataSubLst = [];
  List<LeaveConfigurationEditData> leaveConfigDataCanLst = [];

  final LeaveConfigurationController leaveController = getX.Get.put(
    LeaveConfigurationController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getConfigurations();
    });
  }

  void _addSelectOption() {
    LeaveConfigurationEditData selectOption = LeaveConfigurationEditData(
      dayType: 0,
      dLsdate: "-- Select --",
      lieuday: "null",
    );

    bool hasSelectOption = leaveConfigDataCanLst.any(
      (element) => element.dLsdate == "-- Select --",
    );

    if (!hasSelectOption) {
      leaveConfigDataCanLst.add(selectOption);
    }
  }

  Future<void> _setSandwichLogic() async {
    try {
      List<LeaveConfigurationEditData> updatedData = List.from(leaveConfigData);

      var responseJson = await ref
          .read(leaveRepositoryProvider)
          .getEditLeaveDetails(
            userContext: ref.watch(userContextProvider),
            leaveId: int.parse(widget.leaveCode ?? '0'),
          );

      List<LeaveConfigurationEditData> subList = [];
      for (var i in responseJson) {
        for (var item in i["subLst"]) {
          subList.add(LeaveConfigurationEditData.fromJson(item));
        }
      }

      if (subList.isEmpty) return;

      var config = subList[0];
      var includeOff = config.includeOff ?? "N";
      var includeHoliday = config.includeHolliday ?? "N";
      var glapho = config.glapho ?? "N";
      var ltaphl = config.ltaphl ?? "N";

      _processSandwichDates(
        updatedData,
        includeOff,
        includeHoliday,
        glapho,
        ltaphl,
      );

      setState(() {
        leaveConfigData = updatedData;
      });

      leaveController.setDataEdit(updatedData);
    } catch (e) {
      print('Error in setSandwichLogic: $e');
    }
  }

  void _processSandwichDates(
    List<LeaveConfigurationEditData> data,
    String includeOff,
    String includeHoliday,
    String glapho,
    String ltaphl,
  ) {
    DateTime fromDate = DateFormat('dd/MM/yyyy').parse(data.first.date ?? '');
    DateTime toDate = DateFormat('dd/MM/yyyy').parse(data.last.date ?? '');
    DateTime startDate = fromDate;

    while (startDate.isBefore(toDate) || startDate.isAtSameMomentAs(toDate)) {
      var startDateStr = DateFormat('dd/MM/yyyy').format(startDate);
      var item = data.firstWhere(
        (element) => element.date == startDateStr,
        orElse: () => LeaveConfigurationEditData(dayType: 1),
      );

      if (item.dayType == 3 || item.dayType == 4) {
        _updateDayFlag(
          data,
          startDateStr,
          item,
          includeOff,
          includeHoliday,
          glapho,
          ltaphl,
        );
      }

      startDate = startDate.add(const Duration(days: 1));
    }
  }

  void _updateDayFlag(
    List<LeaveConfigurationEditData> data,
    String dateStr,
    LeaveConfigurationEditData item,
    String includeOff,
    String includeHoliday,
    String glapho,
    String ltaphl,
  ) {
    var dataItem = data.firstWhere((element) => element.date == dateStr);

    if (ltaphl == "N") {
      if (item.dayType == 3) {
        dataItem.dayFlag = includeOff == "N" ? '' : 'F';
      } else if (item.dayType == 4) {
        dataItem.dayFlag = includeHoliday == "N" ? '' : 'F';
      }
    } else {
      // More complex logic for sandwich rules
      _applySandwichRules(
        data,
        dataItem,
        item,
        includeOff,
        includeHoliday,
        glapho,
      );
    }
  }

  void _applySandwichRules(
    List<LeaveConfigurationEditData> data,
    LeaveConfigurationEditData dataItem,
    LeaveConfigurationEditData item,
    String includeOff,
    String includeHoliday,
    String glapho,
  ) {
    // Simplified sandwich logic - you can expand this based on your business rules
    if (glapho == "N") {
      if (item.dayType == 3) {
        dataItem.dayFlag = includeOff == "N" ? '' : 'F';
      } else if (item.dayType == 4) {
        dataItem.dayFlag = includeHoliday == "N" ? '' : 'F';
      }
    } else {
      // Apply sandwich rules based on preceding/trailing logic
      dataItem.dayFlag = '';
    }
  }

  void _getConfigurations() async {
    setState(() => isLoading = true);
    try {
      // Future.microtask(() async => await _getLeaveDetails());
      //
      // _setSandwichLogic();
      await _getLeaveDetails(); // ✅ Wait for this to complete
      await _setSandwichLogic(); // ✅ Also make this async and wait
    } catch (e) {
      print('Error getting configurations: $e');
      _navigateToNoServer();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getLeaveDetails() async {
    var leaveDetails = await ref
        .read(leaveRepositoryProvider)
        .getEditLeaveDetails(
          userContext: ref.watch(userContextProvider),
          leaveId: int.parse(widget.leaveCode ?? '0'),
        );
    if (leaveDetails == null) {
      _navigateToNoServer();
      return;
    }

    _processLeaveDetailsResponse(leaveDetails);
  }

  void _processLeaveDetailsResponse(dynamic responseJson) {
    List<LeaveConfigurationEditData> appData = [];
    List<LeaveConfigurationEditData> subData = [];
    List<LeaveConfigurationEditData> canData = [];
    debugPrint(jsonEncode(responseJson));
    jsonEncode('responseJson');
    for (var item in responseJson["appLst"] ?? []) {
      appData.add(LeaveConfigurationEditData.fromJson(item));
    }

    for (var item in responseJson["subLst"] ?? []) {
      subData.add(LeaveConfigurationEditData.fromJson(item));
    }

    for (var item in responseJson["canLst"] ?? []) {
      canData.add(LeaveConfigurationEditData.fromJson(item));
    }

    setState(() {
      leaveConfigData = appData;
      leaveConfigDataSubLst = subData;
      leaveConfigDataCanLst = canData;
      _addSelectOption();
    });

    leaveController.setDataEdit(appData);
  }

  void _navigateToNoServer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoServer()),
    );
  }

  void _updateHalfType(String type, LeaveConfigurationEditData targetItem) {
    setState(() {
      for (var item in leaveConfigData) {
        if (item.date == targetItem.date) {
          item.halfType = type;
          break;
        }
      }
    });

    leaveController.setDataEdit(leaveConfigData);
    _setSandwichLogic();
    Navigator.pop(context);
  }

  String _getDateColor(String dayType) {
    switch (dayType) {
      case "3":
        return "#FF0000";
      case "4":
        return "#78DE95";
      default:
        return "#ffffff";
    }
  }

  bool _isLieuDayEnabled() {
    return leaveConfigDataSubLst.isNotEmpty &&
        (leaveConfigDataSubLst[0].ltlieu ?? 'N') == "Y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Configuration')),
      body:
          isLoading
              ? Loader()
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEnhancedDataTable(),
                              SizedBox(height: 24.h),

                              CustomElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Go Back'),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEnhancedDataTable() {
    return Container(
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
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: HexColor("#F8FAFB"),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      color: HexColor("#374151"),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Full\nDay',
                      style: TextStyle(
                        color: HexColor("#374151"),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Half\nDay',
                      style: TextStyle(
                        color: HexColor("#374151"),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_isLieuDayEnabled())
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        'Lieu Day',
                        style: TextStyle(
                          color: HexColor("#374151"),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Table Body
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaveConfigData.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final item = leaveConfigData[index];
              return _buildEnhancedDataRow(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDataRow(LeaveConfigurationEditData item, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Date Cell
          Expanded(flex: 4, child: _buildEnhancedDateCell(item)),
          // Full Day Cell
          Expanded(
            flex: 2,
            child: Center(child: _buildEnhancedFullDayCell(item)),
          ),
          // Half Day Cell
          Expanded(
            flex: 2,
            child: Center(child: _buildEnhancedHalfDayCell(item)),
          ),
          // Lieu Day Cell
          if (_isLieuDayEnabled())
            Expanded(flex: 4, child: _buildEnhancedLieuDayCell(item)),
        ],
      ),
    );
  }

  Widget _buildEnhancedDateCell(LeaveConfigurationEditData item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HexColor(_getDateColor(item.dayType.toString())),
            HexColor(_getDateColor(item.dayType.toString())).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: HexColor(
              _getDateColor(item.dayType.toString()),
            ).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: labelText(item.date ?? ''),
    );
  }

  Widget _buildEnhancedFullDayCell(LeaveConfigurationEditData item) {
    bool isSelected = item.dayFlag == "F";
    bool isDisabled = item.dayType == 3 || item.dayType == 4;

    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? HexColor("#10A0DB")
                  : isDisabled
                  ? Colors.grey[300]
                  : HexColor("#E1F5FE"),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color:
                isSelected
                    ? HexColor("#10A0DB")
                    : isDisabled
                    ? Colors.grey[400]!
                    : HexColor("#B3E5FC"),
            width: 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: HexColor("#10A0DB").withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child:
            isSelected
                ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                : null,
      ),
    );
  }

  Widget _buildEnhancedHalfDayCell(LeaveConfigurationEditData item) {
    bool isSelected = item.dayFlag == "H";
    bool isDisabled = item.dayType == 3 || item.dayType == 4;

    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? HexColor("#FF9800")
                      : isDisabled
                      ? Colors.grey[300]
                      : HexColor("#FFF3E0"),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color:
                    isSelected
                        ? HexColor("#FF9800")
                        : isDisabled
                        ? Colors.grey[400]!
                        : HexColor("#FFCC02"),
                width: 2,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: HexColor("#FF9800").withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child:
                isSelected
                    ? Icon(Icons.schedule, color: Colors.white, size: 14.sp)
                    : null,
          ),
          if (isSelected) ...[
            SizedBox(height: 4.h),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: HexColor("#FF9800"),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.halfType == "1" ? "FH" : "SH",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedLieuDayCell(LeaveConfigurationEditData item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: HexColor("#F3F4F6"),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: HexColor("#E5E7EB")),
        ),
        child: Text(
          item.ludate ?? '',
          style: TextStyle(
            fontSize: 10.sp,
            color: HexColor("#374151"),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future getLeaveConfigurations(
    String dateFrom,
    String dateTo,
    String leaveType,
    UserContext userContext,
  ) async {
    try {
      final data = {
        "suconn": ref.watch(userContextProvider).companyConnection,
        "emcode": ref.watch(userContextProvider).empCode,
        "dtfrm": dateFrom,
        "dtto": dateTo,
        "leavcode": leaveType,
      };
      print(data);
      print('leaeve details');
      final responseJson = await Dio().post(
        "${userContext.baseUrl}/api/Leave/CalculateLeave",
        data: data,
        options: dioHeader(token: ref.watch(userContextProvider).jwtToken),
      );

      return responseJson.data['data'];
    } catch (e) {
      return null;
    }
  }
}
