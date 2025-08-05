import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/salary_certificate_notifier.dart';
import '../models/salary_certificate_detail_model.dart';
import '../models/salary_certificate_listing_model.dart';

final salaryCertificateListProvider = AutoDisposeAsyncNotifierProvider<
  SalaryCertificateNotifier,
  SalaryCertificateListResponse
>(() => SalaryCertificateNotifier());

final salaryCertificateDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<
      SalaryCertificateDetailsNotifier,
      SalaryCertificateDetailsModel,
      int
    >(SalaryCertificateDetailsNotifier.new);
