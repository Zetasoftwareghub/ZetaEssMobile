import '../../../self_service/loan/models/loan_list_model.dart';

class ApproveLoanListResponse {
  final List<LoanListModel> approved;
  final List<LoanListModel> rejected;
  final List<LoanListModel> pending;

  ApproveLoanListResponse({
    required this.approved,
    required this.rejected,
    required this.pending,
  });

  // factory ApproveLoanListResponse.fromJson(Map<String, dynamic> json) {
  //   final data = json['data'] as List;
  //   return ApproveLoanListResponse(
  //     pending: (data[0] as List).map((e) => LoanListModel.fromJson(e)).toList(),
  //
  //     approved:
  //         (data[1] as List).map((e) => LoanListModel.fromJson(e)).toList(),
  //     rejected:
  //         (data[2] as List).map((e) => LoanListModel.fromJson(e)).toList(),
  //   );
  // }
  factory ApproveLoanListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;

    return ApproveLoanListResponse(
      pending:
          (data[0] as List)
              .map((e) => LoanListModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      approved:
          (data[1] as List)
              .map((e) => LoanListModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      rejected:
          (data[2] as List)
              .map((e) => LoanListModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
