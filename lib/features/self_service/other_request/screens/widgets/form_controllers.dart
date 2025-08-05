// // Form Controller
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
//
// import '../../models/submit_other_request_model.dart';
//
// // Form Controller
// class FormController {
//   Map<String, dynamic> _formData = {};
//
//   Map<String, dynamic> get formData => _formData;
//
//   void initializeFormData(List<dynamic> forms) {
//     _formData.clear();
//     for (var form in forms) {
//       _formData[_generateFieldId(form)] = "";
//     }
//   }
//
//   void updateFormData(String fieldId, dynamic value) {
//     _formData[fieldId] = value ?? "";
//   }
//
//   String getFieldValue(String fieldId) {
//     return _formData[fieldId]?.toString() ?? "";
//   }
//
//   void toggleCheckboxOption(String fieldId, String option, bool isSelected) {
//     final selectedOptions = getFieldValue(fieldId).split(',');
//
//     if (isSelected) {
//       selectedOptions.add(option);
//     } else {
//       selectedOptions.remove(option);
//     }
//
//     final newValue = selectedOptions.where((e) => e.isNotEmpty).join(',');
//     updateFormData(fieldId, newValue);
//   }
//
//   bool isOptionSelected(String fieldId, String option) {
//     final selectedOptions = getFieldValue(fieldId).split(',');
//     return selectedOptions.contains(option);
//   }
//
//   List<SubmitOtherRequestModel> buildSubmissionData(
//     List<SubmitOtherRequestModel> filesData,
//   ) {
//     final formData = <SubmitOtherRequestModel>[];
//     print(_formData);
//     print("_formData");
//     _formData.forEach((key, value) {
//       final rqtscd = _extractRqtscd(key);
//       final fileData = filesData.firstWhere(
//         (file) => file.rqtscd == key,
//         orElse:
//             () => SubmitOtherRequestModel(
//               rqtscd: "",
//               rtenvl: "",
//               rtcont: "",
//               rtflnm: "",
//             ),
//       );
//       print(rqtscd);
//       print(value.toString());
//       print('value.toString()');
//       print(fileData.rtflnm);
//       print("fileData.rtflnm");
//       formData.add(
//         SubmitOtherRequestModel(
//           rqtscd: rqtscd,
//           rtenvl: value.toString(),
//           rtcont: fileData.rtcont ?? "",
//           rtflnm: fileData.rtflnm ?? "",
//           rtescd: "0",
//         ),
//       );
//     });
//
//     return formData;
//   }
//
//   String _generateFieldId(dynamic item) {
//     return "${item['rqflnm'].toString().toLowerCase().replaceAll(" ", "_")}_${item['Rqtscd']}";
//   }
//
//   String _extractRqtscd(String key) {
//     print(key);
//     print('splitttt');
//     try {
//       final parts = key.split('_');
//       return parts.last;
//     } catch (e) {
//       return "0";
//     }
//   }
// }
//
// // File Controller
// class FileController {
//   static const List<String> _allowedFileExtensions = [
//     'jpg',
//     'jpeg',
//     'pdf',
//     'doc',
//     'png',
//   ];
//   static const List<String> _imageExtensions = ['jpg', 'jpeg', 'png'];
//   static const List<String> _documentExtensions = ['pdf', 'doc'];
//
//   List<SubmitOtherRequestModel> _filesData = [];
//   final Function(String, SubmitOtherRequestModel) onFileChanged;
//   final Function(String) onFileRemoved;
//
//   FileController({required this.onFileChanged, required this.onFileRemoved});
//
//   List<SubmitOtherRequestModel> get filesData => _filesData;
//
//   Future<void> pickFile(String fieldId) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: _allowedFileExtensions,
//       );
//
//       if (result != null) {
//         await _processSelectedFile(result.files.first, fieldId);
//       }
//     } catch (e) {
//       // Handle error appropriately
//       print('Error picking file: $e');
//     }
//   }
//
//   Future<void> _processSelectedFile(PlatformFile file, String fieldId) async {
//     final fileExtension = file.extension ?? '';
//     final base64Content = await _convertFileToBase64(
//       File(file.path!),
//       fileExtension,
//     );
//     final fileName = file.name.split('.').first;
//
//     final fileData = SubmitOtherRequestModel(
//       rqtscd: fieldId,
//       rtenvl: fileName,
//       rtcont: base64Content,
//       rtflnm: fileExtension,
//     );
//
//     _filesData.add(fileData);
//     onFileChanged(fieldId, fileData);
//   }
//
//   Future<String> _convertFileToBase64(File file, String extension) async {
//     if (_imageExtensions.contains(extension)) {
//       // TODO: Implement image conversion
//       final bytes = await file.readAsBytes();
//       return base64Encode(bytes);
//     } else if (_documentExtensions.contains(extension)) {
//       final bytes = await file.readAsBytes();
//       return base64Encode(bytes);
//     }
//     return '';
//   }
//
//   bool hasFileUploaded(String fieldId) {
//     return _filesData.any((file) => file.rqtscd == fieldId);
//   }
//
//   void removeFile(String fieldId) {
//     _filesData.removeWhere((file) => file.rqtscd == fieldId);
//     onFileRemoved(fieldId);
//   }
// }
//
// // Date Controller
// class DateController {
//   final String? restorationId;
//   final Function(String, String) onDateSelected;
//
//   String? _selectedDateFieldId;
//   late final RestorableDateTime _selectedDate;
//   late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture;
//
//   DateController({required this.restorationId, required this.onDateSelected}) {
//     _selectedDate = RestorableDateTime(DateTime.now());
//     _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
//       onComplete: _selectDate,
//       onPresent: (NavigatorState navigator, Object? arguments) {
//         return navigator.restorablePush(
//           _datePickerRoute,
//           arguments: _selectedDate.value.millisecondsSinceEpoch,
//         );
//       },
//     );
//   }
//
//   void restoreState(
//     RestorationMixin mixin,
//     RestorationBucket? oldBucket,
//     bool initialRestore,
//   ) {
//     mixin.registerForRestoration(_selectedDate, 'selected_date');
//     mixin.registerForRestoration(
//       _restorableDatePickerRouteFuture,
//       'date_picker_route_future',
//     );
//   }
//
//   void openDatePicker(String fieldId) {
//     _selectedDateFieldId = fieldId;
//     _restorableDatePickerRouteFuture.present();
//   }
//
//   void _selectDate(DateTime? newSelectedDate) {
//     if (newSelectedDate != null && _selectedDateFieldId != null) {
//       _selectedDate.value = newSelectedDate;
//       final formattedDate = DateFormat('dd/MM/yyyy').format(newSelectedDate);
//       onDateSelected(_selectedDateFieldId!, formattedDate);
//     }
//   }
//
//   static Route<DateTime> _datePickerRoute(
//     BuildContext context,
//     Object? arguments,
//   ) {
//     return DialogRoute<DateTime>(
//       context: context,
//       builder:
//           (context) => DatePickerDialog(
//             restorationId: 'date_picker_dialog',
//             initialEntryMode: DatePickerEntryMode.calendarOnly,
//             initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
//             firstDate: DateTime(DateTime.now().year - 100),
//             lastDate: DateTime(DateTime.now().year + 100),
//           ),
//     );
//   }
// }
//
// // Validation Controller
// class ValidationController {
//   String? validateTextField(String? value, dynamic item) {
//     if (value == null || value.isEmpty) {
//       if (item["rqfdtp"] == "M") {
//         return _buildValidationMessage("Please Enter", item['rqflnm']);
//       }
//       return null;
//     }
//
//     if (_containsEmoji(value)) {
//       return 'Emojis not supported';
//     }
//
//     return null;
//   }
//
//   String? validateRequiredField(dynamic value, dynamic item) {
//     if (item["rqfdtp"] == "M" && (value == null || value.toString().isEmpty)) {
//       return _buildValidationMessage("Please Select", item['rqflnm']);
//     }
//     return null;
//   }
//
//   String? validateFileField(
//     dynamic item,
//     String fieldId,
//     Map<String, dynamic> formData,
//     List<SubmitOtherRequestModel> filesData,
//   ) {
//     if (item["rqfdtp"] == "M") {
//       if (formData[fieldId]?.toString().isEmpty == true || filesData.isEmpty) {
//         return "Please Select File";
//       }
//     }
//     return null;
//   }
//
//   String _buildValidationMessage(String prefix, String fieldName) {
//     final capitalizedFieldName = toBeginningOfSentenceCase(
//       fieldName.toString(),
//     );
//     return "$prefix ${capitalizedFieldName ?? ''}";
//   }
//
//   bool _containsEmoji(String text) {
//     final emojiRegex = RegExp(
//       r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|'
//       r'[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|'
//       r'[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|'
//       r'[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
//       unicode: true,
//     );
//     return emojiRegex.hasMatch(text);
//   }
// }

