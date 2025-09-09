import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';

import '../../models/punch_model.dart';
import '../controller/punch_controller.dart';
import '../repository/home_repository.dart';

final punchDetailsProvider =
    AutoDisposeAsyncNotifierProvider<PunchDetailsProvider, List<PunchModel>>(
      PunchDetailsProvider.new,
    );

/// Provider to save punch (check-in/check-out)
final savePunchProvider = AsyncNotifierProvider<SavePunchNotifier, String>(
  SavePunchNotifier.new,
);

final getEmployeeShiftProvider = FutureProvider.family<String, String>((
  ref,
  date,
) async {
  final repo = ref.read(homeRepositoryProvider);
  final userContext = ref.watch(userContextProvider);

  final res = await repo.getShiftAgainstEmployee(
    userContext: userContext,
    date: date,
  );

  return res.fold(
    (l) => throw l, // failure branch → throw so FutureProvider catches error
    (r) => r, // success branch → return data
  );
});
