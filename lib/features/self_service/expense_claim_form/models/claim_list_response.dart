import 'package:zeta_ess/models/listRights_model.dart';

class ClaimListResponse {
  final List<ClaimListData> subLst; // submitted
  final List<ClaimListData> appLst; // approved
  final List<ClaimListData> rejLst; // rejected
  final List<ClaimListData> canLst; // cancelled
  final ListRightsModel rights;

  ClaimListResponse({
    required this.subLst,
    required this.appLst,
    required this.rejLst,
    required this.canLst,
    required this.rights,
  });

  factory ClaimListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;

    return ClaimListResponse(
      subLst: _parseList(data, 0),
      appLst: _parseList(data, 1),
      rejLst: _parseList(data, 2),
      canLst: _parseList(data, 3),
      rights: ListRightsModel.fromJson(json['rights']),
    );
  }

  /// Helper to extract inner lists safely
  static List<ClaimListData> _parseList(List data, int index) {
    if (data.length > index) {
      return (data[index] as List)
          .map((e) => ClaimListData.fromJson(e))
          .toList();
    }
    return [];
  }
}

class ClaimListData {
  ClaimListData({
    num? expenseId,
    String? employeeId,
    String? requestDate,
    num? requestNumber,
    String? createdByName,
    String? employeeName,
    dynamic approvedBy,
    dynamic approvedDate,
    String? remarks,
    String? approvalStatus,
    num? paidAmount,
    String? currencyName,
    num? currencyDecimal,
  }) {
    _expenseId = expenseId;
    _employeeId = employeeId;
    _requestDate = requestDate;
    _requestNumber = requestNumber;
    _createdByName = createdByName;
    _employeeName = employeeName;
    _approvedBy = approvedBy;
    _approvedDate = approvedDate;
    _remarks = remarks;
    _approvalStatus = approvalStatus;
    _paidAmount = paidAmount;
    _currencyName = currencyName;
    _currencyDecimal = currencyDecimal;
  }

  ClaimListData.fromJson(dynamic json) {
    _expenseId = json['exmtid'];
    _employeeId = json['eminid'];
    _requestDate = json['reqdat'];
    _requestNumber = json['reqnum'];
    _createdByName = json['cremnm'];
    _employeeName = json['emname'];
    _approvedBy = json['atapby'];
    _approvedDate = json['tdapdt'];
    _remarks = json['rqrmrk'];
    _approvalStatus = json['apstat'];
    _paidAmount = json['padamt'];
    _currencyName = json['emcrnm'];
    _currencyDecimal = json['crdcml'];
  }

  num? _expenseId;
  String? _employeeId;
  String? _requestDate;
  num? _requestNumber;
  String? _createdByName;
  String? _employeeName;
  dynamic _approvedBy;
  dynamic _approvedDate;
  String? _remarks;
  String? _approvalStatus;
  num? _paidAmount;
  String? _currencyName;
  num? _currencyDecimal;

  // Getters
  num? get expenseId => _expenseId;
  String? get employeeId => _employeeId;
  String? get requestDate => _requestDate;
  num? get requestNumber => _requestNumber;
  String? get createdByName => _createdByName;
  String? get employeeName => _employeeName;
  dynamic get approvedBy => _approvedBy;
  dynamic get approvedDate => _approvedDate;
  String? get remarks => _remarks;
  String? get approvalStatus => _approvalStatus;
  num? get paidAmount => _paidAmount;
  String? get currencyName => _currencyName;
  num? get currencyDecimal => _currencyDecimal;

  // CopyWith
  ClaimListData copyWith({
    num? expenseId,
    String? employeeId,
    String? requestDate,
    num? requestNumber,
    String? createdByName,
    String? employeeName,
    dynamic approvedBy,
    dynamic approvedDate,
    String? remarks,
    String? approvalStatus,
    num? paidAmount,
    String? currencyName,
    num? currencyDecimal,
  }) => ClaimListData(
    expenseId: expenseId ?? _expenseId,
    employeeId: employeeId ?? _employeeId,
    requestDate: requestDate ?? _requestDate,
    requestNumber: requestNumber ?? _requestNumber,
    createdByName: createdByName ?? _createdByName,
    employeeName: employeeName ?? _employeeName,
    approvedBy: approvedBy ?? _approvedBy,
    approvedDate: approvedDate ?? _approvedDate,
    remarks: remarks ?? _remarks,
    approvalStatus: approvalStatus ?? _approvalStatus,
    paidAmount: paidAmount ?? _paidAmount,
    currencyName: currencyName ?? _currencyName,
    currencyDecimal: currencyDecimal ?? _currencyDecimal,
  );

  // JSON
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exmtid'] = _expenseId;
    map['eminid'] = _employeeId;
    map['reqdat'] = _requestDate;
    map['reqnum'] = _requestNumber;
    map['cremnm'] = _createdByName;
    map['emname'] = _employeeName;
    map['atapby'] = _approvedBy;
    map['tdapdt'] = _approvedDate;
    map['rqrmrk'] = _remarks;
    map['apstat'] = _approvalStatus;
    map['padamt'] = _paidAmount;
    map['emcrnm'] = _currencyName;
    map['crdcml'] = _currencyDecimal;
    return map;
  }
}
