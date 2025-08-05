class DocumentModel {
  final String fileName; // maps from "valuefield"
  final String description; // maps from "textfield"
  final String fileKey; // maps from "keyID"

  DocumentModel({
    required this.fileName,
    required this.description,
    required this.fileKey,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      fileName: json['valuefield'] ?? '',
      description: json['textfield'] ?? '',
      fileKey: json['keyID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'valuefield': fileName, 'textfield': description, 'keyID': fileKey};
  }
}
