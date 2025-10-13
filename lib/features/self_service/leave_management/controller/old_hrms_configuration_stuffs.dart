import 'package:get/get.dart';

final LeaveConfigurationController leaveController = Get.put(
  LeaveConfigurationController(),
);

class LeaveConfigurationController {
  final leaveConfigurationData = <LeaveConfigurationData>[].obs;
  final leaveConfigurationEditData = <LeaveConfigurationEditData>[].obs;
  final totalLeaves = "".obs;
  bool isSubmitted = false;
  bool isBlankLieu = false;

  void setData(List<LeaveConfigurationData> data) {
    leaveConfigurationData.value = data;
  }

  void setDataEdit(var data) {
    leaveConfigurationEditData.value = data;
  }

  void setTotalLeaves(var total) {
    totalLeaves.value = total;
  }

  void setBlankLieu(var data) {
    isBlankLieu = data;
  }
}

class LeaveConfigDate {
  int? iLsslno;
  String? dLsdate;
  int? iEmcode;
  int? ltCode;
  String? cLsflag;
  String? halfDayType;
  int? dayType;
  String? cLsstat;

  LeaveConfigDate({
    this.iLsslno,
    this.dLsdate,
    this.iEmcode,
    this.ltCode,
    this.cLsflag,
    this.halfDayType,
    this.dayType,
    this.cLsstat,
  });

  factory LeaveConfigDate.fromJson(Map<String, dynamic> json) {
    return LeaveConfigDate(
      iLsslno: json['iLsslno'],
      dLsdate: json['dLsdate'],
      iEmcode: json['iEmcode'],
      ltCode: json['ltCode'],
      cLsflag: json['cLsflag'],
      halfDayType: json['halfDayType'],
      dayType: json['dayType'],
      cLsstat: json['cLsstat'],
    );
  }

  Map toJson() => {
    'ILsslno': iLsslno,
    'dLsdate': dLsdate,
    'iEmcode': iEmcode,
    'LtCode': ltCode,
    'cLsflag': cLsflag,
    'halfDayType': halfDayType,
    'dayType': dayType,
    'cLsstat': cLsstat,
  };
}

class LeaveConfigurationData {
  String? date;
  String? leaveType;
  String? dayFlag;
  String? paidAbsent;
  String? unpaidAbs;
  int arOrder = 0;
  int arLuslno = 0;
  String? halfType;
  String? leaveCode;
  int dayType = 1;
  String? includeHolliday;
  String? includeOff;
  String? isLieuDay;
  String? dLsdate;
  String? iLsslno;
  String? lieuday;
  String? glapho;
  String? ltaphl;

  LeaveConfigurationData({
    this.date,
    this.leaveType,
    this.dayFlag,
    this.paidAbsent,
    this.unpaidAbs,
    this.halfType,
    required this.dayType,
    this.includeHolliday,
    this.includeOff,
    this.isLieuDay,
    this.dLsdate,
    this.iLsslno,
    this.lieuday,
    this.glapho,
    this.ltaphl,
  });

  factory LeaveConfigurationData.fromJson(Map<String, dynamic> json) {
    return LeaveConfigurationData(
      date: json['dLsdate']?.toString() ?? '', // or dLsdate for approved list
      leaveType: json['cLtpType']?.toString() ?? '',
      dayFlag: "F",
      // json['cLsflag'] == null ? 'F' : json['cLsflag']?.toString() ?? '',
      paidAbsent: json['cLtpType'] == '1' ? 'Y' : 'N',
      unpaidAbs: json['cLtpType'] == '1' ? 'N' : 'Y',
      halfType: json['halfDayType']?.toString() ?? '',
      dayType:
          json['dayType'] != null
              ? int.tryParse(json['dayType'].toString()) ?? 0
              : 0,
      includeHolliday: json['includeHolliday']?.toString() ?? '',
      includeOff: json['includeOff']?.toString() ?? '',
      isLieuDay: json['lsnote']?.toString() ?? '',
      dLsdate: json['dLsdate']?.toString() ?? json['dLsrdtf']?.toString() ?? '',

      //TODO is this needed?
      iLsslno: json['iLsslno']?.toString() ?? json['ILsslno']?.toString() ?? '',
      lieuday: json['ltlieu']?.toString() ?? '',
      glapho: json['glapho']?.toString() ?? '',
      ltaphl: json['ltaphl']?.toString() ?? '',
    );
  }

