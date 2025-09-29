import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../controller/attendance_regularise_controller.dart';
import '../models/regularise_calendar_models.dart';
import '../models/submit_regularise_model.dart';
import '../repository/attendance_regularise_repository.dart';

final calendarNotifierProvider =
    AsyncNotifierProvider<CalendarNotifier, List<Map<String, dynamic>>>(
      () => CalendarNotifier(),
    );

class AttendanceRegularizationController
    extends StateNotifier<AttendanceRegularizationState> {
  final AttendanceRegulariseRepository _repository;
  final UserContext _userContext;

  AttendanceRegularizationController(this._repository, this._userContext)
    : super(AttendanceRegularizationState());

  Future<void> loadCalendarDetails(String date) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _repository.getCalendarDetails(
        userContext: _userContext,
        regulariseDate: date,
      );

      result.fold(
        (error) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          );
        },
        (response) {
          state = state.copyWith(
            isLoading: false,
            calendarDetails:
                response.calendarDetails.first, //TODO check this get only one
            punchingDetails: response.calendarPunchDetails,
            isPageAdd: response.listRights.canCreate ?? true,
            isPageEdit: response.listRights.canEdit ?? true,
            isPageDelete: response.listRights.canDelete ?? true,
            isEditMode: _checkEditMode(response),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void addNewPunchingDetail() {
    final newDetail = CalendarPunchingDetails(
      date: "Select Date",
      time: "Select",
      type: "IN",
      location: "",
      id: state.lastId,
    );

    state = state.copyWith(
      punchingDetails: [...state.punchingDetails, newDetail],
      lastId: state.lastId + 1,
    );
  }

  void removePunchingDetail(int index) {
    final updatedList = List<CalendarPunchingDetails>.from(
      state.punchingDetails,
    );
    updatedList.removeAt(index);
    state = state.copyWith(punchingDetails: updatedList);
  }

  void updatePunchingTime(int index, String time) {
    final updatedList = List<CalendarPunchingDetails>.from(
      state.punchingDetails,
    );
    updatedList[index] = updatedList[index].copyWith(time: time);
    state = state.copyWith(punchingDetails: updatedList);
  }

  void updatePunchingDate(int index, String date) {
    final updatedList = List<CalendarPunchingDetails>.from(
      state.punchingDetails,
    );
    updatedList[index] = updatedList[index].copyWith(date: date);
    state = state.copyWith(punchingDetails: updatedList);
  }

  void updatePunchingType(int index, String type) {
    final updatedList = List<CalendarPunchingDetails>.from(
      state.punchingDetails,
    );
    updatedList[index] = updatedList[index].copyWith(type: type);
    state = state.copyWith(punchingDetails: updatedList);
  }

  ValidationResult validatePunchingDetails() {
    final details = state.punchingDetails;

    // Count IN and OUT punches
    int totalIn = details.where((d) => d.type == "IN").length;
    int totalOut = details.where((d) => d.type == "OUT").length;

    // Check if counts match
    if (totalIn != totalOut) {
      return ValidationResult.failure("IN and OUT punches must be equal");
    }

    if (totalIn == 0) {
      return ValidationResult.failure("At least one punch is required");
    }

    // Check for duplicates
    final times = details.map((d) => d.time).toList();
    final uniqueTimes = times.toSet();
    if (times.length != uniqueTimes.length) {
      return ValidationResult.failure("Duplicate times found");
    }

    // Check for blank dates
    if (details.any((d) => d.date == "Select Date")) {
      return ValidationResult.failure("Please select all dates");
    }

    // Check first punch type
    if (details.isNotEmpty && details.first.type == "OUT") {
      return ValidationResult.failure("First punch cannot be OUT");
    }

    // Check continuous IN/OUT
    for (int i = 1; i < details.length; i++) {
      if (details[i].type == details[i - 1].type) {
        return ValidationResult.failure(
          "Continuous IN or OUT punches not allowed",
        );
      }
    }

    return ValidationResult.success();
  }

  //TODO need this in the UI and then submit with below funtion
  Future<String?> buildAndSubmit(String remark, BuildContext context) async {
    final details = state.punchingDetails;
    int totalIn = 0;
    int totalOut = 0;
    List<String> archkdat = [];
    List<String> arckdate = [];
    List<String> arcktime = [];
    List<String> archktyp = [];

    DateFormat dtfFull = DateFormat("dd-MM-yyyy HH:mm");
    DateFormat dtfDate = DateFormat("dd-MM-yyyy");
    DateFormat dtfYMD = DateFormat("yyyyMMdd HH:mm");

    try {
      for (var item in details) {
        if (item.date == "Select Date" || item.time == "Select") {
          continue;
        }

        if (item.type == "IN") {
          totalIn++;
          archktyp.add("I");
        } else if (item.type == "OUT") {
          totalOut++;
          archktyp.add("O");
        }

        // Construct datetime strings
        final fullDateTime = dtfFull.parse("${item.date} ${item.time}");
        archkdat.add(dtfYMD.format(fullDateTime));
        arckdate.add(dtfDate.format(fullDateTime));
        arcktime.add(item.time ?? "");
        item.datetime = fullDateTime;
      }
    } catch (e) {
      return "Could not save: Invalid date/time format";
    }

    // Validations
    if (totalIn != totalOut) return "IN and OUT punches must be equal";
    if (totalIn == 0) return "At least one punch is required";

    final times = details.map((e) => e.time).toList();
    final duplicates = times.length != times.toSet().length;
    if (duplicates) return "Duplicate times found";

    if (details.first.type == "OUT") return "First punch cannot be OUT";

    for (int i = 1; i < details.length; i++) {
      if (details[i].type == details[i - 1].type) {
        return "Continuous IN or OUT punches not allowed";
      }

      final date1 = dtfDate.parse(details[i - 1].date ?? "");
      final date2 = dtfDate.parse(details[i].date ?? "");
      if (date2.isBefore(date1)) return "Backdated punches not allowed";
    }

    if (details.any((d) => d.date == "Select Date")) {
      return "Please select all dates";
    }

    // Submit
    state = state.copyWith(isLoading: true);

    final model = SubmitRegulariseModel(
      attdt: (details.first.date ?? '').replaceAll('-', '/'),
      remark: remark,
      archkdat: archkdat,
      arckdate: arckdate,
      arcktime: arcktime,
      archktyp: archktyp,
    );

    final result = await _repository.submitRegulariseLeave(
      submitRequest: model,
      userContext: _userContext,
    );

    state = state.copyWith(isLoading: false);

    return result.fold((error) => "Failed to submit: ${error.toString()}", (
      response,
    ) {
      Navigator.pop(context, true);
      Navigator.pop(context, true);
      return _parseSubmitResponse(response);
    });
  }

  bool _checkEditMode(dynamic response) {
    return false;
  }

  String _parseSubmitResponse(String? response) {
    switch (response) {
      case "1":
        return "Submitted Successfully";
      case "-1":
        return "Could not submit attendance!";
      case "-3":
        return "Could not save. Trial payroll is executed for some of the requested days";
      case "-2":
        return "Could not save details, because already submitted another request!";
      default:
        return "Something went wrong, try again later";
    }
  }
}

// validation_result.dart
class ValidationResult {
  final bool isValid;
  final String? message;

  ValidationResult._(this.isValid, this.message);

  factory ValidationResult.success() => ValidationResult._(true, null);
  factory ValidationResult.failure(String message) =>
      ValidationResult._(false, message);
}

// providers.dart
final attendanceRegularizationControllerProvider = StateNotifierProvider<
  AttendanceRegularizationController,
  AttendanceRegularizationState
>(
  (ref) => AttendanceRegularizationController(
    ref.read(attendanceRegulariseRepositoryProvider),
    ref.read(userContextProvider),
  ),
);
