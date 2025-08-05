import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/salary_certificate_detail_model.dart';
import '../models/salary_certificate_listing_model.dart';
import '../repository/salary_certificate_repository.dart';

class SalaryCertificateNotifier
    extends AutoDisposeAsyncNotifier<SalaryCertificateListResponse> {
  @override
  Future<SalaryCertificateListResponse> build() async {
    final repository = ref.read(salaryCertificateRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repository.getSalaryCertificateList(
      userContext: userContext,
    );

    return result.fold((failure) => throw failure, (data) => data);
  }
}

class SalaryCertificateDetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<SalaryCertificateDetailsModel, int> {
  @override
  Future<SalaryCertificateDetailsModel> build(int certificateId) async {
    final repo = ref.read(salaryCertificateRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getSalaryCertificateDetails(
      userContext: userContext,
      certificateId: certificateId,
    );

    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}
