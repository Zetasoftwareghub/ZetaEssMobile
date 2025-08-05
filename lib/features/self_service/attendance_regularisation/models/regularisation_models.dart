// Data classes
class AttendanceEvent {
  final String title;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String colorCode;
  final bool hasRequest;

  AttendanceEvent({
    required this.title,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.colorCode,
    required this.hasRequest,
  });
}

class AttendanceSummary {
  final String name;
  final String shortCode;
  final int count;
  final String color;

  AttendanceSummary({
    required this.name,
    required this.shortCode,
    required this.count,
    required this.color,
  });
}

class RequestStatus {
  final String name;
  final int count;

  RequestStatus({required this.name, required this.count});
}

class RegulariseCalendarDay {
  final int id;
  final String day;
  final String title;
  final String colorCode;
  final String date;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final bool hasRequest;

  RegulariseCalendarDay({
    required this.id,
    required this.day,
    required this.title,
    required this.colorCode,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.hasRequest,
  });
}
