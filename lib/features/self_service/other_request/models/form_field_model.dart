class FormFieldModel {
  final String fieldName; // Field name/label
  final int fieldID; // Field ID used in code
  final String fieldType; // Field type (S=String, D=Date, N=Number)
  final int
  fieldWidget; // Form field type (1=Text, 2=TextArea, 3=Radio, 4=Dropdown, 5=Checkbox, 6=File)
  final String
  multiValuesCommas; // Options data for dropdown/radio/checkbox (comma separated)
  final String requiredField; // Required field type (M=Mandatory, O=Optional)

  FormFieldModel({
    required this.fieldName,
    required this.fieldID,
    required this.fieldType,
    required this.fieldWidget,
    required this.multiValuesCommas,
    required this.requiredField,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      fieldName: json['rqflnm'] ?? '',
      fieldID: json['rqtscd'] ?? 0,
      fieldType: json['rqflty'] ?? '',
      fieldWidget: json['rpiptp'] ?? 0,
      multiValuesCommas: json['rpipdt'] ?? '',
      requiredField: json['rqfdtp'] ?? '',
    );
  }

  bool get isRequired => requiredField == 'M';
  bool get isOptional => requiredField == 'O';
  bool get isDateField => fieldType == 'D';
  bool get isNumberField => fieldType == 'N';
  bool get isStringField => fieldType == 'S';

  FormFieldType get fieldTypeCases {
    switch (fieldWidget) {
      case 1:
        return FormFieldType.textField;
      case 2:
        return FormFieldType.textArea;
      case 3:
        return FormFieldType.radio;
      case 4:
        return FormFieldType.dropdown;
      case 5:
        return FormFieldType.checkbox;
      case 6:
        return FormFieldType.fileUpload;
      default:
        return FormFieldType.textField;
    }
  }

  List<String> get options {
    return multiValuesCommas.isEmpty ? [] : multiValuesCommas.split(',');
  }

  String generateFieldId() {
    return "${fieldName.toLowerCase().replaceAll(" ", "_")}_$fieldName";
  }
}

enum FormFieldType {
  textField,
  textArea,
  radio,
  dropdown,
  checkbox,
  fileUpload,
}

// Response model for the complete form
class FormResponseModel {
  final List<FormFieldModel> formFieldList;
  final List appLst;
  final List subLst;

  FormResponseModel({
    required this.formFieldList,
    required this.appLst,
    required this.subLst,
  });

  factory FormResponseModel.fromJson(Map<String, dynamic> json) {
    return FormResponseModel(
      formFieldList:
          (json['canLst'] as List<dynamic>?)
              ?.map((item) => FormFieldModel.fromJson(item))
              .toList() ??
          [],
      appLst: (json['appLst'] as List<dynamic>?) ?? [],
      subLst: (json['subLst'] as List<dynamic>?) ?? [],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {'canLst': canLst.map((field) => field.toJson()).toList()};
  // }
}
