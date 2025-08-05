class HolidayRegion {
  String? name;
  String? value;

  HolidayRegion({this.name, this.value});
  factory HolidayRegion.fromJson(Map<String, dynamic> json) {
    return HolidayRegion(
      name: json['leaveName'].toString(),
      value: json['dLsrdtt'].toString(),
    );
  }
}

class HolidayListModel {
  String? month;
  String? date;
  String? holidayReason;
  String? day;

  HolidayListModel({this.date, this.day, this.holidayReason, this.month});

  factory HolidayListModel.fromJson(Map<String, dynamic> json) {
    return HolidayListModel(
      month: json['leaveName'].toString(),
      date: json['dLsrdtf'].toString(),
      day: json['dLsrdtt'].toString(),
      holidayReason: json['empName'].toString(),
    );
  }
}
