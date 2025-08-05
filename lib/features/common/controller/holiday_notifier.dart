// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zeta_ess/features/common/repository/common_repository.dart';
//
// import '../../../core/providers/userContext_provider.dart';
// import '../models/holiday_calendar_models.dart';
//
// /// Notifier for regions
// class HolidayRegionNotifier extends AsyncNotifier<List<HolidayRegion>> {
//   @override
//   FutureOr<List<HolidayRegion>> build() async {
//     final userContext = ref.read(userContextProvider);
//     final result = await ref
//         .watch(commonRepositoryProvider)
//         .getHolidayCalendarRegion(userContext: userContext);
//     return result.fold((l) => throw l, (r) => r);
//   }
// }
//
// final holidayRegionProvider =
//     AsyncNotifierProvider<HolidayRegionNotifier, List<HolidayRegion>>(
//       () => HolidayRegionNotifier(),
//     );
//
// /// Notifier for holidays by selected region and year
// class HolidayListNotifier extends AsyncNotifier<List<HolidayListModel>> {
//   String? regionCode;
//   String? year;
//
//   void setParams({required String region, required String year}) {
//     regionCode = region;
//     this.year = year;
//   }
//
//   @override
//   FutureOr<List<HolidayListModel>> build() async {
//     if (regionCode == null || year == null) return [];
//
//     final userContext = ref.read(userContextProvider);
//     final result = await ref
//         .watch(commonRepositoryProvider)
//         .getHolidayCalendar(
//           userContext: userContext,
//           region: regionCode!,
//           year: year!,
//         );
//     return result.fold((l) => throw l, (r) => r);
//   }
// }
//
// final holidayListProvider =
//     AsyncNotifierProvider<HolidayListNotifier, List<HolidayListModel>>(
//       () => HolidayListNotifier(),
//     );

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/userContext_provider.dart';
import '../models/holiday_calendar_models.dart';
import '../repository/common_repository.dart';

class HolidayRegionNotifier extends AsyncNotifier<List<HolidayRegion>> {
  @override
  FutureOr<List<HolidayRegion>> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(commonRepositoryProvider);
    final result = await repo.getHolidayCalendarRegion(
      userContext: userContext,
    );
    return result.fold((l) => throw l, (r) => r);
  }
}

final holidayRegionProvider =
    AsyncNotifierProvider<HolidayRegionNotifier, List<HolidayRegion>>(
      () => HolidayRegionNotifier(),
    );

class HolidayCalendarNotifier extends AsyncNotifier<List<HolidayListModel>> {
  late final String year;
  late final String region;

  @override
  FutureOr<List<HolidayListModel>> build() async {
    throw UnimplementedError(); // Use `.future` with parameters instead of auto-calling build
  }

  Future<void> getCalendar({
    required String year,
    required String region,
  }) async {
    state = const AsyncLoading();
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(commonRepositoryProvider);
    final result = await repo.getHolidayCalendar(
      userContext: userContext,
      year: year,
      region: region,
    );
    state = result.fold(
      (l) => AsyncError(l, StackTrace.current),
      (r) => AsyncData(r),
    );
  }
}

final holidayCalendarProvider =
    AsyncNotifierProvider<HolidayCalendarNotifier, List<HolidayListModel>>(
      () => HolidayCalendarNotifier(),
    );
