import 'package:flutter/material.dart';

import 'form_controllers.dart';
//
// // Form Field Builder
// class CustomFormFieldBuilder {
//   static Widget buildField({
//     required dynamic item,
//     required FormController formController,
//     required FileController fileController,
//     required DateController dateController,
//     required ValidationController validationController,
//     required Function(String, dynamic) onFieldChanged,
//   }) {
//     final fieldType = item['rpiptp'].toString();
//
//     switch (fieldType) {
//       case '1':
//         return item['rqflty'].toString() == "D"
//             ? _buildDateField(
//               item,
//               formController,
//               dateController,
//               validationController,
//             )
//             : _buildTextField(
//               item,
//               formController,
//               validationController,
//               onFieldChanged,
//               maxLines: 1,
//             );
//       case '2':
//         return _buildTextField(
//           item,
//           formController,
//           validationController,
//           onFieldChanged,
//           maxLines: 4,
//         );
//       case '3':
//         return _buildRadioField(
//           item,
//           formController,
//           validationController,
//           onFieldChanged,
//         );
//       case '4':
//         return _buildDropdownField(
//           item,
//           formController,
//           validationController,
//           onFieldChanged,
//         );
//       case '5':
//         return _buildCheckboxField(
//           item,
//           formController,
//           validationController,
//           onFieldChanged,
//         );
//       case '6':
//         return _buildFileUploadField(
//           item,
//           formController,
//           fileController,
//           validationController,
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   static Widget _buildTextField(
//     dynamic item,
//     FormController formController,
//     ValidationController validationController,
//     Function(String, dynamic) onFieldChanged, {
//     int maxLines = 1,
//   }) {
//     final fieldId = _generateFieldId(item);
//     final isNumeric = item['rqflty'] == 'N';
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildFieldLabel(item),
//         TextFormField(
//           maxLines: maxLines > 1 ? null : maxLines,
//           onChanged: (value) => onFieldChanged(fieldId, value),
//           keyboardType:
//               isNumeric
//                   ? TextInputType.number
//                   : (maxLines > 1
//                       ? TextInputType.multiline
//                       : TextInputType.text),
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           validator:
//               (value) => validationController.validateTextField(value, item),
//         ),
//       ],
//     );
//   }
//
//   static Widget _buildDateField(
//     dynamic item,
//     FormController formController,
//     DateController dateController,
//     ValidationController validationController,
//   ) {
//     final fieldId = _generateFieldId(item);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildFieldLabel(item),
//         TextFormField(
//           readOnly: true,
//           onTap: () => dateController.openDatePicker(fieldId),
//           controller: TextEditingController(
//             text: formController.getFieldValue(fieldId),
//           ),
//           validator:
//               (value) =>
//                   validationController.validateRequiredField(value, item),
//         ),
//       ],
//     );
//   }
//
//   static Widget _buildDropdownField(
//     dynamic item,
//     FormController formController,
//     ValidationController validationController,
//     Function(String, dynamic) onFieldChanged,
//   ) {
//     final fieldId = _generateFieldId(item);
//     final items = item['rpipdt'].toString().split(',');
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildFieldLabel(item),
//         DropdownButtonFormField<String>(
//           isExpanded: true,
//           value:
//               formController.getFieldValue(fieldId).isEmpty
//                   ? null
//                   : formController.getFieldValue(fieldId),
//           items:
//               items
//                   .map(
//                     (item) => DropdownMenuItem(
//                       value: item,
//                       child: Text(item.toString()),
//                     ),
//                   )
//                   .toList(),
//           onChanged: (value) => onFieldChanged(fieldId, value),
//           validator:
//               (value) =>
//                   validationController.validateRequiredField(value, item),
//         ),
//       ],
//     );
//   }
//
//   static Widget _buildRadioField(
//     dynamic item,
//     FormController formController,
//     ValidationController validationController,
//     Function(String, dynamic) onFieldChanged,
//   ) {
//     final fieldId = _generateFieldId(item);
//     final options = item['rpipdt'].toString().split(',');
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildFieldLabel(item),
//         ...options.map(
//           (option) => Row(
//             children: [
//               Radio<String>(
//                 value: option,
//                 groupValue: formController.getFieldValue(fieldId),
//                 onChanged: (value) => onFieldChanged(fieldId, value),
//               ),
//               Expanded(child: Text(option.toString())),
//             ],
//           ),
//         ),
//         _buildHiddenValidator(item, formController, validationController),
//       ],
//     );
//   }
//
//   static Widget _buildCheckboxField(
//     dynamic item,
//     FormController formController,
//     ValidationController validationController,
//     Function(String, dynamic) onFieldChanged,
//   ) {
//     final fieldId = _generateFieldId(item);
//     final options = item['rpipdt'].toString().split(',');
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildFieldLabel(item),
//         ...options.map(
//           (option) => Row(
//             children: [
//               Checkbox(
//                 value: formController.isOptionSelected(fieldId, option),
//                 onChanged: (value) {
//                   formController.toggleCheckboxOption(
//                     fieldId,
//                     option,
//                     value ?? false,
//                   );
//                   onFieldChanged(
//                     fieldId,
//                     formController.getFieldValue(fieldId),
//                   );
//                 },
//               ),
//               Expanded(child: Text(option.toString())),
//             ],
//           ),
//         ),
//         _buildHiddenValidator(item, formController, validationController),
//       ],
//     );
//   }
//
//   static Widget _buildFileUploadField(
//     dynamic item,
//     FormController formController,
//     FileController fileController,
//     ValidationController validationController,
//   ) {
//     final fieldId = _generateFieldId(item);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildFieldLabel(item),
//         Row(
//           children: [
//             ElevatedButton(
//               onPressed: () => fileController.pickFile(fieldId),
//               child: const Text('Upload'),
//             ),
//             if (fileController.hasFileUploaded(fieldId))
//               _buildRemoveFileButton(fieldId, fileController),
//           ],
//         ),
//         _buildFileValidator(
//           item,
//           fieldId,
//           formController,
//           fileController,
//           validationController,
//         ),
//       ],
//     );
//   }
//
//   static Widget _buildFieldLabel(dynamic item) {
//     return Row(
//       children: [
//         Text(
//           item['rqflnm'].toString(),
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         if (item["rqfdtp"] == "M")
//           const Text(" *", style: TextStyle(color: Colors.red)),
//       ],
//     );
//   }
//
//   static Widget _buildHiddenValidator(
//     dynamic item,
//     FormController formController,
//     ValidationController validationController,
//   ) {
//     return SizedBox(
//       height: 25,
//       child: TextFormField(
//         readOnly: true,
//         decoration: const InputDecoration(
//           contentPadding: EdgeInsets.symmetric(vertical: 0),
//           border: InputBorder.none,
//         ),
//         validator:
//             (value) => validationController.validateRequiredField(
//               formController.getFieldValue(_generateFieldId(item)),
//               item,
//             ),
//       ),
//     );
//   }
//
//   static Widget _buildFileValidator(
//     dynamic item,
//     String fieldId,
//     FormController formController,
//     FileController fileController,
//     ValidationController validationController,
//   ) {
//     return SizedBox(
//       height: 25,
//       child: TextFormField(
//         readOnly: true,
//         decoration: const InputDecoration(
//           contentPadding: EdgeInsets.symmetric(vertical: 0),
//           border: InputBorder.none,
//         ),
//         validator:
//             (value) => validationController.validateFileField(
//               item,
//               fieldId,
//               formController.formData,
//               fileController.filesData,
//             ),
//       ),
//     );
//   }
//
//   static Widget _buildRemoveFileButton(
//     String fieldId,
//     FileController fileController,
//   ) {
//     return GestureDetector(
//       onTap: () => fileController.removeFile(fieldId),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//         child: Text(
//           'Remove',
//           style: TextStyle(
//             color: HexColor("#0E6D9B"),
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
//
//   static String _generateFieldId(dynamic item) {
//     return "${item['rqflnm'].toString().toLowerCase().replaceAll(" ", "_")}_${item['Rqtscd']}";
//   }
// }

class CustomFormFieldBuilder {
  static const List<String> allowedFileExtensions = [
    'jpg',
    'jpeg',
    'pdf',
    'doc',
    'png',
  ];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> documentExtensions = ['pdf', 'doc'];

  static Widget buildTextField({
    required dynamic item,
    required Function(String, dynamic) onChanged,
    int maxLines = 1,
  }) {
    final fieldId = _generateFieldId(item);
    final isNumeric = item['rqflty'] == 'N';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(item),
        TextFormField(
          maxLines: maxLines > 1 ? null : maxLines,
          onChanged: (value) => onChanged(fieldId, value),
          keyboardType:
              isNumeric
                  ? TextInputType.number
                  : (maxLines > 1
                      ? TextInputType.multiline
                      : TextInputType.text),
          validator: (value) => FormValidator.validateTextField(value, item),
          decoration: _getInputDecoration(),
        ),
      ],
    );
  }

  static Widget buildDateField({
    required dynamic item,
    required VoidCallback onTap,
    required String? currentValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(item),
        TextFormField(
          readOnly: true,
          onTap: onTap,
          controller: TextEditingController(text: currentValue ?? ""),
          decoration: _getInputDecoration(),
          validator:
              (value) => FormValidator.validateRequiredField(value, item),
        ),
      ],
    );
  }

  static Widget buildDropdownField({
    required dynamic item,
    required Function(String, dynamic) onChanged,
    required String? currentValue,
  }) {
    final fieldId = _generateFieldId(item);
    final items = item['rpipdt'].toString().split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(item),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: currentValue?.isEmpty == true ? null : currentValue,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: _getDropdownTextStyle()),
                    ),
                  )
                  .toList(),
          onChanged: (value) => onChanged(fieldId, value),
          decoration: _getDropdownDecoration(),
          validator:
              (value) => FormValidator.validateRequiredField(value, item),
        ),
      ],
    );
  }

  static Widget buildRadioField({
    required dynamic item,
    required Function(String, dynamic) onChanged,
    required String? currentValue,
  }) {
    final fieldId = _generateFieldId(item);
    final options = item['rpipdt'].toString().split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(item),
        ...options.map(
          (option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: currentValue,
            onChanged: (value) => onChanged(fieldId, value),
            dense: true,
          ),
        ),
        _buildHiddenValidator(item, currentValue),
      ],
    );
  }

  static Widget buildCheckboxField({
    required dynamic item,
    required Function(String, String, bool) onToggle,
    required String? currentValue,
  }) {
    final fieldId = _generateFieldId(item);
    final options = item['rpipdt'].toString().split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(item),
        ...options.map(
          (option) => CheckboxListTile(
            title: Text(option),
            value: _isOptionSelected(currentValue, option),
            onChanged: (value) => onToggle(fieldId, option, value ?? false),
            dense: true,
          ),
        ),
        _buildHiddenValidator(item, currentValue),
      ],
    );
  }

  static Widget buildFileUploadField({
    required dynamic item,
    required VoidCallback onUpload,
    required VoidCallback? onRemove,
    required bool hasFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(item),
        Row(
          children: [
            ElevatedButton(onPressed: onUpload, child: const Text('Upload')),
            if (hasFile)
              TextButton(
                onPressed: onRemove,
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        _buildFileValidator(item),
      ],
    );
  }

  static String _generateFieldId(dynamic item) {
    return "${item['rqflnm'].toString().toLowerCase().replaceAll(" ", "_")}_${item['Rqtscd']}";
  }

  static Widget _buildFieldLabel(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: item['rqflnm'].toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            if (item["rqfdtp"] == "M")
              const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  static Widget _buildHiddenValidator(dynamic item, String? currentValue) {
    return SizedBox(
      height: 0,
      child: TextFormField(
        enabled: false,
        decoration: const InputDecoration(border: InputBorder.none),
        validator:
            (_) => FormValidator.validateRequiredField(currentValue, item),
      ),
    );
  }

  static Widget _buildFileValidator(dynamic item) {
    return SizedBox(
      height: 0,
      child: TextFormField(
        enabled: false,
        decoration: const InputDecoration(border: InputBorder.none),
        validator: (_) => FormValidator.validateFileField(item),
      ),
    );
  }

  static bool _isOptionSelected(String? currentValue, String option) {
    final selectedOptions = (currentValue ?? '').split(',');
    return selectedOptions.contains(option);
  }

  static InputDecoration _getInputDecoration() {
    return const InputDecoration(
      border: UnderlineInputBorder(),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }

  static InputDecoration _getDropdownDecoration() {
    return const InputDecoration(
      border: UnderlineInputBorder(),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }

  static TextStyle _getDropdownTextStyle() {
    return const TextStyle(color: Colors.blue, fontSize: 14);
  }
}
