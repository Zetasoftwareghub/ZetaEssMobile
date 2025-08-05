class PunchModel {
  String? punchDate;
  String? punchTime;
  String? punchType;
  String? punchLocation;
  String? punchMode;

  PunchModel({
    this.punchDate,
    this.punchTime,
    this.punchType,
    this.punchLocation,
    this.punchMode,
  });

  PunchModel.fromJson(Map<String, dynamic> json) {
    punchDate = json['valuefield'] as String?;
    punchTime = json['officialMail'] as String?;
    punchType = json['textfield'] as String?;
    punchLocation = json['keyID'] as String?;
    punchMode = json['punchmd'] as String?;
  }
}

class EligibleLocations {
  List? locations;
  double? distance;
  EligibleLocations({this.locations, this.distance});

  factory EligibleLocations.fromJson(Map<String, dynamic> json) {
    double? d;
    json['keyID'] == "" ? d = 0 : d = double.parse(json['keyID']);
    return EligibleLocations(
      locations: json['locations'] as List?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}
