import 'package:zeta_ess/models/listRights_model.dart';

class CalendarDetails {
  String? date;
  String? remarks;

  CalendarDetails({this.date, this.remarks});

  factory CalendarDetails.fromMap(Map<String, dynamic> map) {
    return CalendarDetails(
      date: map['lsnote']?.toString(), // now lowercase
      remarks: map['subname']?.toString(),
    );
  }
}

class CalendarPunchingDetails {
  String? date;
  String? time;
  String? type;
  String? location;
  int? id;
  DateTime? datetime;
  String? atndid;

  CalendarPunchingDetails({
    this.date,
    this.location,
    this.time,
    this.type,
    this.id,
    this.datetime,
    this.atndid,
  });
  factory CalendarPunchingDetails.fromMap(Map<String, dynamic> map, int id) {
    return CalendarPunchingDetails(
      date: map['dLsrdtf']?.toString(),
      time: map['empName']?.toString(),
      type: map['lsnote']?.toString(),
      location: map['lvpcarname']?.toString(),
      id: id,
      atndid: map['leaveName']?.toString(),
    );
  }
  CalendarPunchingDetails copyWith({
    String? date,
    String? time,
    String? type,
    String? location,
    int? id,
    DateTime? datetime,
    String? atndid,
  }) {
    return CalendarPunchingDetails(
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      location: location ?? this.location,
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      atndid: atndid ?? this.atndid,
    );
  }
}

class RegulariseCalenderDetailResponse {
  final List<CalendarDetails> calendarDetails;
  final List<CalendarPunchingDetails> calendarPunchDetails;
  final ListRightsModel listRights;
  RegulariseCalenderDetailResponse({
    required this.calendarDetails,
    required this.calendarPunchDetails,
    required this.listRights,
  });
  factory RegulariseCalenderDetailResponse.fromJson(Map<String, dynamic> json) {
    return RegulariseCalenderDetailResponse(
      calendarDetails:
          (json['subLst'] as List<dynamic>?)
              ?.map((item) => CalendarDetails.fromMap(item))
              .toList() ??
          [],
      calendarPunchDetails:
          (json['canLst'] as List<dynamic>?)
              ?.asMap()
              .entries
              .map(
                (entry) =>
                    CalendarPunchingDetails.fromMap(entry.value, entry.key + 1),
              )
              .toList() ??
          [],
      listRights: ListRightsModel.fromJson(json['rights'] ?? {}),
    );
  }
}
