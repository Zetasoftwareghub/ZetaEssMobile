//TODO  STATIC AI MODEL REMOVEEE == = = =

class AdvancePaymentModel {
  final String id;
  final String paymentNumber;
  final String currency;
  final String amount;
  final String conversionRate;
  final String amountInEmployeeCurrency;

  AdvancePaymentModel({
    required this.id,
    required this.paymentNumber,
    required this.currency,
    required this.amount,
    required this.conversionRate,
    required this.amountInEmployeeCurrency,
  });

  double get totalAmount => double.tryParse(amountInEmployeeCurrency) ?? 0.0;
}

// todo api model
// class CashAdvanceDetail {
//   String? cashAdvance;
//   String? dummyAdvance;
//
//   CashAdvanceDetail({this.cashAdvance, this.dummyAdvance});
//
//   factory CashAdvanceDetail.fromJson(Map<String, dynamic> json) =>
//       CashAdvanceDetail(
//         cashAdvance: json['cshAdvnc'],
//         dummyAdvance: json['dummyAdvnc'],
//       );
//
//   Map<String, dynamic> toJson() => {
//     'cshAdvnc': cashAdvance,
//     'dummyAdvnc': dummyAdvance,
//   };
// }
