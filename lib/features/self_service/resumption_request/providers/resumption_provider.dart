import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../controller/resumption_notifiers.dart';
import '../models/resumption_details_model.dart';
import '../models/resumption_leave_model.dart';
import '../models/resumption_listing_model.dart';
import '../repository/resumption_repository.dart';

final resumptionListProvider = AutoDisposeAsyncNotifierProvider<
  ResumptionListNotifier,
  ResumptionListResponse
>(() => ResumptionListNotifier());

final resumptionLeavesProvider = AutoDisposeAsyncNotifierProvider<
  ResumptionLeavesNotifier,
  List<ResumptionLeaveModel>
>(ResumptionLeavesNotifier.new);

final resumptionDetailProvider = FutureProvider.autoDispose
    .family<ResumptionDetailModel, int>((ref, resumptionId) async {
      final repo = ref.read(resumptionRepositoryProvider);
      final user = ref.read(userContextProvider);

      final result = await repo.getResumptionDetails(
        userContext: user,
        resumptionId: resumptionId,
      );

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });
