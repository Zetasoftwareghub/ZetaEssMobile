import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/salary_advance/models/salary_advance_details.dart';

import '../controller/salary_advance_notifier.dart';
import '../models/salaryAdvance_listing_model.dart';

final salaryAdvanceListProvider = AutoDisposeAsyncNotifierProvider<
  SalaryAdvanceListNotifier,
  SalaryAdvanceListResponse
>(SalaryAdvanceListNotifier.new);

final salaryAdvanceDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<SalaryAdvanceDetailsNotifier, SalaryAdvanceDetailsModel, String?>(
      SalaryAdvanceDetailsNotifier.new,
    );
