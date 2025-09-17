// import '../../../../models/listRights_model.dart';
//
// class ExpenseClaimModel {
//   // Fields from your existing model (for app use)
//   int iEcid;
//   String monthyear;
//   String requestedDate;
//   String note;
//   String amount;
//   int allowanceCode;
//   String crcode;
//   double conrate;
//   String url;
//   int cocode;
//   int expenseClaimId;
//   String expenseClaimName;
//   String? employeeID;
//   String? employeeName;
//   String? currency;
//
//   ExpenseClaimModel({
//     this.iEcid = 0,
//     required this.monthyear,
//     required this.requestedDate,
//     required this.note,
//     required this.amount,
//     required this.allowanceCode,
//     required this.crcode,
//     this.conrate = 0,
//     required this.url,
//     this.cocode = 0,
//     this.expenseClaimId = 0,
//     this.expenseClaimName = '',
//     this.employeeID,
//     this.employeeName,
//     this.currency,
//   });
//
//   /// 🔄 Your toJson for submission – **DO NOT CHANGE**
//   Map<String, dynamic> toJson() {
//     return {
//       'iEcid': iEcid,
//       'monthyear': monthyear,
//       'reqdate': requestedDate,
//       'note': note,
//       'amount': amount,
//       'alcode': allowanceCode,
//       'crcode': crcode,
//       'conrate': conrate,
//       'url': url,
//       'cocode': cocode,
//     };
//   }
//
//   /// ✅ Parses only server response JSON
//   factory ExpenseClaimModel.fromJson(Map<String, dynamic> json) {
//     return ExpenseClaimModel(
//       // Default/manual values for the other required constructor params
//       expenseClaimId: json['iClslno'] ?? 0,
//       expenseClaimName: json['sAlname'] ?? '',
//       monthyear: json['monthYear'] ?? '',
//       iEcid: json['iClslno'] ?? 0,
//       requestedDate: json['sCldate'],
//       note: json['sClnote'] ?? '',
//       amount: json['sClamnt'] ?? '',
//       allowanceCode: json['iAlcode'] ?? 0,
//       crcode: '',
//       conrate: 0,
//       url: '',
//       cocode: 0,
//       employeeID: json['empId'] ?? '',
//       employeeName: json['empName'] ?? '',
//       currency: json['cCrcode'] ?? '',
//     );
//   }
// }
//
// //THIS is to fetch the response from the api !
// class ExpenseClaimListResponse {
//   final SubmittedExpenseClaimResponse submitted;
//   final List<ExpenseClaimModel> approved;
//   final List<ExpenseClaimModel> rejected;
//
//   ExpenseClaimListResponse({
//     required this.submitted,
//     required this.approved,
//     required this.rejected,
//   });
//
//   factory ExpenseClaimListResponse.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] ?? {};
//     print(data);
//     print("data123");
//     return ExpenseClaimListResponse(
//       submitted: SubmittedExpenseClaimResponse.fromJson(json),
//       approved:
//           (data['appLst'] as List<dynamic>? ?? [])
//               .map((e) => ExpenseClaimModel.fromJson(e))
//               .toList(),
//       rejected:
//           (data['rejLst'] as List<dynamic>? ?? [])
//               .map((e) => ExpenseClaimModel.fromJson(e))
//               .toList(),
//     );
//   }
// }
//
// class SubmittedExpenseClaimResponse {
//   final List<ExpenseClaimModel> expenseClaimList;
//   final ListRightsModel listRights;
//   SubmittedExpenseClaimResponse({
//     required this.expenseClaimList,
//     required this.listRights,
//   });
//
//   factory SubmittedExpenseClaimResponse.fromJson(Map<String, dynamic> json) {
//     return SubmittedExpenseClaimResponse(
//       expenseClaimList:
//           (json['data']['subLst'].isNotEmpty
//                   ? json['data']['subLst'] as List<dynamic>
//                   : <dynamic>[])
//               .map((e) => ExpenseClaimModel.fromJson(e))
//               .toList(),
//       listRights: ListRightsModel.fromJson(json['data']['rights'] ?? {}),
//     );
//   }
// }
import '../../../../models/listRights_model.dart';

