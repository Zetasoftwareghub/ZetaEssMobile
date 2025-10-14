import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeta_ess/core/utils.dart';
import '../../../../../core/api_constants/dio_headers.dart';
import '../../../../../core/providers/userContext_provider.dart';
import '../../controller/old_hrms_configuration_stuffs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

/*Fetch Leave Configuration
→ LeaveApiHelper.extractLeaveConfig()

Check Leave Gaps & Adjacent Days
→ LeaveConditionChecker.checkPrecedingTrailing()
→ LeaveConditionChecker.checkGapLeaveConditions()

Apply Leave Policies and Flags
→ LeaveFlagProcessor.processDayConfiguration()
→ setDayFlag() updates flags (F, X, etc.)

Data flows through Dio + Riverpod context, using user details.


| Class                     | Responsibility                                     |
| ------------------------- | -------------------------------------------------- |
| **LeaveApiHelper**        | Safe API execution + parse response                |
| **LeaveConditionChecker** | Checks conditions between holidays/working days    |
| **LeaveFlagProcessor**    | Sets and processes final day flags based on policy |
| **LeaveConstants**        | Stores constants & config values                   |
| **GapLeaveConditions**    | Holds result of gap leave check                    |*/

class LeaveApiHelper {
  static Future<T?> executeWithTimeout<T>(
    Future<T> Function() apiCall,
    String operation,
    BuildContext context,
  ) async {
    try {
      return await apiCall().timeout(LeaveConstants.apiTimeout);
    } catch (e) {
      print("Error in $operation: $e");
      return null;
    }
  }

  static LeaveConfigurationData? extractLeaveConfig(
    Map<String, dynamic>? responseJson,
  ) {
    if (responseJson == null) return null;

    try {
      final subLst = (responseJson['subLst'] ?? []) as List;
      if (subLst.isEmpty) return null;
      printFullJson(subLst.first);
      print("subLst.first");
      return LeaveConfigurationData.fromJson(subLst.first);
    } catch (e) {
      print("Error parsing subLst: $e");
      return null;
    }
  }
}

//This class checks conditions related to preceding or trailing leaves, gap leave rules, etc.
class LeaveConditionChecker {
  static Future<bool> checkPrecedingTrailing(
    List<LeaveConfigurationData> leaveData,
    String leaveCode,
    bool isTrailing,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final targetDay = isTrailing ? leaveData.first : leaveData.last;

    if (targetDay.dayType != LeaveConstants.weekOff &&
        targetDay.dayType != LeaveConstants.holiday) {
      return false;
    }

    DateTime dt = DateFormat(
      LeaveConstants.dateFormat,
    ).parse(targetDay.date ?? '');
    dt = dt.add(Duration(days: isTrailing ? -1 : 1));

    while (true) {
      final responseJson = await LeaveApiHelper.executeWithTimeout(
        () => getLeaveDetailsByDate(ref, dt.toString(), leaveCode),

        'checkPrecedingTrailing',
        context,
      );

      if (responseJson == null) break;

      final leaveConfigDates = <LeaveConfigDate>[];
      try {
        for (var item in responseJson) {
          leaveConfigDates.add(LeaveConfigDate.fromJson(item));
        }
      } catch (e) {
        print("Error parsing leave config dates: $e");
        break;
      }

      if (leaveConfigDates.isEmpty) break;

      final firstConfig = leaveConfigDates.first;
      if (firstConfig.dayType == LeaveConstants.workingDay) {
        return _evaluateWorkingDayCondition(firstConfig, leaveData, isTrailing);
      }

      dt = dt.add(Duration(days: isTrailing ? -1 : 1));
    }

    return false;
  }

  //Determines if leave bridging with weekends/holidays is valid.
  static bool _evaluateWorkingDayCondition(
    LeaveConfigDate config,
    List<LeaveConfigurationData> leaveData,
    bool isTrailing,
  ) {
    if (config.cLsflag == LeaveConstants.flagFull) {
      return true;
    }

    final hasMultipleDays = leaveData.first.date != leaveData.last.date;
    final oppositeEndIsWorking =
        isTrailing
            ? leaveData.last.dayType == LeaveConstants.workingDay
            : leaveData.first.dayType == LeaveConstants.workingDay;

    if (hasMultipleDays && oppositeEndIsWorking) {
      final expectedHalfType =
          isTrailing ? LeaveConstants.halfDay1 : LeaveConstants.halfDay2;
      if (config.halfDayType == expectedHalfType) {
        return true;
      }
    }

    return config.halfDayType ==
        (isTrailing ? LeaveConstants.halfDay2 : LeaveConstants.halfDay1);
  }

