import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:dio/dio.dart';
import 'package:zeta_ess/core/common/widgets/customTimePicker.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../controller/other_request_controller.dart';
import '../models/form_field_model.dart';
import '../models/submit_other_request_model.dart';
import '../repository/other_request_repository.dart';
import 'package:intl/intl.dart';

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

  // Fixed file upload handling
  Map<String, FileUploadData?> _fileData = {};

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
      formData.fold((l) {
        _isLoading = false;
        showSnackBar(context: context, content: 'error loading form');
      }, (response) => _initializeForm(response));
    });
  }

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

      // Initialize file upload data
      if (field.fieldTypeCases == FormFieldType.fileUpload) {
        _fileData[fieldKey] = null;
        _selectedFiles[fieldKey] = null;
      }

      // Initialize default values
      _formValues[fieldKey] = _getDefaultValue(field);
    }

    // Prefill values if appLst has data and in edit mode
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
              // Fixed: Properly handle existing file data
              if (item['rtflnm'] != null &&
                  item['rtflnm'].toString().isNotEmpty) {
                _fileData[fieldKey] = FileUploadData(
                  rqtscd: fieldKey,
                  rtenvl: item['rtenvl']?.toString() ?? '',
                  rtcont: item['rtcont']?.toString() ?? '',
                  rtflnm: item['rtflnm']?.toString() ?? '',
                  rtflpth: item['rtflpth']?.toString(),
                  rtescd: item['rtescd']?.toString(),
                );
                _formValues[fieldKey] =
                    'existing_file'; // Mark as having existing file
              }
            } else {
              String value = item['rtenvl']?.toString() ?? '';
              _formValues[fieldKey] = value;
              // Update text controllers if they exist
              if (_controllers[fieldKey] != null) {
                String displayValue = value;

                if (field.isTimeField && value.isNotEmpty) {
                  try {
                    final parsedTime = DateFormat("HH:mm").parse(value);
                    displayValue = DateFormat("hh:mm a").format(parsedTime);
                  } catch (e) {
                    displayValue = value;
                  }
                }

                _controllers[fieldKey]!.text = displayValue;
              }
            }
            break;
          }
        }
      }
    }
  }

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
    // Special handling for file upload fields
    if (field.fieldTypeCases == FormFieldType.fileUpload) {
      if (field.isRequired) {
        // Check if we have either existing file data or newly selected file
        String fieldKey = field.generateFieldId();
        bool hasExistingFile = _fileData[fieldKey] != null;
        bool hasNewFile = _selectedFiles[fieldKey] != null;

        if (!hasExistingFile && !hasNewFile) {
          return '${field.fieldName} is required';
        }
      }
      return null; // File upload validation passed
    }

    // Original validation logic for other field types
    if (value != null) {
      if (value is String && value.isNotEmpty) return null;
      if (value is List && value.isNotEmpty) return null;
    }

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
        readOnly: field.isDateField || field.isTimeField,
        onTap:
            field.isTimeField
                ? () =>
                    _selectTime(field, fieldKey, _controllers[fieldKey]?.text)
                : field.isDateField
                ? () => _selectDate(field, fieldKey)
                : null,
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
        initialValue: _formValues[fieldKey],
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
                .toSet()
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: SizedBox(width: 290, child: Text(option)),
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
        initialValue: List<String>.from(_formValues[fieldKey] ?? []),
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

  // Fixed file upload widget
  Widget _buildFileUploadField(FormFieldModel field, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<dynamic>(
        validator: (value) => _validateField(field, value),
        builder: (FormFieldState state) {
          String displayText = 'Select file';
          bool hasFile = false;
          bool canView = false;

          // Check for newly selected file first
          if (_selectedFiles[fieldKey] != null) {
            displayText = _selectedFiles[fieldKey]!.name;
            hasFile = true;
            canView = _selectedFiles[fieldKey]!.path != null;
          }
          // Then check for existing file data
          else if (_fileData[fieldKey] != null) {
            final fileData = _fileData[fieldKey]!;
            displayText =
                fileData.rtenvl.isNotEmpty
                    ? '${fileData.rtenvl}.${fileData.rtflnm}'
                    : 'Existing file';
            hasFile = true;
            canView = fileData.rtflpth?.isNotEmpty == true;
          }

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
                      .pickFiles(
                        withData: true,
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc'],
                      );

                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      _selectedFiles[fieldKey] = result.files.single;
                      _formValues[fieldKey] = result.files.single;
                      // Clear existing file data since user selected new file
                      _fileData[fieldKey] = null;
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
                          displayText,
                          style: TextStyle(
                            color: hasFile ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                      // This is sarath bro !
                      if (canView && widget.isEditMode)
                        IconButton(
                          color: AppTheme.primaryColor,
                          onPressed: () => _viewFile(fieldKey),
                          icon: Icon(Icons.visibility, color: Colors.blue),
                          tooltip: 'View file',
                        ),
                      // Show remove button if we have any file
                      if (hasFile)
                        IconButton(
                          onPressed: () => _removeFile(fieldKey, state),
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          tooltip: 'Remove file',
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

  void _viewFile(String fieldKey) async {
    String? filePath;

    // Check for newly selected file first
    if (_selectedFiles[fieldKey] != null) {
      filePath = _selectedFiles[fieldKey]!.path;
      if (filePath != null) {
        await _launchUrl(filePath);
      }
    }
    // Then check existing file
    else if (_fileData[fieldKey] != null &&
        _fileData[fieldKey]!.rtflpth != null) {
      filePath = _fileData[fieldKey]!.rtflpth;
      if (filePath != null && filePath.isNotEmpty) {
        await _launchUrl(filePath);
      }
    }
  }

  void _removeFile(String fieldKey, FormFieldState state) {
    setState(() {
      _selectedFiles[fieldKey] = null;
      _fileData[fieldKey] = null;
      _formValues[fieldKey] = null;
    });
    state.didChange(null);
  }

  // Launch URL method
  Future<void> _launchUrl(String filePath) async {
    try {
      setState(() => _isLoading = true);
      String attachmentUrl;

      // If it's a local file path, launch directly
      if (filePath.startsWith('/') || filePath.contains('file://')) {
        final Uri url = Uri.file(filePath);
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return;
      }

      // If it's a server path, construct the URL
      attachmentUrl = "${ref.watch(userContextProvider).userBaseUrl}/$filePath";

      var status = await getAttachmentStatus(attachmentUrl);
      if (status == "200") {
        final Uri url = Uri.parse(attachmentUrl);
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showSnackBar(context: context, content: 'File not found');
      }
    } catch (e) {
      showSnackBar(context: context, content: 'Error opening file');
    }
    setState(() => _isLoading = false);
  }

  Future<String> getAttachmentStatus(String url) async {
    try {
      var response = await Dio().get(url);
      return response.statusCode.toString();
    } catch (e) {
      return "404";
    }
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

  Future<void> _selectTime(
    FormFieldModel field,
    String fieldKey,
    String? existingTime,
  ) async {
    TimeOfDay initialTime = TimeOfDay.now();

    // Try to parse existingTime ("HH:mm") if provided
    if (existingTime != null && existingTime.isNotEmpty) {
      try {
        final parsedTime = DateFormat("HH:mm").parse(existingTime);
        initialTime = TimeOfDay(
          hour: parsedTime.hour,
          minute: parsedTime.minute,
        );
      } catch (e) {
        // Fallback: keep default TimeOfDay.now()
        debugPrint('Invalid existingTime: $existingTime, using current time.');
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        // Keep 12-hour picker (default)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Convert picked time (12-hour) → 24-hour string
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final formatted24 = '$hour:$minute';

      // Also prepare a user-friendly display (e.g. 02:30 PM)
      final formatted12 = picked.format(context);

      // Show 12hr format to user, store 24hr format internally
      _controllers[fieldKey]?.text = formatted12;
      _formValues[fieldKey] = formatted24;
    }
  }

  String _extractRqtscd(FormFieldModel field) {
    return field.fieldID.toString();
  }

  // Fixed submission data building
  Future<List<SubmitOtherRequestModel>> _buildSubmissionData() async {
    final List<SubmitOtherRequestModel> formData = [];

    for (final field in _formData?.formFieldList ?? []) {
      String fieldKey = field.generateFieldId();
      dynamic value = _formValues[fieldKey];
      final rqtscd = _extractRqtscd(field);

      String rtcont = "";
      String rtflnm = "";
      String rtenvl = "";

      if (field.fieldTypeCases == FormFieldType.fileUpload) {
        // Check if user selected a new file
        if (_selectedFiles[fieldKey] != null) {
          final file = _selectedFiles[fieldKey]!;
          rtflnm = file.extension ?? '';
          rtenvl = file.name.split('.').first;

          if (file.bytes != null) {
            rtcont = base64Encode(file.bytes!);
          } else if (file.path != null) {
            final bytes = await File(file.path!).readAsBytes();
            rtcont = base64Encode(bytes);
          }
        }
        // Use existing file data if no new file selected
        else if (_fileData[fieldKey] != null) {
          final existingFile = _fileData[fieldKey]!;
          rtflnm = existingFile.rtflnm;
          rtenvl = existingFile.rtenvl;
          rtcont = existingFile.rtcont; // Keep existing content
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
          rtescd:
              _fileData[fieldKey]?.rtescd ?? "0", // Preserve existing rtescd
        ),
      );
    }

    return formData;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Build the submission data
      final formData = await _buildSubmissionData();

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
