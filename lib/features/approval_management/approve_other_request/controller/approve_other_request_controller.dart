// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../core/providers/userContext_provider.dart';
// import '../../../self_service/other_request/models/other_request_listing_model.dart';
// import '../repository/approve_other_request_repository.dart';
//
// final approveOtherRequestListProvider = AutoDisposeAsyncNotifierProvider<
//   ApproveOtherRequestListNotifier,
//   OtherRequestListResponse
// >(ApproveOtherRequestListNotifier.new);
//
// class ApproveOtherRequestListNotifier
//     extends AutoDisposeAsyncNotifier<OtherRequestListResponse> {
//   @override
//   Future<OtherRequestListResponse> build() async {
//     final userContext = ref.read(userContextProvider);
//     final repo = ref.read(approveOtherRequestRepositoryProvider);
//     final result = await repo.getApproveOtherRequestList(
//       userContext: userContext,
//     );
//     return result.fold((failure) => throw failure, (data) => data);
//   }
// }