  //This method checks gap leave conditions — i.e., if there are working days between two leaves.
  static Future<GapLeaveConditions> checkGapLeaveConditions(
    List<LeaveConfigurationData> leaveData,
    DateTime fromDate,
    DateTime toDate,
    String date,
  ) async {
    bool prec = false;
    bool trail = false;

    final currentDate = DateFormat(LeaveConstants.dateFormat).parse(date);

    // Check trailing condition
    DateTime checkDate = currentDate;
    while (checkDate.isAfter(fromDate) ||
        checkDate.isAtSameMomentAs(fromDate)) {
      final dateStr = DateFormat(LeaveConstants.dateFormat).format(checkDate);
      final matchingItems = leaveData.where(
        (element) => element.date == dateStr,
      );

      if (matchingItems.isNotEmpty) {
        final item = matchingItems.first;
        if (item.dayType == LeaveConstants.workingDay) {
          trail = _evaluateTrailingCondition(item, leaveData);
          break;
        }
      }
      checkDate = checkDate.add(const Duration(days: -1));
    }

    // Check preceding condition
    checkDate = currentDate;
    while (checkDate.isBefore(toDate) || checkDate.isAtSameMomentAs(toDate)) {
      final dateStr = DateFormat(LeaveConstants.dateFormat).format(checkDate);
      final matchingItems = leaveData.where(
        (element) => element.date == dateStr,
      );

      if (matchingItems.isNotEmpty) {
        final item = matchingItems.first;
        if (item.dayType == LeaveConstants.workingDay) {
          prec = _evaluatePrecedingCondition(item, leaveData);
          break;
        }
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return GapLeaveConditions(preceding: prec, trailing: trail);
  }

  static bool _evaluateTrailingCondition(
    LeaveConfigurationData item,
    List<LeaveConfigurationData> leaveData,
  ) {
    final hasMultipleDays = leaveData.first.date != leaveData.last.date;

    if (hasMultipleDays &&
        leaveData.last.dayType == LeaveConstants.workingDay &&
        item.halfType == LeaveConstants.halfDay1) {
      return true;
    }

    return item.dayFlag == LeaveConstants.flagFull ||
        item.halfType == LeaveConstants.halfDay2;
  }

  static bool _evaluatePrecedingCondition(
    LeaveConfigurationData item,
    List<LeaveConfigurationData> leaveData,
  ) {
    final hasMultipleDays = leaveData.first.date != leaveData.last.date;

    if (item.halfType == LeaveConstants.halfDay2 &&
        hasMultipleDays &&
        leaveData.first.dayType == LeaveConstants.workingDay) {
      return true;
    }

    return item.dayFlag == LeaveConstants.flagFull ||
        item.halfType == LeaveConstants.halfDay1;
  }

  static Future getLeaveDetailsByDate(
    WidgetRef ref,
    String date,
    String ltcode,
  ) async {
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
}

//This class applies flag logic (whether to include/exclude a day from leave count).

class LeaveFlagProcessor {
  static void setDayFlag(
    List<LeaveConfigurationData> leaveData,
    String date,
    int dayType,
    String includeOff,
    String includeHoliday,
    String flagValue, {
    String? glapho,
  }) {
    final dayConfig = leaveData.firstWhere((element) => element.date == date);

    if (flagValue.isEmpty) {
      dayConfig.dayFlag = LeaveConstants.flagEmpty;
      return;
    }

    if (flagValue == LeaveConstants.flagExcluded) {
      dayConfig.dayFlag = LeaveConstants.flagExcluded;
      return;
    }
    bool isOFFCombo = false;
    printFullJson(isOFFCombo);
    if (glapho == 'S') {
      //TODO eth thatti koot ann - READY akkanm Sherikk !
      printFullJson("assa");
      final firstDayOFF =
          leaveData.first.dayType == 3 || leaveData.first.dayType == 4;
      final lastDayOFF =
          leaveData.last.dayType == 3 || leaveData.last.dayType == 4;
      final firstHalf = leaveData.first.halfType ?? '';
      final lastHalf = leaveData.last.halfType ?? '';

      isOFFCombo =
          (firstDayOFF && lastHalf == LeaveConstants.halfDay2) ||
          (lastDayOFF && firstHalf == LeaveConstants.halfDay1);
    }

    if (dayType == LeaveConstants.weekOff) {
      dayConfig.dayFlag =
          includeOff == LeaveConstants.no || isOFFCombo
              ? LeaveConstants.flagExcluded
              : LeaveConstants.flagFull;
    } else if (dayType == LeaveConstants.holiday) {
      dayConfig.dayFlag =
          includeHoliday == LeaveConstants.no || isOFFCombo
              ? LeaveConstants.flagExcluded
              : LeaveConstants.flagFull;
    }
  }

  static String processGapLeavePolicy(
    String glapho,
    GapLeaveConditions conditions,
    int dayType,
    String includeOff,
    String includeHoliday,
    List<LeaveConfigurationData> leaveData,
  ) {
    // final firstDayFlag = leaveData.first.dayFlag;
    // final lastDayFlag = leaveData.last.dayFlag;
    // final firstHalf = leaveData.first.dayFlag ?? '';
    // final lastHalf = leaveData.last.halfType ?? '';

    switch (glapho) {
      //isHalfDayCut true ayyal thazhe exclude avvum false ayyal full
      case 'S': // Preceding & Trailing
        if (conditions.preceding && conditions.trailing) {
          final isHalfDayCut = halfDayRuleHit(
            leaveData,
            GapLeaveConditions(preceding: true, trailing: true),
            leaveData.first.halfType ?? '',
            leaveData.last.halfType ?? '',
          );
          return _getDayFlagValue(
            dayType,
            includeOff,
            includeHoliday,
            isHalfDayCut,
          );
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      case 'P': // Preceding only
        if (conditions.preceding) {
          final isHalfDayCut = halfDayRuleHit(
            leaveData,
            GapLeaveConditions(preceding: true, trailing: false),
            leaveData.first.halfType ?? '',
            leaveData.last.halfType ?? '',
          );
          return _getDayFlagValue(
            dayType,
            includeOff,
            includeHoliday,
            isHalfDayCut,
          );
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      case 'T': // Trailing only
        if (conditions.trailing) {
          final isHalfDayCut = halfDayRuleHit(
            leaveData,
            GapLeaveConditions(preceding: false, trailing: true),
            leaveData.first.halfType ?? '',
            leaveData.last.halfType ?? '',
          );
          return _getDayFlagValue(
            dayType,
            includeOff,
            includeHoliday,
            isHalfDayCut,
          );
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      case LeaveConstants.yes: // Preceding or Trailing
        if (conditions.preceding || conditions.trailing) {
          // --- --- //TODO check the precee OR trail last day second half and firsst day first halff ==== don;t includeee!  !
          final firstDayFlag = leaveData.first.dayFlag ?? '';
          final lastDayFlag = leaveData.last.dayFlag ?? '';
          final firstHalf = leaveData.first.halfType ?? '';
          final lastHalf = leaveData.last.halfType ?? '';

          bool isHalfDayCut = false;
          // If first day is H and it's the second half, cut
          if (firstDayFlag != 'F' && lastDayFlag != 'F') {
            if ((firstDayFlag == 'H' && firstHalf == LeaveConstants.halfDay1) &&
                (lastDayFlag == 'H' && lastHalf == LeaveConstants.halfDay2)) {
              isHalfDayCut = true;
            }
          }

          return _getDayFlagValue(
            dayType,
            includeOff,
            includeHoliday,
            isHalfDayCut,
          );
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      default:
        return LeaveConstants.flagEmpty;
    }
  }

  //Helper methods to map logic → flag value depending on type:
  static String _getDayFlagValue(
    int dayType,
    String includeOff,
    String includeHoliday,
    bool isHalfDayCut,
  ) {
    printFullJson(isHalfDayCut);
    printFullJson("isHalfDayCut");
    if (dayType == LeaveConstants.weekOff) {
      return includeOff == LeaveConstants.no || isHalfDayCut
          ? LeaveConstants.flagExcluded
          : LeaveConstants.flagFull;
    } else if (dayType == LeaveConstants.holiday) {
      return includeHoliday == LeaveConstants.no || isHalfDayCut
          ? LeaveConstants.flagExcluded
          : LeaveConstants.flagFull;
    }
    return LeaveConstants.flagEmpty;
  }

  //ETH ann call akkune - prec check cheyymbo false avvonduu@
  static String _getInclusiveDayFlagValue(
    int dayType,
    String includeOff,
    String includeHoliday,
  ) {
    if ((dayType == LeaveConstants.weekOff &&
            includeOff == LeaveConstants.yes) ||
        (dayType == LeaveConstants.holiday &&
            includeHoliday == LeaveConstants.yes)) {
      return LeaveConstants.flagFull;
    }
    return LeaveConstants.flagEmpty;
  }

  //Main method that orchestrates all rules for a given day: CALLS FROM THE SCREEN !!!!!!!

  static Future<void> processDayConfiguration(
    List<LeaveConfigurationData> leaveData,
    LeaveConfigurationData dayItem,
    String dateStr,
    String includeOff,
    String includeHoliday,
    String glapho,
    String ltaphl,
    DateTime fromDate,
    DateTime toDate,
    GapLeaveConditions globalConditions,
  ) async {
    // Skip working days
    if (dayItem.dayType != LeaveConstants.weekOff &&
        dayItem.dayType != LeaveConstants.holiday) {
      return;
    }
    printFullJson(ltaphl);
    printFullJson("ltaphl");
    if (ltaphl == LeaveConstants.no) {
      // Simple case: no gap leave policy
      setDayFlag(
        leaveData,
        dateStr,
        dayItem.dayType,
        includeOff,
        includeHoliday,
        LeaveConstants.flagFull,
      );
    } else if (glapho == LeaveConstants.no) {
      // Gap leave policy disabled
      setDayFlag(
        leaveData,
        dateStr,
        dayItem.dayType,
        includeOff,
        includeHoliday,
        LeaveConstants.flagFull,
      );
    } else {
      // Complex gap leave policy
      final conditions = await LeaveConditionChecker.checkGapLeaveConditions(
        leaveData,
        fromDate,
        toDate,
        dayItem.date ?? '',
      );
      printFullJson(conditions.preceding);
      printFullJson("conditions.preceding");
      // --- --- //TODO check the precee OR trail like this bro !
      //TODO evde ann mone set akkande 1FH 2FH
      final flagValue =
          (glapho == 'T' && conditions.trailing == false) ||
                  (glapho == 'P' && conditions.preceding == false)
              ? LeaveConstants.flagExcluded
              : processGapLeavePolicy(
                glapho,
                conditions,
                dayItem.dayType,
                includeOff,
                includeHoliday,
                leaveData,
              );

      setDayFlag(
        leaveData,
        dateStr,
        dayItem.dayType,
        includeOff,
        includeHoliday,
        flagValue,
        glapho: glapho,
      );
    }
  }
}

//models and constants !
class GapLeaveConditions {
  final bool preceding;
  final bool trailing;

  GapLeaveConditions({required this.preceding, required this.trailing});
}

class LeaveConstants {
  static const Duration apiTimeout = Duration(seconds: 60);
  static const String dateFormat = 'dd/MM/yyyy';

  // Day flags - keeping original values
  static const String flagExcluded = 'X';
  static const String flagFull = 'F';
  static const String flagEmpty = 'X';

  // Configuration values - keeping original values
  static const String yes = 'Y';
  static const String no = 'N';

  // Day types
  static const int workingDay = 1;
  static const int weekOff = 3;
  static const int holiday = 4;

  // Half day types - keeping original values
  static const String halfDay1 = '1';
  static const String halfDay2 = '2';
}

bool halfDayRuleHit(
  List<LeaveConfigurationData> leaveData,
  GapLeaveConditions conditions,
  String firstHalf,
  String lastHalf,
) {
  final firstDayFlag = leaveData.first.dayFlag;
  final lastDayFlag = leaveData.last.dayFlag;
  bool isHalfDayCut = false;
  // Case 1: both preceding and trailing should be satisfied
  if (conditions.preceding && conditions.trailing) {
    final isHolidayHalfCombo =
        (firstDayFlag == 'H' &&
            firstHalf == LeaveConstants.halfDay1 &&
            lastDayFlag != 'F') ||
        (lastDayFlag == 'H' &&
            lastHalf == LeaveConstants.halfDay2 &&
            firstDayFlag != 'F');
    final isFullHalfCombo =
        (firstDayFlag == 'F' &&
            lastHalf == LeaveConstants.halfDay2 &&
            lastDayFlag != 'F') ||
        (lastDayFlag == 'F' &&
            firstHalf == LeaveConstants.halfDay1 &&
            firstDayFlag != 'F');

    if (isHolidayHalfCombo || isFullHalfCombo) {
      isHalfDayCut = true;
    }
  }
  // Case 2: only preceding condition
  else if (conditions.preceding) {
    final isHolidayHalfCombo =
        (lastDayFlag == 'H' && lastHalf == LeaveConstants.halfDay2);
    printFullJson(lastDayFlag == 'H');
    printFullJson(lastHalf == LeaveConstants.halfDay2);
    printFullJson("lastHalf == LeaveConstants.halfDay2");
    final isFullHalfCombo =
        (firstDayFlag == 'F' && lastHalf == LeaveConstants.halfDay2);

    if (isHolidayHalfCombo || isFullHalfCombo) {
      isHalfDayCut = true;
    }
  }
  // Case 3: only trailing condition
  else if (conditions.trailing) {
    final isHolidayHalfCombo =
        (firstDayFlag == 'H' && firstHalf == LeaveConstants.halfDay1);

    final isFullHalfCombo =
        (firstDayFlag == 'F' && firstHalf == LeaveConstants.halfDay1);

    if (isHolidayHalfCombo || isFullHalfCombo) {
      isHalfDayCut = true;
    }
  }

  return isHalfDayCut;
}
