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
  final String? showSubmit;
  final bool fromAppTab;
  final String lssNo;
  const LeaveMoreDetailsScreen({
    Key? key,
    this.dateFrom,
    this.dateTo,
    this.leaveCode,
    this.showSubmit,
    required this.fromAppTab,
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
    _getConfigurations();
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

  void _setSandwichLogic() async {
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
    setState(() {
      isLoading = true;
    });
    try {
      if (widget.showSubmit == "true") {
        Future.microtask(() async => await _getLeaveDetails());
      } else {
        Future.microtask(() async => await _getLeaveConfigurationsEdit());
      }
      _setSandwichLogic();
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
    print(leaveDetails);
    print("leaveDetails");
    if (leaveDetails == null) {
      _navigateToNoServer();
      return;
    }

    _processLeaveDetailsResponse(leaveDetails);
  }

  Future<void> _getLeaveConfigurationsEdit() async {
    var responseJson = await getLeaveConfigurations(
      widget.dateFrom.toString(),
      widget.dateTo.toString(),
      widget.leaveCode.toString(),
      ref.read(userContextProvider),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const NoServer()),
        );
        return null;
      },
    );

    if (responseJson == null) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => const NoServer()),
      );
      return;
    }

    if (responseJson is String) {
      showCustomAlertBox(
        context,
        title: responseJson,
        type: AlertType.error,
        onSecondaryPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );

      return;
    }

    // ✅ FIX: Read maps correctly
    final data = responseJson as Map<String, dynamic>;
    final appLst = data["appLst"] as List<dynamic>? ?? [];
    final subLst = data["subLst"] as List<dynamic>? ?? [];
    final canLst = data["canLst"] as List<dynamic>? ?? [];

    /*
    d = appLst.map((e) => LeaveConfigurationData.fromJson(e)).toList();
    dSubLst = subLst.map((e) => LeaveConfigurationData.fromJson(e)).toList();
    dCanLst = canLst.map((e) => LeaveConfigurationData.fromJson(e)).toList();
*/

    _processLeaveDetailsResponse(responseJson);
    setState(() {
      dateChanged = true;
    });
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

  void _showHalfDaySelector(LeaveConfigurationEditData item) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Select Half Day Type',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _updateHalfType('1', item),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              minimumSize: const Size(100, 40),
                            ),
                            child: Text('First Half (FH)'),
                          ),
                          SizedBox(width: 20.w),
                          ElevatedButton(
                            onPressed: () => _updateHalfType('2', item),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              minimumSize: const Size(100, 40),
                            ),
                            child: Text('Second Half (SH)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
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

  void _setHalfDay(LeaveConfigurationEditData targetItem) {
    setState(() {
      for (var item in leaveConfigData) {
        if (item.date == targetItem.date) {
          item.dayFlag = 'H';
          break;
        }
      }
    });

    leaveController.setDataEdit(leaveConfigData);
    _showHalfDaySelector(targetItem);
  }

  void _setFullDay(LeaveConfigurationEditData targetItem) {
    setState(() {
      for (var item in leaveConfigData) {
        if (item.date == targetItem.date) {
          item.dayFlag = 'F';
          break;
        }
      }
    });

    leaveController.setDataEdit(leaveConfigData);
    _setSandwichLogic();
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

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Configuration')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildDataTable(),
                        SizedBox(height: 20.h),
                        _buildSubmitButton(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: EdgeInsets.all(5.w),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HexColor("#F3F3F3"),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          horizontalMargin: 5,
          columnSpacing: 10,
          columns: [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(
                  color: HexColor("#212121"),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Full Day',
                style: TextStyle(
                  color: HexColor("#212121"),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Half Day',
                style: TextStyle(
                  color: HexColor("#212121"),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isLieuDayEnabled())
              DataColumn(
                label: Text(
                  'Lieu Day',
                  style: TextStyle(
                    color: HexColor("#212121"),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    return leaveConfigData.map((item) {
      return DataRow(
        color: MaterialStateColor.resolveWith((states) => HexColor('#F3F3F3')),
        cells: [
          _buildDateCell(item),
          _buildFullDayCell(item),
          _buildHalfDayCell(item),
          if (_isLieuDayEnabled()) _buildLieuDayCell(item),
        ],
      );
    }).toList();
  }

  DataCell _buildDateCell(LeaveConfigurationEditData item) {
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: HexColor(_getDateColor(item.dayType.toString())),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          item.date.toString(),
          style: TextStyle(fontSize: 13.sp, color: Colors.black),
        ),
      ),
    );
  }

  DataCell _buildFullDayCell(LeaveConfigurationEditData item) {
    return DataCell(
      Container(
        width: 20.h,
        height: 20.h,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: HexColor("#aee2f5"),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            item.dayFlag == "F"
                ? Container(
                  decoration: BoxDecoration(
                    color: HexColor("#10A0DB"),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
                : null,
      ),
      onTap: () {
        if (item.dayType == 3 || item.dayType == 4 || widget.fromAppTab) return;
        _setFullDay(item);
      },
    );
  }

  DataCell _buildHalfDayCell(LeaveConfigurationEditData item) {
    return DataCell(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.h,
            height: 20.h,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: HexColor("#aee2f5"),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                item.dayFlag == "H"
                    ? Container(
                      decoration: BoxDecoration(
                        color: HexColor("#10A0DB"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                    : null,
          ),
          if (item.dayFlag == "H")
            InkWell(
              onTap: () => _showHalfDaySelector(item),
              child: Text(
                item.halfType == "1" ? "F Half" : "S Half",
                style: TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: () {
        if (item.dayType == 3 || item.dayType == 4 || widget.fromAppTab) return;
        _setHalfDay(item);
      },
    );
  }

  DataCell _buildLieuDayCell(LeaveConfigurationEditData item) {
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child:
            widget.fromAppTab
                ? Text(
                  item.ludate ?? '',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black),
                )
                : DropdownButtonFormField<String>(
                  value: dateChanged ? null : (item.luslno ?? "").toString(),
                  hint: Text(
                    "-- Select --",
                    style: TextStyle(fontSize: 13.sp, color: Colors.black),
                  ),
                  items:
                      leaveConfigDataCanLst
                          .map(
                            (canItem) => DropdownMenuItem<String>(
                              value: canItem.iLsslno,
                              child: Text(
                                canItem.dLsdate.toString(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      item.lieuday = value;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.w,
                        color: HexColor('#0887A1'),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.w,
                        color: HexColor('#0887A1'),
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (widget.showSubmit == "") return const SizedBox();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: HexColor("#09A5D9"),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 40.w),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Go Back',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }*/
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
                              if (widget.showSubmit != "")
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
                  flex: 3,
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
                      'Full Day',
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
                      'Half Day',
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
                    flex: 3,
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
          Expanded(flex: 3, child: _buildEnhancedDateCell(item)),
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
            Expanded(flex: 3, child: _buildEnhancedLieuDayCell(item)),
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
    bool isDisabled =
        item.dayType == 3 || item.dayType == 4 || widget.fromAppTab;

    return GestureDetector(
      onTap: isDisabled ? null : () => _setFullDay(item),
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
    bool isDisabled =
        item.dayType == 3 || item.dayType == 4 || widget.fromAppTab;

    return GestureDetector(
      onTap: isDisabled ? null : () => _setHalfDay(item),
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
              onTap: () => _showHalfDaySelector(item),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: HexColor("#FF9800"),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.halfType == "1" ? "First Half" : "Second Half",
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
      child:
          widget.fromAppTab
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: HexColor("#F3F4F6"),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: HexColor("#E5E7EB")),
                ),
                child: Text(
                  item.ludate ?? '',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: HexColor("#374151"),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: HexColor("#E5E7EB")),
                ),
                child: DropdownButtonFormField<String>(
                  value: dateChanged ? null : (item.luslno ?? "").toString(),
                  hint: Text(
                    "-- Select --",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: HexColor("#9CA3AF"),
                    ),
                  ),
                  items:
                      leaveConfigDataCanLst
                          .map(
                            (canItem) => DropdownMenuItem<String>(
                              value: canItem.iLsslno,
                              child: Text(
                                canItem.dLsdate.toString(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: HexColor("#374151"),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      item.lieuday = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  dropdownColor: Colors.white,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: HexColor("#9CA3AF"),
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
      final responseJson = await Dio().post(
        "${userContext.baseUrl}/api/Leave/CalculateLeave",
        data: {
          "suconn": ref.watch(userContextProvider).companyConnection,
          "emcode": ref.watch(userContextProvider).empCode,
          "dtfrm": dateFrom,
          "dtto": dateTo,
          "leavcode": leaveType,
        },
        options: dioHeader(token: ref.watch(userContextProvider).jwtToken),
      );

      return responseJson.data['data'];
    } catch (e) {
      return null;
    }
  }
}
