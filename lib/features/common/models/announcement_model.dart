class AnnouncementModel {
  final int announcementCode;
  final String announcementTitle;
  final String announcementMessage; // now plain text
  final String announcementStatus;
  final int announcementCreatedBy;
  final DateTime announcementCreatedDate;

  AnnouncementModel({
    required this.announcementCode,
    required this.announcementTitle,
    required this.announcementMessage,
    required this.announcementStatus,
    required this.announcementCreatedBy,
    required this.announcementCreatedDate,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final rawHtml = json['anmesg'] ?? '';
    final plainText = _stripHtml(rawHtml);

    return AnnouncementModel(
      announcementCode: json['ancode'],
      announcementTitle: json['antitl'] ?? '',
      announcementMessage: plainText,
      announcementStatus: json['anstat'] ?? '',
      announcementCreatedBy: json['ancrby'] ?? 0,
      announcementCreatedDate: DateTime.parse(json['ancrdt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ancode': announcementCode,
      'antitl': announcementTitle,
      'anmesg': announcementMessage,
      'anstat': announcementStatus,
      'ancrby': announcementCreatedBy,
      'ancrdt': announcementCreatedDate.toIso8601String(),
    };
  }

  /// Static utility method to remove HTML tags
  static String _stripHtml(String html) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return html.replaceAll(regex, '').replaceAll('&nbsp;', ' ').trim();
  }
}