// form_validator.dart
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FormValidator {
  static String? validateTextField(String? value, dynamic item) {
    if (value == null || value.isEmpty) {
      if (item["rqfdtp"] == "M") {
        return "Please enter ${item['rqflnm']}";
      }
      return null;
    }

    if (_containsEmoji(value)) {
      return 'Emojis are not supported';
    }

    return null;
  }

  static String? validateRequiredField(dynamic value, dynamic item) {
    if (item["rqfdtp"] == "M" && (value == null || value.toString().isEmpty)) {
      return "Please select ${item['rqflnm']}";
    }
    return null;
  }

  static String? validateFileField(dynamic item) {
    if (item["rqfdtp"] == "M") {
      return "Please select a file";
    }
    return null;
  }

  static bool _containsEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|'
      r'[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|'
      r'[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|'
      r'[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }
}

class FileHandler {
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'pdf',
    'doc',
    'png',
  ];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> documentExtensions = ['pdf', 'doc'];

  static Future<Map<String, dynamic>?> pickAndProcessFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final file = result.files.first;
        final base64Content = await _convertFileToBase64(
          File(file.path!),
          file.extension ?? '',
        );

        return {
          'fileName': file.name.split('.').first,
          'extension': file.extension,
          'base64Content': base64Content,
        };
      }
    } catch (e) {
      print('Error picking file: $e');
    }
    return null;
  }

  static Future<String> _convertFileToBase64(
    File file,
    String extension,
  ) async {
    if (documentExtensions.contains(extension.toLowerCase())) {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    }
    return '';
  }
}

// date_picker_helper.dart
class DatePickerHelper {
  static Future<DateTime?> showDatePicking(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 100),
    );
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
