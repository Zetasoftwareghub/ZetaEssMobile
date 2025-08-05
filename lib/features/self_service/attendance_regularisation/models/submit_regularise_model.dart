import 'package:zeta_ess/features/self_service/attendance_regularisation/models/regularise_calendar_models.dart';

class SubmitRegulariseModel {
  final String attdt;
  final String remark;
  final List<String> archkdat;
  final List<String> arckdate;
  final List<String> arcktime;
  final List<String> archktyp;

  SubmitRegulariseModel({
    required this.attdt,
    required this.remark,
    required this.archkdat,
    required this.arckdate,
    required this.arcktime,
    required this.archktyp,
  });

  Map<String, dynamic> toJson({
    required String emalid,
    required String emcode,
    required String empname,
    required String suconn,
    required String url,
  }) {
    return {
      "emalid": emalid,
      "attdt": attdt,
      "emcode": emcode,
      "empname": empname,
      "suconn": suconn,
      "remark": remark,
      "archkdat": archkdat.join(","),
      "arckdate": arckdate.join(","),
      "arcktime": arcktime.join(","),
      "archktyp": archktyp.join(","),
      "url": "$url/",
      "baseDirectory": '',
    };
  }
}

class AttendanceRegularizationState {
  final bool isLoading;
  final String? errorMessage;
  final CalendarDetails? calendarDetails;
  final List<CalendarPunchingDetails> punchingDetails;
  final bool isPageAdd;
  final bool isPageEdit;
  final bool isPageDelete;
  final bool isEditMode;
  final int lastId;

  AttendanceRegularizationState({
    this.isLoading = false,
    this.errorMessage,
    this.calendarDetails,
    this.punchingDetails = const [],
    this.isPageAdd = true,
    this.isPageEdit = true,
    this.isPageDelete = true,
    this.isEditMode = false,
    this.lastId = 0,
  });

  AttendanceRegularizationState copyWith({
    bool? isLoading,
    String? errorMessage,
    CalendarDetails? calendarDetails,
    List<CalendarPunchingDetails>? punchingDetails,
    bool? isPageAdd,
    bool? isPageEdit,
    bool? isPageDelete,
    bool? isEditMode,
    int? lastId,
  }) {
    return AttendanceRegularizationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      calendarDetails: calendarDetails ?? this.calendarDetails,
      punchingDetails: punchingDetails ?? this.punchingDetails,
      isPageAdd: isPageAdd ?? this.isPageAdd,
      isPageEdit: isPageEdit ?? this.isPageEdit,
      isPageDelete: isPageDelete ?? this.isPageDelete,
      isEditMode: isEditMode ?? this.isEditMode,
      lastId: lastId ?? this.lastId,
    );
  }
}
