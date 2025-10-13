class VersionModel {
  final String latestVersion;
  final bool forceUpdate;
  final String message;

  VersionModel({
    required this.latestVersion,
    required this.forceUpdate,
    required this.message,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      latestVersion: json['latestVersion'] ?? '',
      forceUpdate: json['forceUpdate'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
