class ClaimDetail {
  String? expenseDate;
  String? description;
  String? value;
  String? unitName;
  String? currency;
  String? amount;
  String? conversionRate;
  String? employeeAmount;
  String? jobNumber;
  String? actualAmount;
  String? requiredConversionRate;
  String? analysisText;
  String? analysisValue;
  String? detailId;

  ClaimDetail({
    this.expenseDate,
    this.description,
    this.value,
    this.unitName,
    this.currency,
    this.amount,
    this.conversionRate,
    this.employeeAmount,
    this.jobNumber,
    this.actualAmount,
    this.requiredConversionRate,
    this.analysisText,
    this.analysisValue,
    this.detailId,
  });

  factory ClaimDetail.fromJson(Map<String, dynamic> json) => ClaimDetail(
    expenseDate: json['expDate'],
    description: json['expDescription'],
    value: json['expValue'],
    unitName: json['expUnitName'],
    currency: json['currency'],
    amount: json['expAmount'],
    conversionRate: json['convRate'],
    employeeAmount: json['empAmnt'],
    jobNumber: json['jobNmbr'],
    actualAmount: json['actAmt'],
    requiredConversionRate: json['reqConvRate'],
    analysisText: json['expAnlysText'],
    analysisValue: json['expAnlysValue'],
    detailId: json['exdtid'],
  );

  Map<String, dynamic> toJson() => {
    'expDate': expenseDate,
    'expDescription': description,
    'expValue': value,
    'expUnitName': unitName,
    'currency': currency,
    'expAmount': amount,
    'convRate': conversionRate,
    'empAmnt': employeeAmount,
    'jobNmbr': jobNumber,
    'actAmt': actualAmount,
    'reqConvRate': requiredConversionRate,
    'expAnlysText': analysisText,
    'expAnlysValue': analysisValue,
    'exdtid': detailId,
  };
}

class ClaimAttachmentModel {
  String? mediaFile;
  String? fileName;

  ClaimAttachmentModel({this.mediaFile, this.fileName});

  factory ClaimAttachmentModel.fromJson(Map<String, dynamic> json) =>
      ClaimAttachmentModel(
        mediaFile: json['mediaFile'],
        fileName: json['fileName'],
      );

  Map<String, dynamic> toJson() => {
    'mediaFile': mediaFile,
    'fileName': fileName,
  };
}
