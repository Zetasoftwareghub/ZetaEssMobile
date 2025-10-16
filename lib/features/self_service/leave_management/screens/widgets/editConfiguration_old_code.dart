import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';

import '../../../../../core/api_constants/dio_headers.dart';
import '../../../../../core/common/no_server_screen.dart';
import '../../../../../core/providers/userContext_provider.dart';
import '../../controller/old_hrms_configuration_stuffs.dart';
import '../../models/leave_model.dart';
import 'package:easy_localization/easy_localization.dart' as local;

import '../helper/sandwich_helper.dart';

class LeaveConfigurationEdit extends ConsumerStatefulWidget {
  String? dateFrom;
  String? dateTo;
  String? leaveCode;
  bool isResumptionLeave = false;
  bool? selectedSameValues;
  bool isLieuDay;
  String lssNo;
  final LeaveTypeModel? selectedLeaveType;
  final LeaveTypeModel? initialLeaveType;
  List<LeaveConfigurationEditData> data = [];
  List<LeaveConfigurationEditData> dataSub = [];
  List<LeaveConfigurationEditData> dataCan = [];

  LeaveConfigurationEdit({
    Key? key,
    this.dateFrom,
    this.isResumptionLeave = false,
    required this.isLieuDay,
    this.dateTo,
    this.leaveCode,
    required this.selectedSameValues,
    required this.data,
    required this.dataSub,
    required this.dataCan,
    required this.lssNo,
    this.selectedLeaveType,
    this.initialLeaveType,
  }) : super(key: key);

  @override
  ConsumerState<LeaveConfigurationEdit> createState() =>
      _LeaveConfigurationState();
}

class _LeaveConfigurationState extends ConsumerState<LeaveConfigurationEdit> {
  List leaveTypes = [
    LeaveTypeModel(leaveType: "Full Day", leaveTypeId: "1"),
    LeaveTypeModel(leaveType: "Half Day", leaveTypeId: "2"),
    LeaveTypeModel(leaveType: "Compensatory", leaveTypeId: "3"),
  ];

  String? selectedValue;
  bool datechanged = false;
  List<LeaveConfigurationEditData> leaveConfigData = [];
  List<LeaveConfigurationEditData> leaveConfigDataSubLst = [];
  List<LeaveConfigurationEditData> leaveConfigDataCanLst = [];

