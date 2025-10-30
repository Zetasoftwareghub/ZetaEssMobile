import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/features/self_service/leave_management/models/leave_model.dart';

import '../../../../../core/api_constants/dio_headers.dart';
import '../../../../../core/common/no_server_screen.dart';
import '../../controller/old_hrms_configuration_stuffs.dart';
import '../../providers/leave_providers.dart';
import '../helper/sandwich_helper.dart';

class LeaveConfiguration extends ConsumerStatefulWidget {
  String? dateFrom;
  String? dateTo;
  String? leaveCode;
  // String? showSubmit; TODO eth view  nte case ann thonnunu !
  final bool showDetail;
  final bool isResumptionLeave;

  LeaveConfiguration({
    Key? key,
    this.dateFrom,
    this.dateTo,
    this.leaveCode,
    this.showDetail = false,
    this.isResumptionLeave = false,
    // this.showSubmit,
  }) : super(key: key);

  @override
  ConsumerState<LeaveConfiguration> createState() =>
      _OLDLeaveConfigurationState();
}

class _OLDLeaveConfigurationState extends ConsumerState<LeaveConfiguration> {
  bool isLoading = false;
  //TODO new sandwich claude
  void setSandwich() async {
    if (!mounted) return;

    List<LeaveConfigurationData> d = leaveConfigData;

    if (d.isEmpty) return;

    // Get leave configuration
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
    setState(() => isLoading = true);

    // Extract configuration values with defaults
    var includeOff = leaveConfig.includeOff ?? LeaveConstants.no;
    var includeHoliday = leaveConfig.includeHolliday ?? LeaveConstants.no;
    var glapho = leaveConfig.glapho ?? LeaveConstants.no; //None
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
          glapho, //None
          ltaphl,
          fromDate,
          toDate,
          GapLeaveConditions(preceding: precInclued, trailing: trailInclude),
        );
      }

      startDate = startDate.add(const Duration(days: 1));
    }

    // Update UI
    if (mounted) {
      setState(() {
        leaveConfigData = d;
        isLoading = false;
      });
      leaveController.setData(d);
    }
  }

  void _getConfigurations() async {
    setState(() => isLoading = true);
    List<LeaveConfigurationData> d = [];
    List<LeaveConfigurationData> dSubLst = [];
    List<LeaveConfigurationData> dCanLst = [];

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
    d = appLst.map((e) => LeaveConfigurationData.fromJson(e)).toList();
    dSubLst = subLst.map((e) => LeaveConfigurationData.fromJson(e)).toList();
    dCanLst = canLst.map((e) => LeaveConfigurationData.fromJson(e)).toList();

    setState(() {
      leaveConfigData = d;
      leaveConfigDataSubLst = dSubLst;
      leaveConfigDataCanLst = dCanLst;

      leaveConfigDataCanLst.add(
        LeaveConfigurationData(
          dayType: 0,
          dLsdate: "-- select --",
          lieuday: "null",
        ),
      );
    });

    try {
      for (var element in d) {
        final match = leaveController.leaveConfigurationData.where(
          (x) => x.dLsdate == element.dLsdate,
        );
        if (match.isNotEmpty) {
          final item = match.first;
          print(item?.halfType);

          element.lieuday = item.lieuday;
          element.halfType = item.halfType;
          element.dayType = item.dayType;
          element.dayFlag = item.dayFlag;
        }
      }
    } catch (e) {
      print("Mapping error: $e");
    }

    leaveController.setData(d);
    setSandwich();
  }

  List leaveTypes = [
    LeaveTypeModel(leaveType: "Full Day", leaveTypeId: "1"),
    LeaveTypeModel(leaveType: "Half Day", leaveTypeId: "2"),
    LeaveTypeModel(leaveType: "Compensatory", leaveTypeId: "3"),
  ];

  String? selectedValue;
  List<LeaveConfigurationData> leaveConfigData = [];
  List<LeaveConfigurationData> leaveConfigDataSubLst = [];
  List<LeaveConfigurationData> leaveConfigDataCanLst = [];

  @override
  void initState() {
    super.initState();
    // if (widget.data.isNotEmpty) {
    // } else {
    Future.delayed(Duration.zero, () => _getConfigurations());
    // }

    leaveController.setBlankLieu(false);
  }

  void _halfType(String type, LeaveConfigurationData t) async {
    List<LeaveConfigurationData> tmp = leaveConfigData;
    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i].date == t.date) {
        tmp[i].halfType = type.toString();
        tmp[i].dayFlag = 'H';
      }
    }

    setState(() {
      leaveConfigData = tmp;
    });
    leaveController.setData(tmp);
    Navigator.pop(context);

    setSandwich();
  }

  void _halfDay(LeaveConfigurationData t) {
    List<LeaveConfigurationData> tmp = leaveConfigData;
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
                    Text('Select Half Day Type'.tr()),
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
                              child: Text('First Half FH'.tr()),
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
                              child: Text('Second Half SH'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                child: Text('Close'.tr()),
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
    leaveController.setData(tmp);
  }

  void _fullDay(LeaveConfigurationData t) async {
    List<LeaveConfigurationData> tmp = leaveConfigData;
    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i].date == t.date) {
        tmp[i].dayFlag = 'F';
      }
    }

    setState(() {
      tmp.sort((b, a) => (b.date ?? '').compareTo(a.date ?? ''));
      leaveConfigData = tmp;
    });
    leaveController.setData(tmp);
    setSandwich();
  }

  bool validateConfig() {
    bool result = false;
    String msg = 'invalidLieuDayConfiguration';

    var items = leaveConfigData.where((element) => element.lieuday != "null");
    var distinctItems = items.map((i) => i.lieuday).toSet().toList();

    for (int i = 0; i <= (distinctItems.length - 1); i++) {
      var lieuday = distinctItems[i].toString();
      var lstItems = leaveConfigDataCanLst.where(
        (element) => element.iLsslno == lieuday,
      );
      if (lstItems.isNotEmpty) {
        var lstItem = lstItems.first;

        var arr = (lstItem.dLsdate ?? '').split('(');
        var arr1 = arr[1].split(')');
        var lieuBalance = double.parse(arr1[0]);

        var totalDateCount = 0.0;
        for (var element in leaveConfigData) {
          if (element.dayFlag == "H" && element.lieuday == lieuday) {
            totalDateCount = totalDateCount + 0.50;
          } else if (element.dayFlag == "F" && element.lieuday == lieuday) {
            totalDateCount = totalDateCount + 1;
          }
        }

        if (totalDateCount > lieuBalance) {
          result = true;
          msg = "The selected lieu day should not be less than the leave day";
          break;
        }
      }
    }

    if (result == true) {
      showCustomAlertBox(context, title: msg, type: AlertType.warning);
    }
    return result;
  }

  bool validateConfigBlank() {
    bool result = false;

    var l = lieuDayValue();
    if (l == "Y") {
      for (int i = 0; i <= (leaveConfigData.length - 1); i++) {
        String lVal = leaveConfigData[i].lieuday ?? '';
        if (lVal == '' || lVal == "null") {
          result = true;
          break;
        }
      }
    }

    return result;
  }

  String lieuDayValue() {
    String val = "N";
    if ((leaveConfigDataSubLst.length) > 0) {
      val = leaveConfigDataSubLst[0].isLieuDay ?? "N";
    }
    return val;
  }

  void _save() {
    if ((leaveConfigDataSubLst[0].isLieuDay ?? 'N') == "Y") {
      if (leaveConfigData.any(
        (e) =>
            e.lieuday == null ||
            e.lieuday == "" ||
            e.lieuday == "null" ||
            e.lieuday == "0",
      )) {
        showCustomAlertBox(
          context,
          title: 'Please select lieu day!',
          type: AlertType.warning,
        );
        return;
      }
    }
    if (validateConfig() == true) {
      return;
    }
    if (validateConfigBlank() == true) {
      leaveController.setBlankLieu(true);
    }

    List<LeaveConfigurationData> tmp = leaveConfigData;
    double leaves = 0;
    for (var i = 0; i < tmp.length; i++) {
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
    leaveController.setData(tmp);
    String n = leaves.toString();
    ref.watch(totalLeaveDaysStateProvider.notifier).state = n;
    leaveController.setTotalLeaves(n);

    leaveController.isSubmitted = true;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 30);
    return Scaffold(
      appBar: AppBar(title: Text('Leave Configuration')),
      body:
          isLoading
              ? const Loader()
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    shadowColor: HexColor("#F1F1F1").withOpacity(.9),
                    elevation: 15.0,
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
                                  border: Border.all(
                                    color: HexColor("#F3F3F3"),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Theme(
                                  data: Theme.of(
                                    context,
                                  ).copyWith(dividerColor: HexColor("#F3F3F3")),
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      dataRowMinHeight: 20,
                                      dataRowMaxHeight: 50,
                                      horizontalMargin: 5,
                                      columnSpacing: 10,
                                      columns: <DataColumn>[
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'date'.tr(),
                                              style: AppTextStyles.smallFont(),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Full\nday',
                                              style: AppTextStyles.smallFont(),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Half\nday',
                                              style: AppTextStyles.smallFont(),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Visibility(
                                            visible:
                                                (lieuDayValue()) == "Y"
                                                    ? true
                                                    : false,
                                            child: Expanded(
                                              child: Text(
                                                'Lieu Day'.tr(),
                                                style:
                                                    AppTextStyles.mediumFont(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: leaveConfigDetailRow(
                                        leaveConfigData,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Center(
                                child:
                                    // widget.showSubmit == ""
                                    true
                                        ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: const StadiumBorder(),
                                            backgroundColor: HexColor(
                                              "#09A5D9",
                                            ),
                                            padding: EdgeInsets.only(
                                              top: 10.h,
                                              bottom: 15.h,
                                              left: 40.w,
                                              right: 40.w,
                                            ),
                                          ),
                                          onPressed: () {
                                            if (widget.showDetail) {
                                              Navigator.pop(context);
                                              return;
                                            }
                                            _save();
                                          },
                                          child: Text(
                                            widget.showDetail
                                                ? 'Go back'
                                                : 'submit'.tr(),
                                            style: AppTextStyles.mediumFont(),
                                          ),
                                        )
                                        : const Text(""),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
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
    } else if (dayType == "2") {
      return "#B0B0B0";
    }

    return "#ffffff";
  }

  List<DataRow> leaveConfigDetailRow(
    List<LeaveConfigurationData> leaveConfigList,
  ) {
    List<DataRow> ConfigList = [];
    int index = 0;
    for (var i in leaveConfigList) {
      var item = leaveController.leaveConfigurationData.where(
        (x) => x.dLsdate == i.dLsdate,
      );
      ConfigList.add(
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
                  style: AppTextStyles.smallFont(),
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

                if (widget.showDetail) {
                  return;
                }
                if (i.dayType == 3 || i.dayType == 4 || i.dayType == 2) {
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
                      padding: EdgeInsets.only(top: i.dayFlag == "H" ? 10 : 0),
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

                            if (widget.showDetail) {
                              return;
                            }
                            _halfDay(i);
                          },
                          child: Text(
                            (i.halfType ?? '').isEmpty || i.halfType == "1"
                                ? 'FH'
                                : 'SH',
                            style: AppTextStyles.smallFont(),
                          ),
                        )
                        : Visibility(
                          visible: false,
                          child: Text("", style: AppTextStyles.smallFont()),
                        ),
                  ],
                ),
              ),
              onTap: () {
                if (widget.isResumptionLeave) return;
                if (widget.showDetail) {
                  return;
                }
                if (i.dayType == 3 || i.dayType == 4 || i.dayType == 2) {
                  return;
                }

                _halfDay(i);
              },
            ),
            DataCell(
              (leaveConfigDataSubLst[0].isLieuDay ?? 'N') == "Y"
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
                          leaveConfigDataCanLst
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.iLsslno,
                                  child: Text(
                                    item.dLsdate.toString(),
                                    style: AppTextStyles.smallFont(),
                                  ),
                                ),
                              )
                              .toList(),
                      value:
                          (item.first.lieuday == null ||
                                  item.first.lieuday == "" ||
                                  item.first.lieuday?.toLowerCase() == "null")
                              ? null
                              : item.first.lieuday,
                      // value: i.lieuday,
                      onChanged: (value) {
                        setState(() {
                          i.lieuday = value.toString();
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

      index++;
    }

    return ConfigList;
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
      print(responseJson.data['data']);
      return responseJson.data['data'];
    } catch (e) {
      return null;
    }
  }
}
