import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/currency_model.dart';

import '../controller/claim_controller.dart';
import '../models/claim_list_response.dart';

final claimListProvider =
    AutoDisposeAsyncNotifierProvider<ClaimListNotifier, ClaimListResponse>(
      () => ClaimListNotifier(),
    );

final currencyListProvider =
    AutoDisposeAsyncNotifierProvider<CurrencyListNotifier, List<CurrencyModel>>(
      () => CurrencyListNotifier(),
    );
//
// import '../controller/claim_controller.dart';
// import '../models/claim_list_response.dart';
//
// final claimListProvider =
//     AutoDisposeAsyncNotifierProvider<ClaimListNotifier, ClaimListResponse>(
//       () => ClaimListNotifier(),
//     );