class ExpenseClaimModel {
  // Fields from your existing model (for app use)
  int iEcid;
  String monthyear;
  String reqdate;
  String note;
  String amount;
  int allowanceCode;
  String crcode;
  double conrate;
  String expnam;
  String url;
  int cocode;
  int expenseClaimId;
  String expenseClaimName;
  String? month, year, empCode;
  String? employeeID;
  String? employeeName;
  String? currency;
  String? approveMonthYear;
  String? approveAmount;
  String? requestedDate;
  String? comment;

  ExpenseClaimModel({
    this.iEcid = 0,
    required this.monthyear,
    required this.reqdate,
    required this.note,
    required this.amount,
    required this.allowanceCode,
    required this.crcode,
    this.conrate = 0,
    required this.expnam,
    required this.url,
    this.cocode = 0,
    this.expenseClaimId = 0,
    this.expenseClaimName = '',
    this.employeeName,
    this.employeeID,
    this.currency,
    this.approveMonthYear,
    this.approveAmount,
    this.requestedDate,
    this.month,
    this.year,
    this.empCode,
    this.comment,
  });

  /// 🔄 Your toJson for submission – **DO NOT CHANGE**
  Map<String, dynamic> toJson() {
    return {
      'iEcid': iEcid,
      'monthyear': monthyear,
      'reqdate': reqdate,
      'note': note,
      'amount': amount,
      'alcode': allowanceCode,
      'crcode': crcode,
      'conrate': conrate,
      'expnam': expnam,
      'url': url,
      'cocode': cocode,
      'approveAmount': approveAmount,
    };
  }

  /// ✅ Parses only server response JSON
  factory ExpenseClaimModel.fromJson(Map<String, dynamic> json) {
    return ExpenseClaimModel(
      month: json['iClmnth']?.toString(),
      year: json['iClyear']?.toString(),
      empCode: json['iEmcode']?.toString(),

      expenseClaimName: json['sAlname'] ?? '',
      expenseClaimId: json['iClslno'] ?? 0,
      monthyear: json['monthYear'] ?? '',
      iEcid: json['iClslno'] ?? 0,
      reqdate: json['sCldate'].toString(),
      note: json['sClnote'] ?? '',
      amount: json['sClamnt'] ?? '',
      allowanceCode: json['iAlcode'] ?? 0,
      crcode: '',
      conrate: (json['lClcnrt'] ?? 0).toDouble(),
      expnam: json['sAlname'] ?? '',
      url: '',
      cocode: 0,
      approveMonthYear: json['aprMnthYearName'].toString(),
      approveAmount: json['lClappv'].toString(),
      employeeID: json['empId'].toString(),
      employeeName: json['empName'].toString(),
      currency: json['cCrcode'].toString(),
      requestedDate: json['sCldate'].toString(),
      comment:
          (json['lmComment'] ?? '').toString().isEmpty
              ? (json['prevComment'] ?? '').toString()
              : (json['lmComment'] ?? '').toString(),
    );
  }
}

//THIS is to fetch the response from the api !
class ExpenseClaimListResponse {
  final SubmittedExpenseClaimResponse submitted;
  final List<ExpenseClaimModel> approved;
  final List<ExpenseClaimModel> rejected;

  ExpenseClaimListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ExpenseClaimListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ExpenseClaimListResponse(
      submitted: SubmittedExpenseClaimResponse.fromJson(json),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ExpenseClaimModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ExpenseClaimModel.fromJson(e))
              .toList(),
    );
  }
}

class SubmittedExpenseClaimResponse {
  final List<ExpenseClaimModel> expenseClaimList;
  final ListRightsModel listRights;
  SubmittedExpenseClaimResponse({
    required this.expenseClaimList,
    required this.listRights,
  });

  factory SubmittedExpenseClaimResponse.fromJson(Map<String, dynamic> json) {
    return SubmittedExpenseClaimResponse(
      expenseClaimList:
          (json['data']['subLst'].isNotEmpty
                  ? json['data']['subLst'] as List<dynamic>
                  : <dynamic>[])
              .map((e) => ExpenseClaimModel.fromJson(e))
              .toList(),
      listRights: ListRightsModel.fromJson(json['data']['rights'] ?? {}),
    );
  }
}
