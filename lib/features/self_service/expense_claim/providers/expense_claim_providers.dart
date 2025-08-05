import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';

import '../models/allowance_type_model.dart';
import '../models/expense_claim_model.dart';

final allowanceTypesProvider = AutoDisposeAsyncNotifierProvider<
  AllowanceTypesNotifier,
  List<AllowanceTypeModel>
>(() => AllowanceTypesNotifier());

final expenseClaimListProvider =
    AsyncNotifierProvider<ExpenseClaimListNotifier, ExpenseClaimListResponse>(
      ExpenseClaimListNotifier.new,
    );

final expenseClaimDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<ExpenseClaimDetailsNotifier, ExpenseClaimModel, int>(
      ExpenseClaimDetailsNotifier.new,
    );
