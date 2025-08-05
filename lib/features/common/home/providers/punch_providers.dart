import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/punch_model.dart';
import '../controller/punch_controller.dart';

final punchDetailsProvider =
    AutoDisposeAsyncNotifierProvider<PunchDetailsProvider, List<PunchModel>>(
      PunchDetailsProvider.new,
    );

/// Provider to save punch (check-in/check-out)
final savePunchProvider = AsyncNotifierProvider<SavePunchNotifier, String>(
  SavePunchNotifier.new,
);
