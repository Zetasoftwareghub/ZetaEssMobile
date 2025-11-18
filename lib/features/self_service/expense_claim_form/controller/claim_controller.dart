import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/claim_list_response.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../repository/claim_repository.dart';

// class ClaimListNotifier extends AutoDisposeAsyncNotifier<ClaimListResponse> {
//   @override
//   Future<ClaimListResponse> build() async {
//     final repo = ref.read(expenseClaimControllerProvider);
//     final repo = ref.read(claimRepositoryProvider);
//     final userContext = ref.read(userContextProvider);
//     final result = await repo.getExpenseClaimList(userContext: userContext);
//     return result.fold((l) => throw l.errMsg, (r) => r);
//   }
// }