  final LeaveConfigurationController leaveController = Get.put(
    LeaveConfigurationController(),
  );
  List<LeaveConfigurationEditData> editLieuDropDown = [];
  bool configurationsFetched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLeaveType != widget.selectedLeaveType &&
        widget.selectedLeaveType != null) {
      Future.microtask(() => getDataToDropDown());
    }
    if (widget.data.isNotEmpty || widget.selectedLeaveType == null) {
      configurationsFetched = true;

      setState(() {
        leaveController.setDataEdit(widget.data);
        leaveConfigData = widget.data;
        leaveConfigDataSubLst = widget.dataSub;
        leaveConfigDataCanLst = widget.dataCan;
        if (widget.initialLeaveType != widget.selectedLeaveType) {
          LeaveConfigurationEditData select = LeaveConfigurationEditData(
            dayType: 0,
            dLsdate: "-- select --",
            lieuday: "null",
          );
          var blnk =
              leaveConfigDataCanLst
                  .where((element) => element.dLsdate == "-- select --")
                  .toList();
          if (blnk.isEmpty) {
            leaveConfigDataCanLst.add(select);
          }
        }
      });
      Future.microtask(() => setSandwich());
    } else {
      Future.microtask(() {
        if (!configurationsFetched) _getConfigurations();
      });
    }
  }

  getDataToDropDown() async {
    try {
      var responseJson = await getLeaveConfigurations(
        widget.dateFrom.toString(),
        widget.dateTo.toString(),
        widget.leaveCode.toString(),
        ref.watch(userContextProvider),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const NoServer()),
          );
        },
      );

      if (responseJson == null) {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const NoServer()),
        );
      }

      final canList = responseJson['canLst'] as List;
      for (var i in canList) {
        // for (var item in i["canLst"]) {
        editLieuDropDown.add(LeaveConfigurationEditData.fromJson(i));
        // }
      }
      setState(() {
        leaveConfigDataCanLst = editLieuDropDown;
      });
    } catch (e) {
      print(e.toString());
      print('e.toString()');
    }
  }

  void setSandwich() async {
    if (!mounted) return;

    // Convert LeaveConfigurationEditData to LeaveConfigurationData
    List<LeaveConfigurationData> d =
        leaveConfigData
            .map(
              (editData) => LeaveConfigurationData(
                date: editData.date,
                dayType: editData.dayType ?? 0,
                dayFlag: editData.dayFlag ?? '',
                halfType: editData.halfType ?? '',
                // Add other necessary mappings
              ),
            )
            .toList();

    if (d.isEmpty) return;

    // Get leave configuration using the helper
    final userContext = ref.read(userContextProvider);
    final responseJson = await LeaveApiHelper.executeWithTimeout(
      () => getLeaveConfigurations(
        widget.dateFrom.toString(),
        widget.dateTo.toString(),
        widget.leaveCode.toString(),
        userContext,
      ),
      'getLeaveConfigurations',
      context,
    );

    final leaveConfig = LeaveApiHelper.extractLeaveConfig(responseJson);
    if (leaveConfig == null) return;

    // Extract configuration values with defaults
    var includeOff = leaveConfig.includeOff ?? LeaveConstants.no;
    var includeHoliday = leaveConfig.includeHolliday ?? LeaveConstants.no;
    var glapho = leaveConfig.glapho ?? LeaveConstants.no;
    var ltaphl = leaveConfig.ltaphl ?? LeaveConstants.no;

    // Check preceding and trailing conditions
    var trailInclude = false;
    var precInclued = false;

    if (d.first.dayType == LeaveConstants.weekOff ||
        d.first.dayType == LeaveConstants.holiday) {
      trailInclude = await LeaveConditionChecker.checkPrecedingTrailing(
        d,
        widget.leaveCode.toString(),
        true,
        context,
        ref,
      );
    }

    if (d.last.dayType == LeaveConstants.weekOff ||
        d.last.dayType == LeaveConstants.holiday) {
      precInclued = await LeaveConditionChecker.checkPrecedingTrailing(
        d,
        widget.leaveCode.toString(),
        false,
        context,
        ref,
      );
    }

    // Parse date range
    DateTime fromDate = DateFormat(
      LeaveConstants.dateFormat,
    ).parse(d.first.date ?? '');
    DateTime toDate = DateFormat(
      LeaveConstants.dateFormat,
    ).parse(d.last.date ?? '');

    DateTime startDate = fromDate;
    DateTime endDate = toDate;

    // Process each day in the range
    while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
      var startDateStr = DateFormat(
        LeaveConstants.dateFormat,
      ).format(startDate);
      var itemLst = d.where((element) => element.date == startDateStr);

      if (itemLst.isNotEmpty) {
        var item = itemLst.first;
        await LeaveFlagProcessor.processDayConfiguration(
          d,
          item,
          startDateStr,
          includeOff,
          includeHoliday,
          glapho,
          ltaphl,
          fromDate,
          toDate,
          GapLeaveConditions(preceding: precInclued, trailing: trailInclude),
        );
      }

      startDate = startDate.add(const Duration(days: 1));
    }

    // Convert back to LeaveConfigurationEditData and update UI
    if (mounted) {
      List<LeaveConfigurationEditData> updatedEditData = [];
      for (int i = 0; i < leaveConfigData.length; i++) {
        var editItem = leaveConfigData[i];
        var processedItem = d.firstWhere(
          (element) => element.date == editItem.date,
          orElse: () => LeaveConfigurationData(dayType: 1), // Provide default
        );

        // Update the edit item with processed values
        editItem.dayFlag = processedItem.dayFlag;
        updatedEditData.add(editItem);
      }

      setState(() {
        leaveConfigData = updatedEditData;
      });
      leaveController.setDataEdit(updatedEditData);
    }
  }

  void _getConfigurations() async {
    List<LeaveConfigurationEditData> d = [];
    List<LeaveConfigurationEditData> dsub = [];
    List<LeaveConfigurationEditData> dcan = [];

    var responseJson = await getLeaveConfigurations(
      widget.dateFrom.toString(),
      widget.dateTo.toString(),
      widget.leaveCode.toString(),
      ref.watch(userContextProvider),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const NoServer()),
        );
      },
    );
    for (var i in responseJson) {
      for (var item in i["appLst"]) {
        d.add(LeaveConfigurationEditData.fromJson(item));
      }
      for (var item in i["subLst"]) {
        dsub.add(LeaveConfigurationEditData.fromJson(item));
      }
      for (var item in i["canLst"]) {
        dcan.add(LeaveConfigurationEditData.fromJson(item));
      }
    }

    setState(() {
      leaveConfigData = d;
      leaveConfigDataSubLst = dsub;
      leaveConfigDataCanLst = dcan;
      datechanged = true;
    });

    leaveController.setDataEdit(d);
    setState(() {});

    setSandwich();
  }

  void _halfType(String type, LeaveConfigurationEditData t) {
    List<LeaveConfigurationEditData> tmp = leaveConfigData;
    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i].date == t.date) {
        tmp[i].halfType = type.toString();
      }
    }

    setState(() {
      leaveConfigData = tmp;
    });
    leaveController.setDataEdit(tmp);
    setSandwich();
    Navigator.pop(context);
  }

  void _halfDay(LeaveConfigurationEditData t) {
    List<LeaveConfigurationEditData> tmp = leaveConfigData;
    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i].date == t.date) {
        tmp[i].dayFlag = 'H';
      }
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      local.tr('Select Half DayType'),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0.h),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _halfType('1', t);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                shadowColor: Colors.greenAccent,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                minimumSize: const Size(100, 40), //////// HERE
                              ),
                              child: Text('firstHalf FH'),
                            ),
                            SizedBox(width: 20.w),
                            ElevatedButton(
                              onPressed: () {
                                _halfType('2', t);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                shadowColor: Colors.greenAccent,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                minimumSize: const Size(100, 40), //////// HERE
                              ),
                              child: Text('secondHalfSH'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                child: Text(local.tr('Close')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    setState(() {
      leaveConfigData = tmp;
    });
    leaveController.setDataEdit(tmp);
  }

  void _fullDay(LeaveConfigurationEditData t) {
    List<LeaveConfigurationEditData> tmp = leaveConfigData;

    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i].date == t.date) {
        tmp[i].dayFlag = 'F';
      }
    }

    setState(() {
      leaveConfigData = tmp;
    });
    leaveController.setDataEdit(tmp);
    setSandwich();
  }

  void _save() {
    if (widget.isLieuDay) {
      if (leaveConfigData.isEmpty ||
          leaveConfigData.any(
            (e) =>
                e.lieuday == null ||
                e.lieuday == "" ||
                e.lieuday == "null" ||
                e.lieuday == "0" ||
                e.lieuday == "-- select --",
          )) {
        showCustomAlertBox(context, title: 'Please select lieu day!');
        return;
      }

      if (validateLieuDayConfig() == true) {
        return;
      }
    }

    List<LeaveConfigurationEditData> tmp = leaveConfigData;
    double leaves = 0;
    for (var i = 0; i < tmp.length; i++) {
      if (!widget.isLieuDay) {
        tmp[i].lieuday = '0';
      }
      tmp[i].leaveCode = widget.leaveCode;

      if (tmp[i].dayFlag == 'F') {
        leaves = leaves + 1;
      } else if (tmp[i].dayFlag == 'H') {
        leaves = leaves + .5;
      }
    }

    setState(() {
      leaveConfigData = tmp;
    });

    leaveController.setDataEdit(tmp);
    leaveController.isSubmitted = true;
    String n = leaves.toString();
    leaveController.setTotalLeaves(n);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 30);

    return Scaffold(
      appBar: AppBar(title: Text('Leave Configuration Edit')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: itemHeight,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.all(5.w),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HexColor("#F3F3F3"),
                        border: Border.all(color: HexColor("#F3F3F3")),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: HexColor("#F3F3F3")),
                        child: SingleChildScrollView(
                          child: DataTable(
                            horizontalMargin: 5,
                            columnSpacing: 10,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Date',
                                    style: TextStyle(
                                      color: HexColor("#212121"),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Full\nDay',
                                    style: TextStyle(
                                      color: HexColor("#212121"),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Half\nDay',
                                    style: TextStyle(
                                      color: HexColor("#212121"),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Visibility(
                                  visible:
                                      (lieuDayValue()) == "Y" ? true : false,
                                  child: Expanded(
                                    child: Text(
                                      'Lieu Day',
                                      style: TextStyle(
                                        color: HexColor("#212121"),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: sDetails(leaveConfigData),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: HexColor("#09A5D9"),
                          padding: EdgeInsets.only(
                            top: 10.h,
                            bottom: 15.h,
                            left: 40.w,
                            right: 40.w,
                          ),
                        ),
                        onPressed: () => _save(),
                        child: Text(
                          local.tr(submitText),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getColor(String dayType) {
    if (dayType == "3") {
      return "#FF0000";
    } else if (dayType == "4") {
      return "#78DE95";
    }

    return "#ffffff";
  }

  String? lieuDayValue() {
    String? val = "N";
    if (leaveConfigDataSubLst.isNotEmpty) {
      // val = leaveConfigDataSubLst[0].ltlieu ?? "N";
      val =
          widget.selectedLeaveType?.ltlieu ??
          leaveConfigDataSubLst.first.ltlieu;
    }
    return val;
  }

  List<DataRow> sDetails(List<LeaveConfigurationEditData> s) {
    List<DataRow> l = [];
    for (var i in s) {
      l.add(
        DataRow(
          color: MaterialStateColor.resolveWith((states) {
            return HexColor('#F3F3F3');
          }),
          cells: [
            DataCell(
              Container(
                padding: EdgeInsets.only(
                  top: 8.h,
                  bottom: 8.h,
                  left: 10.w,
                  right: 10.w,
                ),
                decoration: BoxDecoration(
                  color: HexColor(_getColor(i.dayType.toString())),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  i.date.toString(),
                  style: TextStyle(fontSize: 13.sp, color: HexColor("#000000")),
                ),
              ),
            ),
            DataCell(
              Container(
                width: 20.h,
                height: 20.h,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: HexColor("#aee2f5"),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    i.dayFlag == "F"
                        ? Container(
                          width: 10.h,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: HexColor("#10A0DB"),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                        : const Text(""),
              ),
              onTap: () {
                if (widget.isResumptionLeave) return;

                if (i.dayType == 3 || i.dayType == 4) {
                  return;
                }
                _fullDay(i);
              },
            ),
            DataCell(
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: i.dayFlag == "H" ? 10 : 10),
                      child: Container(
                        width: 20.h,
                        height: 20.h,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: HexColor("#aee2f5"),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            i.dayFlag == "H"
                                ? Container(
                                  width: 10.h,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: HexColor("#10A0DB"),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                                : const Text(""),
                      ),
                    ),
                    i.dayFlag == "H"
                        ? InkWell(
                          onTap: () {
                            if (widget.isResumptionLeave) return;

                            _halfDay(i);
                          },
                          child: Text(
                            i.halfType == "1" ? 'FH' : 'SH',
                            style: TextStyle(fontSize: 10),
                          ),
                        )
                        : Text("", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              onTap: () {
                if (widget.isResumptionLeave) return;

                if (i.dayType == 3 || i.dayType == 4) {
                  return;
                }

                _halfDay(i);
              },
            ),
            DataCell(
              widget.isLieuDay && editLieuDropDown.isNotEmpty
                  ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
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
                      hint: Text(
                        "-- Select --",
                        style: AppTextStyles.smallFont(),
                      ),

                      items:
                          leaveConfigDataCanLst.map((item) {
                            return DropdownMenuItem(
                              value: item.iLsslno,
                              child: Text(
                                item.dLsdate.toString(),
                                style: AppTextStyles.smallFont(),
                              ),
                            );
                          }).toList(),
                      value:
                          (i.luslno == null || i.luslno == 0)
                              ? null
                              : i.luslno.toString(),
                      onChanged: (value) {
                        setState(() {
                          i.lieuday = value;
                        });
                      },
                      //itemHeight: 40.h,
                    ),
                  )
                  : const Text(""),
            ),
          ],
        ),
      );
    }

    return l;
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

  Future getLeaveDetailsByDate(String date, String ltcode) async {
    final responseJson = await Dio().post(
      "${ref.watch(userContextProvider).baseUrl}/api/Leave/GetLeaveDetailsByDate",
      data: {
        "suconn": ref.watch(userContextProvider).companyConnection,
        "date": date,
        "emcode": ref.watch(userContextProvider).empCode,
        "ltcode": ltcode,
      },
      options: dioHeader(token: ref.watch(userContextProvider).jwtToken),
    );
    return responseJson.data['data']['subLst'];
  }

  bool validateLieuDayConfig() {
    bool isInvalidConfig = false;
    const String errorMessage = 'Invalid LieuDay Configuration';

    // get items with valid LieuDay
    var validLieuDayItems = leaveConfigData.where(
      (item) => item.lieuday != "null",
    );

    // unique LieuDay IDs
    var distinctLieuDayIds =
        validLieuDayItems.map((item) => item.lieuday).toSet().toList();

    for (int i = 0; i < distinctLieuDayIds.length; i++) {
      var currentLieuDayId = distinctLieuDayIds[i].toString();

      // matching CanLst items
      var matchingCanLstItems =
          widget.dataCan
              .where(
                (item) => item.iLsslno == currentLieuDayId,
              ) //TODO i have doubt here !
              .toList();

      if (matchingCanLstItems.isNotEmpty) {
        var matchedItem = matchingCanLstItems.first;
        double availableLieuDayBalance = 0.0;
        List<String> parts = (matchedItem.lsnote ?? '').split('-');
        // get balance based on condition
        if (widget.dataCan.isEmpty &&
            widget.initialLeaveType != widget.selectedLeaveType) {
          List<String> parts = (matchedItem.dLsdate ?? '').split(' ');
          var numberString = parts[1].replaceAll('(', '').replaceAll(')', '');
          availableLieuDayBalance = double.parse(numberString);
        } else {
          availableLieuDayBalance = double.parse(parts[1]);
        }

        // count total applied days
        double totalAppliedLieuDays = 0.0;
        for (var item in leaveConfigData) {
          if (item.lieuday == currentLieuDayId) {
            if (item.dayFlag == "H") {
              totalAppliedLieuDays += 0.5;
            } else if (item.dayFlag == "F") {
              totalAppliedLieuDays += 1.0;
            }
          }
        }

        // compare applied vs balance
        if (totalAppliedLieuDays > availableLieuDayBalance) {
          isInvalidConfig = true;
          break;
        }
      }
    }

    // show alert if invalid
    if (isInvalidConfig) {
      showCustomAlertBox(context, title: errorMessage);
    }

    return isInvalidConfig;
  }
}
