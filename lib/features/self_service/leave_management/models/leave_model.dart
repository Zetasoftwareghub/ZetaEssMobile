import 'package:zeta_ess/core/utils/date_utils.dart';

import '../../../../models/listRights_model.dart';
import '../controller/old_hrms_configuration_stuffs.dart';

class LeaveModel {
  final String? leaveFrom;
  final String? leaveTo;
  final String? leaveType;
  final String? leaveDays;
  final String? leaveId;

  // Additional fields from the new API
  final String? employeName;
  final String? employeId;
  final String? submitted;
  final String? note;
  final String? leaveCode;
  final String? emergencyContact;
  final String? emcode;
  final String? lRTPAC;
  final String? appRejComment;
  final String? lmComment;
  final String? prevComment;
  final String? cancelComment;

  //FOR edit
  String? editLeaveFrom,
      editLeaveTo,
      editReason,
      editContactValue,
      editAttachmentUrl,
      editAllowanceType;
  LeaveModel({
    this.leaveFrom,
    this.leaveTo,
    this.leaveType,
    this.leaveDays,
    this.leaveId,
    this.employeName,
    this.employeId,
    this.submitted,
    this.note,
    this.leaveCode,
    this.emergencyContact,
    this.emcode,
    this.lRTPAC,
    this.appRejComment,
    this.lmComment,
    this.prevComment,
    this.cancelComment,
    this.editLeaveFrom,
    this.editLeaveTo,
    this.editReason,
    this.editContactValue,
    this.editAttachmentUrl,
    this.editAllowanceType,
  });

  /// Old API mapping
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    /*

    SUBMITTED
     {
        "emcode": 31092,
        "lsslno": 58233,
        "dtsbmt": "2025-07-31T00:00:00",
        "lsrndy": 3,
        "dtfrm": "2028-05-08T00:00:00",
        "lsrdtf": "08/05/2028",
        "dtto": "2028-05-10T00:00:00",
        "lsrdtt": "10/05/2028",
        "lsstat": "Active",
        "eminid": "vi01",
        "emname": "Jon Snow",
        "dpname": "88887777",
        "diname": "343",
        "lstype": " Pending By Stephen Nedumpally",
        "lsnote": "zbz",
        "lmname": "Michael M Scofield",
        "levname": "vi casual leave"
      },


    APPROVED
    * {
        "emcode": 31093,
        "laslno": 26392,
        "lsslno": 58250,
        "ladate": "25/08/2025",
        "dtapr": "2025-08-25T00:00:00",
        "landys": 1,
        "lanote": "approved test",
        "ladtfm": "07/02/2029",
        "dtfrm": "2029-02-07T00:00:00",
        "ladtto": "07/02/2029",
        "dtto": "2029-02-07T00:00:00",
        "eminid": "vi02",
        "emname": "Marco .",
        "dpname": "88887777",
        "lsdate": "20/08/2025",
        "dtsbmt": "2025-08-20T00:00:00",
        "lmname": "Jon  Snow",
        "lvsts": "Approved",
        "levname": "vi Resumption"
      },
    *
    * REJECTED
    *
    *     {
        "emcode": 31092,
        "ljslno": 12681,
        "lsslno": 58194,
        "ljdate": "24/07/2025",
        "dtrjct": "2025-07-24T00:00:00",
        "ljndys": 3.5,
        "ljnote": "reject",
        "ljstat": "Y",
        "ljdtfm": "25/06/2028",
        "dtfrm": "2028-06-25T00:00:00",
        "ljdtto": "28/06/2028",
        "dtto": "2028-06-28T00:00:00",
        "eminid": "vi01",
        "emname": "Jon Snow",
        "dpname": "88887777",
        "lsdate": "24/07/2025",
        "dtsbmt": "2025-07-24T00:00:00",
        "lmname": "Marco  .",
        "levname": "vi casual leave"
      },
      *
      * Cancelled
      *
      * {
        "emcode": 31092,
        "lcslno": 5210,
        "lsslno": 57171,
        "lcdate": "21/07/2025",
        "dtcncl": "2025-07-21T00:00:00",
        "lsrndy": 1,
        "lcnote": "",
        "lcstat": "Y",
        "lsrdtf": "31/07/2025",
        "dtfrm": "2025-07-31T00:00:00",
        "lsrdtt": "31/07/2025",
        "dtto": "2025-07-31T00:00:00",
        "eminid": "vi01",
        "emname": "Jon Snow",
        "dpname": "88887777",
        "lsdate": "09/07/2025",
        "dtsbmt": "2025-07-09T00:00:00",
        "lmname": "vishnu",
        "levname": "annual leave3"
      },
    *
    * */

