import '../../../../core/providers/userContext_provider.dart';

class CancelLeaveParams {
  final UserContext userContext;
  final String? lsslno;
  final String? laslno;
  final String? clslno;

  CancelLeaveParams({
    required this.userContext,
    this.lsslno,
    this.laslno,
    this.clslno,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CancelLeaveParams &&
            runtimeType == other.runtimeType &&
            userContext == other.userContext &&
            lsslno == other.lsslno &&
            laslno == other.laslno &&
            clslno == other.clslno;
  }

  @override
  int get hashCode =>
      userContext.hashCode ^
      lsslno.hashCode ^
      laslno.hashCode ^
      clslno.hashCode;
}

class ApproveRejectCancelLeaveParams {
  final UserContext userContext;
  final String strapprflg; // approve/reject flag
  final String lsslno;
  final String strEmcode; //approver emcode
  final String username;
  final String strNote;
  final String strlaslno;
  final String suconn;
  final String? ltcode;
  final String emcode;
  final String? baseDirectory;

  const ApproveRejectCancelLeaveParams({
    required this.userContext,
    required this.strapprflg,
    required this.lsslno,
    required this.strEmcode,
    required this.username,
    required this.strNote,
    required this.strlaslno,
    required this.suconn,
    required this.emcode,
    this.ltcode,
    this.baseDirectory,
  });

  Map<String, dynamic> toJson() {
    return {
      "strapprflg": strapprflg,
      "lsslno": lsslno,
      "strEmcode": strEmcode,
      "username": username,
      "strNote": strNote,
      "strlaslno": strlaslno,
      "suconn": suconn,
      "ltcode": ltcode ?? "",
      "emcode": emcode,
      "baseDirectory": baseDirectory ?? "",
    };
  }
}
