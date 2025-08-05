import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/other_request_notifiers.dart';
import '../models/other_request_listing_model.dart';

final otherRequestFirstListingProvider = AutoDisposeAsyncNotifierProvider<
  OtherRequestFirstListingNotifier,
  List<OtherRequestFirstListingModel>
>(OtherRequestFirstListingNotifier.new);

final otherRequestListProvider = AsyncNotifierProvider.autoDispose.family<
  OtherRequestListNotifier,
  OtherRequestListResponse,
  OtherRequestParams
>(() => OtherRequestListNotifier());