    return LeaveModel(
      leaveId: json['lsslno'].toString(),
      leaveFrom: convertRawDateToString(json['dtfrm']),
      leaveTo: convertRawDateToString(json['dtto']),
      //TODO 3variables for leave days because in each api its different
      leaveDays:
          (json['lsrndy'] ?? json['landys'] ?? json['ljndys']).toString(),
      leaveType: json['levname'].toString(),

      // TODO this for edit leave
      editLeaveFrom: json['dLsrdtf'].toString(),
      editLeaveTo: json['dLsrdtt'].toString(),
      submitted: json['dLsdate'].toString(),

      editReason: json?['lsnote']?.toString(),
      editContactValue: json?['lscont']?.toString(),
      editAttachmentUrl: json?['leaveName']?.toString(),
      editAllowanceType:
          json?['lsRtAl']?.toString() == "null"
              ? null
              : json?['LsRtAl']?.toString(),
      leaveCode: json['ltCode'], //leave id i think
    );
  }

  /// New Leave Detail API mapping
  factory LeaveModel.fromLeaveDetailApi(Map<String, dynamic> json) {
    return LeaveModel(
      leaveFrom: json['dLsrdtf'].toString(),
      leaveTo: json['dLsrdtt'].toString(),
      leaveType: json['leaveName'].toString(),
      leaveDays: json['lLsrndy'].toString(),
      leaveId: json['iLsslno'].toString(),
      employeName: json['empName'].toString(),
      employeId: json['sEmpid'].toString(),
      submitted: json['dLsdate'].toString(),
      note: json['lsnote'].toString(),
      leaveCode: json['ltCode'].toString(),
      emergencyContact: json['lscont'].toString(),
      emcode: json['iEmcode'].toString(),
      lRTPAC: json['lrtpac'].toString(),
      appRejComment: json['appRejComment'].toString(),
      lmComment: json['lmComment'].toString(),
      prevComment: json['prevComment'].toString(),
      cancelComment: json['cancelComment'].toString(),
    );
  }
}

class SubmittedLeaveResponse {
  final List<LeaveModel> leaves;
  final ListRightsModel listRights;
  SubmittedLeaveResponse({required this.leaves, required this.listRights});

  factory SubmittedLeaveResponse.fromJson(Map<String, dynamic> json) {
    return SubmittedLeaveResponse(
      leaves:
          (json['data'].isNotEmpty
                  ? json['data'][0] as List<dynamic>
                  : <dynamic>[])
              .map((e) => LeaveModel.fromJson(e))
              .toList(),
      listRights: ListRightsModel.fromJson(json['rights'] ?? {}),
    );
  }
}

class LeaveTypeModel {
  String? leaveType;
  String? leaveTypeId;
  String? ltlieu;

  LeaveTypeModel({this.leaveType, this.leaveTypeId, this.ltlieu});

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      leaveType: json['textfield'].toString(),
      leaveTypeId: json['valuefield'].toString(),
      ltlieu: json['officialMail'].toString(),
    );
  }
}

class LeaveEditResponse {
  final List<LeaveConfigurationEditData> subLst;
  final List<LeaveConfigurationEditData> appLst;
  final List<LeaveConfigurationEditData> canLst;

  LeaveEditResponse({
    required this.subLst,
    required this.appLst,
    required this.canLst,
  });

  factory LeaveEditResponse.fromEditApi(Map<String, dynamic> json) {
    return LeaveEditResponse(
      subLst:
          (json['subLst'] as List<dynamic>)
              .map((e) => LeaveConfigurationEditData.fromJson(e))
              .toList(),
      appLst:
          (json['appLst'] as List<dynamic>)
              .map((e) => LeaveConfigurationEditData.fromJson(e))
              .toList(),
      canLst:
          (json['canLst'] as List<dynamic>)
              .map((e) => LeaveConfigurationEditData.fromJson(e))
              .toList(),
    );
  }
}
