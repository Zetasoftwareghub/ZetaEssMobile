// todo api model
/*class BusinessGiftDetail {
  String? expenseDate;
  String? noOfGuests;
  String? companyName;
  String? amount;
  String? conversionRate;
  String? employeeAmount;
  String? jobNumber;
  String? requiredConversionRate;
  String? actualAmount;
  String? description;
  String? currency;
  String? giftId;

  BusinessGiftDetail({
    this.expenseDate,
    this.noOfGuests,
    this.companyName,
    this.amount,
    this.conversionRate,
    this.employeeAmount,
    this.jobNumber,
    this.requiredConversionRate,
    this.actualAmount,
    this.description,
    this.currency,
    this.giftId,
  });

  factory BusinessGiftDetail.fromJson(Map<String, dynamic> json) =>
      BusinessGiftDetail(
        expenseDate: json['expDate'],
        noOfGuests: json['noGusts'],
        companyName: json['cmpName'],
        amount: json['expAmount'],
        conversionRate: json['convRate'],
        employeeAmount: json['empAmnt'],
        jobNumber: json['jobNmbr'],
        requiredConversionRate: json['reqConvRate'],
        actualAmount: json['actAmt'],
        description: json['bgDesc'],
        currency: json['currency'],
        giftId: json['clgfid'],
      );

  Map<String, dynamic> toJson() => {
    'expDate': expenseDate,
    'noGusts': noOfGuests,
    'cmpName': companyName,
    'expAmount': amount,
    'convRate': conversionRate,
    'empAmnt': employeeAmount,
    'jobNmbr': jobNumber,
    'reqConvRate': requiredConversionRate,
    'actAmt': actualAmount,
    'bgDesc': description,
    'currency': currency,
    'clgfid': giftId,
  };
}

*/
//TODO  STATIC AI MODEL REMOVEEE == = = =

class BusinessGiftModel {
  final String id;
  final String date;
  final String giftNumber;
  final String description;
  final String numberOfGuests;
  final String guestCompanyName;
  final String currency;
  final String expenseAmount;
  final String conversionRate;
  final String requestedConversionRate;
  final String amountInEmployeeCurrency;
  final String costCenter;

  BusinessGiftModel({
    required this.id,
    required this.date,
    required this.giftNumber,
    required this.description,
    required this.numberOfGuests,
    required this.guestCompanyName,
    required this.currency,
    required this.expenseAmount,
    required this.conversionRate,
    required this.requestedConversionRate,
    required this.amountInEmployeeCurrency,
    required this.costCenter,
  });

  double get totalAmount => double.tryParse(amountInEmployeeCurrency) ?? 0.0;
}
