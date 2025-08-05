class ResumptionDetailModel {
  final String? lsrndy;
  final String? leaveType;
  final String? laslno;
  final String? lsflag;
  final String? redate;
  final String? renote;
  final String? emcode;
  final String? lsrdtf;
  final String? lsrdtt;
  final String? recrdt;
  final String? dates;
  final String? clfile;
  final String? clfltp;
  final String? rewkmt;
  final String? eminid;
  final String? emname;
  final String? dpname;
  final String? diname;
  final String? dename;
  final String? emdojn;
  final String? lnname;
  final String? rqemcd;
  final String? attachmentUrl;
  final String? lmComment;
  final String? appRejComment;
  final String? prevComment;

  ResumptionDetailModel({
    required this.lsrndy,
    required this.leaveType,
    required this.laslno,
    required this.lsflag,
    required this.redate,
    required this.renote,
    required this.emcode,
    required this.lsrdtf,
    required this.lsrdtt,
    required this.recrdt,
    required this.dates,
    required this.clfile,
    required this.clfltp,
    required this.rewkmt,
    required this.eminid,
    required this.emname,
    required this.dpname,
    required this.diname,
    required this.dename,
    required this.emdojn,
    required this.lnname,
    required this.rqemcd,
    required this.attachmentUrl,
    required this.lmComment,
    required this.appRejComment,
    required this.prevComment,
  });

  factory ResumptionDetailModel.fromJson(Map<String?, dynamic> json) {
    return ResumptionDetailModel(
      lsrndy: json["lsrndy"].toString(),
      leaveType: json["leaveType"].toString(),
      laslno: json["laslno"].toString(),
      lsflag: json["lsflag"].toString(),
      redate: json["redate"].toString(),
      renote: json["renote"].toString(),
      emcode: json["emcode"].toString(),
      lsrdtf: json["lsrdtf"].toString(),
      lsrdtt: json["lsrdtt"].toString(),
      recrdt: json["recrdt"].toString(),
      dates: json["dates"].toString(),
      clfile: json["clfile"].toString(),
      clfltp: json["clfltp"].toString(),
      rewkmt: json["rewkmt"].toString(),
      eminid: json["eminid"].toString(),
      emname: json["emname"].toString(),
      dpname: json["dpname"].toString(),
      diname: json["diname"].toString(),
      dename: json["dename"].toString(),
      emdojn: json["emdojn"].toString(),
      lnname: json["lnname"].toString(),
      rqemcd: json["rqemcd"].toString(),
      attachmentUrl: json["attachmentUrl"].toString(),
      lmComment: json["lmComment"].toString(),
      appRejComment: json["appRejComment"].toString(),
      prevComment: json["prevComment"].toString(),
    );
  }
}
