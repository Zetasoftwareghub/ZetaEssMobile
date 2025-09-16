// leave_helper.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/api_constants/dio_headers.dart';
import '../../../../../core/common/no_server_screen.dart';
import '../../../../../core/providers/userContext_provider.dart';
import '../../controller/old_hrms_configuration_stuffs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

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

      return LeaveConfigurationData.fromJson(subLst.first);
    } catch (e) {
      print("Error parsing subLst: $e");
      return null;
    }
  }
}

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

class LeaveFlagProcessor {
  static void setDayFlag(
    List<LeaveConfigurationData> leaveData,
    String date,
    int dayType,
    String includeOff,
    String includeHoliday,
    String flagValue,
  ) {
    final dayConfig = leaveData.firstWhere((element) => element.date == date);

    if (flagValue.isEmpty) {
      dayConfig.dayFlag = LeaveConstants.flagEmpty;
      return;
    }

    if (dayType == LeaveConstants.weekOff) {
      dayConfig.dayFlag =
          includeOff == LeaveConstants.no
              ? LeaveConstants.flagExcluded
              : LeaveConstants.flagFull;
    } else if (dayType == LeaveConstants.holiday) {
      dayConfig.dayFlag =
          includeHoliday == LeaveConstants.no
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
  ) {
    switch (glapho) {
      case 'S': // Preceding & Trailing
        if (conditions.preceding && conditions.trailing) {
          return _getDayFlagValue(dayType, includeOff, includeHoliday);
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      case 'P': // Preceding only
        if (conditions.preceding) {
          return _getDayFlagValue(dayType, includeOff, includeHoliday);
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      case 'T': // Trailing only
        if (conditions.trailing) {
          return _getDayFlagValue(dayType, includeOff, includeHoliday);
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      case LeaveConstants.yes: // Preceding or Trailing
        if (conditions.preceding || conditions.trailing) {
          return _getDayFlagValue(dayType, includeOff, includeHoliday);
        } else {
          return _getInclusiveDayFlagValue(dayType, includeOff, includeHoliday);
        }

      default:
        return LeaveConstants.flagEmpty;
    }
  }

  static String _getDayFlagValue(
    int dayType,
    String includeOff,
    String includeHoliday,
  ) {
    if (dayType == LeaveConstants.weekOff) {
      return includeOff == LeaveConstants.no
          ? LeaveConstants.flagExcluded
          : LeaveConstants.flagFull;
    } else if (dayType == LeaveConstants.holiday) {
      return includeHoliday == LeaveConstants.no
          ? LeaveConstants.flagExcluded
          : LeaveConstants.flagFull;
    }
    return LeaveConstants.flagEmpty;
  }

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

      final flagValue = processGapLeavePolicy(
        glapho,
        conditions,
        dayItem.dayType,
        includeOff,
        includeHoliday,
      );

      setDayFlag(
        leaveData,
        dateStr,
        dayItem.dayType,
        includeOff,
        includeHoliday,
        flagValue,
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
  static const String flagEmpty = '';

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
