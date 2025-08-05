class SubmitOtherRequestModel {
  String? rqtscd;
  String? rtenvl;
  String? rtcont;
  String? rtflnm;
  String? rtflpth;
  String? rtescd;
  // String? fieldType;

  SubmitOtherRequestModel({
    this.rqtscd,
    this.rtenvl,
    this.rtcont,
    this.rtflnm,
    this.rtflpth,
    this.rtescd,
    // this.fieldType,
  });

  Map toJson() => {
    'rqtscd': rqtscd,
    'rtenvl': rtenvl,
    'rtcont': rtcont,
    'rtflnm': rtflnm,
    'rtflpth': rtflpth,
    'rtescd': rtescd,
    // 'fieldType': fieldType,
  };
}
