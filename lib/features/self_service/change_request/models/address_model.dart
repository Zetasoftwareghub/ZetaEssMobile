class AddressContactModel {
  final int? employeeCode;

  // current address
  final String? addressLine1;
  final String? streetName;
  final String? townCityName;
  final String? stateName;
  final String? countryCode;
  final String? postBox;
  final String? phoneNumber;
  final String? mobileNumber;
  final String? emailId;

  // home address
  final String? homeAddressLine1;
  final String? homeStreetName;
  final String? homeTownCityName;
  final String? homeStateName;
  final String? homeCountryCode;
  final String? homePostBox;

  // emergency
  final String? emergencyPerson;
  final String? emergencyRelation;
  final String? emergencyPhone;
  final String? emergencyEmail;

  final String? lastModifiedDate;

  // others
  final String? personalPhoneNo;
  final String? personalMobileNo;
  final String? nextOfKinName;
  final String? personalMailId;
  final String? nextOfKinPhone;

  final String? emergencyPerson1;
  final String? emergencyRelation1;
  final String? emergencyPhone1;
  final String? emergencyEmail1;

  final String? emergencyPerson2;
  final String? emergencyRelation2;
  final String? emergencyPhone2;
  final String? emergencyEmail2;

  List<String?> get persons => [
    emergencyPerson,
    emergencyPerson1,
    emergencyPerson2,
  ];
  List<String?> get relations => [
    emergencyRelation,
    emergencyRelation1,
    emergencyRelation2,
  ];
  List<String?> get phones => [
    emergencyPhone,
    emergencyPhone1,
    emergencyPhone2,
  ];
  List<String?> get emails => [
    emergencyEmail,
    emergencyEmail1,
    emergencyEmail2,
  ];

  AddressContactModel({
    this.employeeCode,
    this.addressLine1,
    this.streetName,
    this.townCityName,
    this.stateName,
    this.countryCode,
    this.postBox,
    this.phoneNumber,
    this.mobileNumber,
    this.emailId,
    this.homeAddressLine1,
    this.homeStreetName,
    this.homeTownCityName,
    this.homeStateName,
    this.homeCountryCode,
    this.homePostBox,
    this.emergencyPerson,
    this.emergencyRelation,
    this.emergencyPhone,
    this.emergencyEmail,
    this.lastModifiedDate,
    this.personalPhoneNo,
    this.personalMobileNo,
    this.nextOfKinName,
    this.personalMailId,
    this.nextOfKinPhone,
    this.emergencyPerson1,
    this.emergencyRelation1,
    this.emergencyPhone1,
    this.emergencyEmail1,
    this.emergencyPerson2,
    this.emergencyRelation2,
    this.emergencyPhone2,
    this.emergencyEmail2,
  });

  factory AddressContactModel.fromJson(Map<String, dynamic> json) {
    return AddressContactModel(
      employeeCode: json['emcode'],
      addressLine1: json['eccad1'],
      streetName: json['eccad2'],
      townCityName: json['eccad3'],
      stateName: json['eccad4'],
      countryCode: json['eccccd'],
      postBox: json['eccpbx'],
      phoneNumber: json['eccphn'],
      mobileNumber: json['eccmbn'],
      emailId: json['ecmaid'],
      homeAddressLine1: json['ecpad1'],
      homeStreetName: json['ecpad2'],
      homeTownCityName: json['ecpad3'],
      homeStateName: json['ecpad4'],
      homeCountryCode: json['ecpccd'],
      homePostBox: json['ecppbx'],
      emergencyPerson: json['ececpe'],
      emergencyRelation: json['ececpr'],
      emergencyPhone: json['ececph'],
      emergencyEmail: json['ececid'],
      lastModifiedDate: json['eclmdt'],
      personalPhoneNo: json['eccpnp'],
      personalMobileNo: json['eccmnp'],
      nextOfKinName: json['ecenop'],
      personalMailId: json['ecpmid'],
      nextOfKinPhone: json['ecnkph'],
      emergencyPerson1: json['ececpe1'],
      emergencyRelation1: json['ececpr1'],
      emergencyPhone1: json['ececph1'],
      emergencyEmail1: json['ececid1'],
      emergencyPerson2: json['ececpe2'],
      emergencyRelation2: json['ececpr2'],
      emergencyPhone2: json['ececph2'],
      emergencyEmail2: json['ececid2'],
    );
  }

  Map<String, dynamic> toJson() => {
    'emcode': employeeCode,
    'eccad1': addressLine1,
    'eccad2': streetName,
    'eccad3': townCityName,
    'eccad4': stateName,
    'eccccd': countryCode,
    'eccpbx': postBox,
    'eccphn': phoneNumber,
    'eccmbn': mobileNumber,
    'ecmaid': emailId,
    'ecpad1': homeAddressLine1,
    'ecpad2': homeStreetName,
    'ecpad3': homeTownCityName,
    'ecpad4': homeStateName,
    'ecpccd': homeCountryCode,
    'ecppbx': homePostBox,
    'ececpe': emergencyPerson,
    'ececpr': emergencyRelation,
    'ececph': emergencyPhone,
    'ececid': emergencyEmail,
    'eclmdt': lastModifiedDate,
    'eccpnp': personalPhoneNo,
    'eccmnp': personalMobileNo,
    'ecenop': nextOfKinName,
    'ecpmid': personalMailId,
    'ecnkph': nextOfKinPhone,
    'ececpe1': emergencyPerson1,
    'ececpr1': emergencyRelation1,
    'ececph1': emergencyPhone1,
    'ececid1': emergencyEmail1,
    'ececpe2': emergencyPerson2,
    'ececpr2': emergencyRelation2,
    'ececph2': emergencyPhone2,
    'ececid2': emergencyEmail2,
  };
}