  Map toJson() => {
    'leaveDate': date,
    'dayType': leaveType,
    'leaveCode': leaveCode,
    'dayFlag': (dayFlag ?? '').isEmpty ? 'F' : dayFlag,
    'paidAbsent': paidAbsent,
    'unpaidAbs': unpaidAbs,
    'ArOrder': "0",
    'ArLuslno': "0",
    'halfType': (halfType ?? '').isEmpty ? '1' : halfType,
    // 'halfType': halfType,
    'Lsnote': isLieuDay,
    'dLsdate': dLsdate,
    'ILsslno': iLsslno,
    'lieuDay': lieuday,
    'Glapho': glapho,
    'ltaphl': ltaphl,
  };
}

class LeaveConfigurationEditData {
  String? date;
  String? leaveType;
  String? dayFlag;
  String? paidAbsent;
  String? unpaidAbs;
  int arOrder = 0;
  int arLuslno = 0;
  String? halfType;
  String? leaveCode;
  int dayType = 1;
  String? includeHolliday;
  String? includeOff;
  String? leaveName;
  String? lsnote;
  String? dLsdate;
  String? iLsslno;
  String? lieuday;
  String? ltlieu;
  int? luslno;
  String? ludate;
  String? glapho;
  String? ltaphl, lscont, dLsrdtt, dLsrdtf, llsrndy;

  LeaveConfigurationEditData({
    this.date,
    this.leaveType,
    this.dayFlag,
    this.paidAbsent,
    this.unpaidAbs,
    this.halfType,
    required this.dayType,
    this.includeHolliday,
    this.includeOff,
    this.leaveName,
    this.lsnote,
    this.dLsdate,
    this.iLsslno,
    this.lieuday,
    this.ltlieu,
    this.luslno,
    this.ludate,
    this.glapho,
    this.ltaphl,
    this.dLsrdtt,
    this.dLsrdtf,
    this.lscont,
    this.leaveCode,
    this.llsrndy,
  });
  factory LeaveConfigurationEditData.fromJson(Map<String, dynamic> json) {
    return LeaveConfigurationEditData(
      lscont: json['lscont']?.toString() ?? '',
      leaveCode: json['ltCode']?.toString() ?? '',
      dLsrdtf: json['dLsrdtf']?.toString() ?? '',
      dLsrdtt: json['dLsrdtt']?.toString() ?? '',
      date: json['dLsdate']?.toString() ?? '',
      // leaveType: json['cLtpType']?.toString() ?? '',
      leaveType: json['dayType']?.toString() ?? '',
      dayFlag:
          json['cLsflag'] == null ? 'F' : json['cLsflag']?.toString() ?? '',
      paidAbsent: json['cLtpType'] == '1' ? 'Y' : 'N',
      unpaidAbs: json['cLtpType'] == '1' ? 'N' : 'Y',
      halfType: json['halfDayType']?.toString() ?? '1',
      dayType:
          json['dayType'] != null
              ? int.tryParse(json['dayType'].toString()) ?? 0
              : 0,
      includeHolliday: json['includeHolliday']?.toString() ?? 'N',
      includeOff: json['includeOff']?.toString() ?? 'N',
      leaveName: json['leaveName']?.toString() ?? '',
      lsnote: json['lsnote']?.toString() ?? '',
      dLsdate: json['dLsdate']?.toString() ?? json['dLsrdtf']?.toString() ?? '',
      iLsslno: json['iLsslno']?.toString() ?? json['iLsslno']?.toString() ?? '',
      lieuday: json['ltlieu']?.toString() ?? '',
      ltlieu: json['ltlieu']?.toString() ?? '',
      luslno: json['luslno'],
      ludate: json['ludate']?.toString() ?? '',
      glapho: json['glapho']?.toString() ?? '',
      ltaphl: json['ltaphl']?.toString() ?? '',
      llsrndy: json['lLsrndy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'leaveDate': date,
    // 'dayType': leaveType,
    'dayType': dayType.toString(),

    'leaveCode': leaveCode,
    'dayFlag': (dayFlag ?? '').isEmpty ? 'F' : dayFlag,
    'paidAbsent': paidAbsent,
    'unpaidAbs': unpaidAbs,
    'ArOrder': "0",
    'ArLuslno': "0",
    'halfType': (halfType ?? '').isEmpty ? '1' : halfType,
    // 'halfType': halfType,
    'leaveName': leaveName,
    'Lsnote': lsnote,
    'dLsdate': dLsdate,
    'ILsslno': iLsslno,
    'lieuDay': lieuday,
    'ltlieu': ltlieu,
    'luslno': luslno,
    'ludate': ludate,
    'Glapho': glapho,
    'ltaphl': ltaphl,
  };
}
