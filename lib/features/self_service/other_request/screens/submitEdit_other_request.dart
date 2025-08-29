import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../controller/other_request_controller.dart';
import '../models/form_field_model.dart';
import '../models/submit_other_request_model.dart';
import '../repository/other_request_repository.dart';

class SubmitEditOtherRequest extends ConsumerStatefulWidget {
  final String? title, micode, requestId;
  final bool isEditMode;
  const SubmitEditOtherRequest({
    super.key,
    required this.title,
    required this.micode,
    required this.requestId,
    required this.isEditMode,
  });

  @override
  ConsumerState<SubmitEditOtherRequest> createState() =>
      _SubmitEditOtherRequestState();
}

class _SubmitEditOtherRequestState
    extends ConsumerState<SubmitEditOtherRequest> {
  final _formKey = GlobalKey<FormState>();
  FormResponseModel? _formData;
  bool _isLoading = true;

  // Dynamic form data storage
  Map<String, dynamic> _formValues = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, List<String>> _selectedCheckboxValues = {};
  Map<String, PlatformFile?> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadForm() async {
    setState(() => _isLoading = true);

    Future.delayed(Duration.zero, () async {
      final formData = await ref
          .read(otherRequestRepositoryProvider)
          .getOtherRequestForm(
            userContext: ref.watch(userContextProvider),
            requestId: widget.requestId,
            micode: widget.micode,
          );
      formData.fold(
        (l) => showSnackBar(context: context, content: 'error loading form'),
        (response) => _initializeForm(response),
      );
    });
  }

  //TODO for edit also
  void _initializeForm(FormResponseModel formData) {
    setState(() {
      _formData = formData;
      _isLoading = false;
    });

    // Initialize controllers and default values
    for (var field in formData.formFieldList) {
      String fieldKey = field.generateFieldId();
      // Initialize text controllers for text fields
      if (field.fieldTypeCases == FormFieldType.textField ||
          field.fieldTypeCases == FormFieldType.textArea) {
        _controllers[fieldKey] = TextEditingController();
      }

      // Initialize checkbox values
      if (field.fieldTypeCases == FormFieldType.checkbox) {
        _selectedCheckboxValues[fieldKey] = [];
      }

      // Initialize default values
      _formValues[fieldKey] = _getDefaultValue(field);
    }

    // Prefill values if appLst has data
    if (formData.appLst.isNotEmpty && widget.isEditMode) {
      List appList = formData.appLst;
      for (var item in appList) {
        for (var field in formData.formFieldList) {
          if (field.fieldID == item['rqtscd']) {
            String fieldKey = field.generateFieldId();

            if (field.fieldTypeCases == FormFieldType.checkbox) {
              List<String> checkboxValues =
                  item['rtenvl']?.toString().split(',') ?? [];
              _formValues[fieldKey] = checkboxValues;
              _selectedCheckboxValues[fieldKey] = checkboxValues;
            } else if (field.fieldTypeCases == FormFieldType.fileUpload) {
              _formValues[fieldKey] = {
                'fileName': item['rtflnm'] ?? '',
                'filePath': item['rtflpth'] ?? '',
              };
              // For file upload, also update the selected files map
              if (item['rtflnm'] != null && item['rtflnm'].isNotEmpty) {
                // Create a mock PlatformFile for display purposes
                _selectedFiles[fieldKey] = PlatformFile(
                  name: item['rtflnm'],
                  size: 0,
                  path: item['rtflpth'],
                );
              }
            } else {
              String value = item['rtenvl']?.toString() ?? '';
              _formValues[fieldKey] = value;

              // Update text controllers if they exist
              if (_controllers[fieldKey] != null) {
                _controllers[fieldKey]!.text = value;
              }
            }
            break;
          }
        }
      }
    }
  }
  // void _initializeForm(FormResponseModel formData) {
  //   setState(() {
  //     _formData = formData;
  //     _isLoading = false;
  //   });
  //
  //   // Initialize controllers and default values
  //   for (var field in formData.formFieldList) {
  //     String fieldKey = field.generateFieldId();
  //
  //     // Initialize text controllers for text fields
  //     if (field.fieldTypeCases == FormFieldType.textField ||
  //         field.fieldTypeCases == FormFieldType.textArea) {
  //       _controllers[fieldKey] = TextEditingController();
  //     }
  //
  //     // Initialize checkbox values
  //     if (field.fieldTypeCases == FormFieldType.checkbox) {
  //       _selectedCheckboxValues[fieldKey] = [];
  //     }
  //
  //     // Initialize default values
  //     _formValues[fieldKey] = _getDefaultValue(field);
  //   }
  // }

  dynamic _getDefaultValue(FormFieldModel field) {
    switch (field.fieldTypeCases) {
      case FormFieldType.textField:
      case FormFieldType.textArea:
        return '';
      case FormFieldType.radio:
      case FormFieldType.dropdown:
        return null;
      case FormFieldType.checkbox:
        return <String>[];
      case FormFieldType.fileUpload:
        return null;
    }
  }

  String? _validateField(FormFieldModel field, dynamic value) {
    if (field.isRequired) {
      if (value == null ||
          (value is String && value.isEmpty) ||
          (value is List && value.isEmpty)) {
        return '${field.fieldName} is required';
      }
    }

    if (value != null && value is String && value.isNotEmpty) {
      if (field.isNumberField) {
        if (double.tryParse(value) == null) {
          return '${field.fieldName} must be a valid number';
        }
      }

      if (field.isDateField) {
        try {
          DateTime.parse(value);
        } catch (e) {
          return '${field.fieldName} must be a valid date';
        }
      }
    }

    return null;
  }

  Widget _buildFormField(FormFieldModel field) {
    String fieldKey = field.generateFieldId();

    switch (field.fieldTypeCases) {
      case FormFieldType.textField:
        return _buildTextField(field, fieldKey);
      case FormFieldType.textArea:
        return _buildTextArea(field, fieldKey);
      case FormFieldType.radio:
        return _buildRadioField(field, fieldKey);
      case FormFieldType.dropdown:
        return _buildDropdownField(field, fieldKey);
      case FormFieldType.checkbox:
        return _buildCheckboxField(field, fieldKey);
      case FormFieldType.fileUpload:
        return _buildFileUploadField(field, fieldKey);
    }
  }

  Widget _buildTextField(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,

        controller: _controllers[fieldKey],
        keyboardType:
            field.isNumberField ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: field.fieldName + (field.isRequired ? ' *' : ''),
          hintText: 'Enter ${field.fieldName.toLowerCase()}',
        ),
        validator: (value) => _validateField(field, value),
        onChanged: (value) {
          _formValues[fieldKey] = value;
        },
        readOnly: field.isDateField,
        onTap: field.isDateField ? () => _selectDate(field, fieldKey) : null,
      ),
    );
  }

  Widget _buildTextArea(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _controllers[fieldKey],
        maxLines: 4,
        decoration: InputDecoration(
          labelText: field.fieldName + (field.isRequired ? ' *' : ''),
          hintText: 'Enter ${field.fieldName.toLowerCase()}',
        ),
        validator: (value) => _validateField(field, value),
        onChanged: (value) {
          _formValues[fieldKey] = value;
        },
      ),
    );
  }

  Widget _buildRadioField(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<String>(
        validator: (value) => _validateField(field, value),
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.fieldName + (field.isRequired ? ' *' : ''),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              ...field.options.map(
                (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _formValues[fieldKey],
                  onChanged: (value) {
                    setState(() {
                      _formValues[fieldKey] = value;
                    });
                    state.didChange(value);
                  },
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownField(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _formValues[fieldKey],
        decoration: InputDecoration(
          labelText: field.fieldName + (field.isRequired ? ' *' : ''),
          border: OutlineInputBorder(),
        ),
        items:
            field.options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: SizedBox(width: 290.w, child: Text(option)),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _formValues[fieldKey] = value;
          });
        },
        validator: (value) => _validateField(field, value),
      ),
    );
  }

  Widget _buildCheckboxField(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<List<String>>(
        validator: (value) => _validateField(field, value),
        builder: (FormFieldState<List<String>> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.fieldName + (field.isRequired ? ' *' : ''),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              ...field.options
                  .map(
                    (option) => CheckboxListTile(
                      title: Text(option),
                      value:
                          _selectedCheckboxValues[fieldKey]?.contains(option) ??
                          false,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCheckboxValues[fieldKey]?.add(option);
                          } else {
                            _selectedCheckboxValues[fieldKey]?.remove(option);
                          }
                          _formValues[fieldKey] =
                              _selectedCheckboxValues[fieldKey];
                        });
                        state.didChange(_selectedCheckboxValues[fieldKey]);
                      },
                    ),
                  )
                  .toList(),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileUploadField(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<PlatformFile?>(
        validator: (value) => _validateField(field, value),
        builder: (FormFieldState<PlatformFile?> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.fieldName + (field.isRequired ? ' *' : ''),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(withData: true);
                  if (result != null) {
                    setState(() {
                      _selectedFiles[fieldKey] = result.files.single;
                      _formValues[fieldKey] = result.files.single;
                    });
                    state.didChange(result.files.single);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFiles[fieldKey]?.name ?? 'Select file',
                          style: TextStyle(
                            color:
                                _selectedFiles[fieldKey] != null
                                    ? Colors.black
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectDate(FormFieldModel field, String fieldKey) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _controllers[fieldKey]?.text = formattedDate;
      _formValues[fieldKey] = formattedDate;
    }
  }

  Map<String, dynamic> _generateRequestBody() {
    Map<String, dynamic> body = {};

    _formData?.formFieldList.forEach((field) {
      String fieldKey = field.generateFieldId();
      dynamic value = _formValues[fieldKey];

      // Convert values based on field type
      if (field.fieldTypeCases == FormFieldType.checkbox) {
        body[field.fieldID.toString()] = (value as List<String>).join(',');
      } else if (field.fieldTypeCases == FormFieldType.fileUpload) {
        // Handle file upload separately in your API call
        if (value != null) {
          body[field.fieldID.toString()] = (value as PlatformFile).name;
        }
      } else {
        body[field.fieldID.toString()] = value?.toString() ?? '';
      }
    });

    return body;
  }

  String _extractRqtscd(FormFieldModel field) {
    // Extract the field ID from the field
    return field.fieldID.toString();
  }

  // List<SubmitOtherRequestModel> _buildSubmissionData() {
  //   final List<SubmitOtherRequestModel> formData = [];
  //
  //   _formData?.formFieldList.forEach((field) async {
  //     String fieldKey = field.generateFieldId();
  //     dynamic value = _formValues[fieldKey];
  //
  //     final rqtscd = _extractRqtscd(field);
  //
  //     String rtcont = "";
  //     String rtflnm = "";
  //
  //     if (field.fieldTypeCases == FormFieldType.fileUpload && value != null) {
  //       final file = value as PlatformFile;
  //       rtflnm = file.extension ?? 'extension';
  //       final bytes = await File(file.path!).readAsBytes();
  //       print(bytes);
  //       rtcont = base64Encode(bytes);
  //     }
  //
  //     // Convert value to string based on field type
  //     String rtenvl = "";
  //     if (field.fieldTypeCases == FormFieldType.checkbox) {
  //       rtenvl = (value as List<String>).join(',');
  //     } else if (value != null) {
  //       rtenvl = value.toString();
  //     }
  //
  //     formData.add(
  //       SubmitOtherRequestModel(
  //         rqtscd: rqtscd,
  //         rtenvl: rtenvl,
  //         rtcont: rtcont,
  //         rtflnm: rtflnm,
  //         rtescd: "0",
  //       ),
  //     );
  //   });
  //
  //   return formData;
  // }

  Future<List<SubmitOtherRequestModel>> _buildSubmissionData() async {
    final List<SubmitOtherRequestModel> formData = [];

    for (final field in _formData?.formFieldList ?? []) {
      String fieldKey = field.generateFieldId();
      dynamic value = _formValues[fieldKey];

      final rqtscd = _extractRqtscd(field);

      String rtcont = "";
      String rtflnm = "";
      String rtenvl = "";

      if (field.fieldTypeCases == FormFieldType.fileUpload && value != null) {
        final file = value as PlatformFile;
        rtflnm = file.extension ?? 'extension';

        // ✅ Add file name (without extension) to rtenvl
        rtenvl = file.name.split('.').first;

        if (file.bytes != null) {
          // if filePicker had withData: true
          rtcont = base64Encode(file.bytes!);
        } else if (file.path != null) {
          // fallback: read from path
          final bytes = await File(file.path!).readAsBytes();
          rtcont = base64Encode(bytes);
        }
      } else if (field.fieldTypeCases == FormFieldType.checkbox) {
        rtenvl = (value as List<String>).join(',');
      } else if (value != null) {
        rtenvl = value.toString();
      }

      formData.add(
        SubmitOtherRequestModel(
          rqtscd: rqtscd,
          rtenvl: rtenvl,
          rtcont: rtcont,
          rtflnm: rtflnm,
          rtescd: "0",
        ),
      );
    }

    return formData;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> requestBody = _generateRequestBody();

      // Print form data for debugging
      print('Form submitted with data: $requestBody');

      // Print files for debugging
      _selectedFiles.forEach((key, file) {
        if (file != null) {
          print('File to upload: ${file.name}, path: ${file.path}');
        }
      });

      // Build the submission data
      final formData = await _buildSubmissionData();

      // Print submission data for debugging
      print(
        'Submission data: ${formData.map((e) => {'rqtscd': e.rqtscd, 'rtenvl': e.rtenvl, 'rtcont': e.rtcont, 'rtflnm': e.rtflnm, 'rtescd': e.rtescd}).toList()}',
      );

      // Submit to your API
      ref
          .read(otherRequestControllerProvider.notifier)
          .submitOtherRequest(
            submitModel: formData,
            context: context,
            rtencd: widget.isEditMode ? (widget.micode ?? '0') : '0',
            rqtmcd: widget.requestId ?? '0',
            menuName: widget.title,
            micode: widget.micode ?? '0',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'other_requests'.tr())),
      body:
          _isLoading
              ? Loader()
              : _formData == null
              ? Center(child: Text('Failed to load form'))
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ..._formData!.formFieldList.map(
                        (field) => _buildFormField(field),
                      ),
                      SizedBox(height: 100), // Space for bottom sheet
                    ],
                  ),
                ),
              ),
      bottomSheet:
          ref.watch(otherRequestControllerProvider)
              ? Loader()
              : _isLoading
              ? null
              : Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.isEditMode ? 'Update' : 'Submit'),
                  ),
                ),
              ),
    );
  }
}
