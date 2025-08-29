class SuggestionModel {
  final String? suconn;
  final int id;
  final String? emcode;
  final String? dpDate;
  final String? subject;
  final String? description;
  final String? drpType;
  final String? baseDirectory;
  final String? mediafile;
  final String? filename;

  SuggestionModel({
    required this.suconn,
    required this.id,
    required this.emcode,
    required this.dpDate,
    required this.subject,
    required this.description,
    required this.drpType,
    required this.baseDirectory,
    required this.mediafile,
    required this.filename,
  });

  factory SuggestionModel.fromJson(Map<String?, dynamic> json) {
    return SuggestionModel(
      suconn: json['suconn'] ?? '',
      id: json['id'] ?? 0,
      emcode: json['emcode'] ?? '0',
      dpDate: json['dpDate'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      drpType: json['drpType'] ?? '',
      baseDirectory: json['baseDirectory'] ?? '',
      mediafile: json['mediafile'] ?? '',
      filename: json['filename'] ?? '',
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      'suconn': suconn,
      'id': id,
      'emcode': emcode,
      'dpDate': dpDate,
      'subject': subject,
      'description': description,
      'drpType': drpType,
      'baseDirectory': baseDirectory,
      'mediafile': mediafile,
      'filename': filename,
    };
  }
}
