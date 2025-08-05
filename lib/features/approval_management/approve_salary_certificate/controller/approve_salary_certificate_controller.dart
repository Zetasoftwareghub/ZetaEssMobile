import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_salary_certificate_listing_model.dart';
import '../repository/approve_salary_certificate_repository.dart';

final approveSalaryCertificateListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveSalaryCertificateListNotifier,
  ApproveSalaryCertificateListResponse
>(ApproveSalaryCertificateListNotifier.new);

class ApproveSalaryCertificateListNotifier
    extends AutoDisposeAsyncNotifier<ApproveSalaryCertificateListResponse> {
  @override
  Future<ApproveSalaryCertificateListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveSalaryCertificateRepositoryProvider);
    final result = await repo.getApproveSalaryCertificateList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}
