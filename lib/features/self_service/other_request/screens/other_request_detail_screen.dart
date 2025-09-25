import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/buttons/approveReject_buttons.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/features/approval_management/approve_other_request/controller/approve_otherRequest_notifiers.dart';
import 'package:zeta_ess/features/approval_management/approve_other_request/repository/approve_other_request_repository.dart';

import '../../../../core/common/loader.dart';
import '../../../../core/common/no_server_screen.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../models/form_field_model.dart';
import '../repository/other_request_repository.dart';

class OtherRequestDetailScreen extends ConsumerStatefulWidget {
  final String? rqtmcd;
  final String? rtencd;
  final String? menuName;
  final String? menuId;
  final String? primaryKey;
  final bool show;
  final String? restorationId;
  final bool? fromSelf;

  const OtherRequestDetailScreen({
    super.key,
    this.rqtmcd,
    this.rtencd,
    this.menuName,
    this.menuId,
    this.restorationId,
    required this.show,
    this.primaryKey,
    required this.fromSelf,
  });

  @override
  ConsumerState<OtherRequestDetailScreen> createState() =>
      _OtherRequestDetailScreenState();
}

class _OtherRequestDetailScreenState
    extends ConsumerState<OtherRequestDetailScreen> {
  // Data
  FormResponseModel? _formData;
  Map<String, dynamic> _formValues = {};

  // Controllers
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State
  bool _isLoading = false;
  String _lmComment = "";
  String _prevComment = "";
  String _appRejComment = "";
  String _selfComment = "";

  static const _strings = {
    'approve': 'Approve',
    'reject': 'Reject',
    'comment': 'Comment',
    'previousComment': 'Previous Comment',
    'ok': 'OK',
    'view': 'View',
    'tryAgain': 'Try Again',
    'successMessage': 'Successfully saved your request',
    'errorMessage': 'Something went wrong, try again later',
    'emojisNotSupported': 'Emojis not supported',
    'maximum500Character': 'Maximum 500 characters allowed',
    'pleaseSelectDropdown': 'Please select dropdown',
    'uploadFileMissing': 'Upload File Missing',
  };

  @override
  void initState() {
    super.initState();
    _getForm();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getForm() async {
    setState(() => _isLoading = true);

    Future.delayed(Duration.zero, () async {
      final formData = await ref
          .read(otherRequestRepositoryProvider)
          .getOtherRequestForm(
            userContext: ref.watch(userContextProvider),
            requestId: widget.rqtmcd,
            micode: widget.primaryKey,
          );
      formData.fold(
        (l) => showSnackBar(context: context, content: 'error loading form'),
        (response) => _generateForms(response),
      );
      setState(() => _isLoading = false);
    });
  }

  Future<void> _approveReject(String flag) async {
    _setLoading(true);
    try {
      final response = await ref
          .read(approveOtherRequestRepositoryProvider)
          .approveRejectOtherRequest(
            micode: widget.menuId ?? '0',
            primaryKey: widget.primaryKey ?? '0',
            requestName: widget.menuName ?? '',
            userContext: ref.watch(userContextProvider),
            note: _commentController.text,
            requestId: widget.primaryKey.toString(),
            approveRejectFlag: flag,
          )
          .timeout(const Duration(seconds: 60));

      response.fold(
        (failure) {
          showSnackBar(context: context, content: failure.errMsg);
        },
        (message) {
          ref.invalidate(approveOtherRequestListProvider);
          Navigator.pop(context);
          showSnackBar(
            context: context,
            content: message ?? _strings['successMessage']!,
          );
        },
      );
    } catch (e) {
      _navigateToNoServer();
    } finally {
      _setLoading(false);
    }
  }

  // Utility Methods
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _navigateToNoServer() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => const NoServer()),
    );
  }

  bool _validateEmoji(String text) {
    final regex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return regex.hasMatch(text);
  }

  String _getFormFieldValue(FormFieldModel field) {
    String fieldKey = field.generateFieldId();
    return _formValues[fieldKey]?.toString() ?? '';
  }

  // Form Generation Methods
  void _generateForms(FormResponseModel formData) {
    try {
      _formData = formData;
      if (formData.appLst.isNotEmpty) {
        List appList = formData.appLst;
        for (var item in appList) {
          for (var field in formData.formFieldList) {
            if (field.fieldID == item['rqtscd']) {
              String fieldKey = field.generateFieldId();

              if (field.fieldTypeCases == FormFieldType.checkbox) {
                _formValues[fieldKey] =
                    item['rtenvl']?.toString().split(',') ?? [];
              } else if (field.fieldTypeCases == FormFieldType.fileUpload) {
                _formValues[fieldKey] = {
                  'fileName': item['rtflnm'] ?? '',
                  'filePath': item['rtflpth'] ?? '',
                };
              } else {
                _formValues[fieldKey] = item['rtenvl']?.toString() ?? '';
              }
              break;
            }
          }
        }
      }

      // Handle comments
      if (formData.subLst.isNotEmpty) {
        var subList = formData.subLst;
        setState(() {
          _lmComment = (subList[0]['lmComment'] ?? "").toString();
          _prevComment = (subList[0]['prevComment'] ?? "").toString();
          _appRejComment = (subList[0]['appRejComment'] ?? "").toString();
          _selfComment = (subList[0]['rqflnm'] ?? "").toString();
        });
      }

      setState(() {});
    } catch (e) {
      // Handle error silently
      print('Error generating forms: $e');
    }
  }

  // Enhanced UI Components
  Widget _buildFieldContainer({
    required String label,
    required Widget content,
    bool isRequired = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: labelText(label, isRequired: isRequired)),
            ],
          ),
          SizedBox(height: 8.h),
          content,
        ],
      ),
    );
  }

  Widget _buildValueText(String value, {bool isEmpty = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        isEmpty ? 'No value provided' : value,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isEmpty ? Colors.grey.shade500 : Colors.black87,
          fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildCommentSection(String comment, String title, bool isVisible) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 18.sp,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              comment,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Form Widget Builders
  Widget _buildTextDisplay(FormFieldModel field) {
    String value = _getFormFieldValue(field);
    bool isEmpty = value.isEmpty;

    return _buildFieldContainer(
      label: field.fieldName,
      isRequired: field.isRequired,
      content: _buildValueText(
        isEmpty ? 'No value provided' : value,
        isEmpty: isEmpty,
      ),
    );
  }

  Widget _buildTextAreaDisplay(FormFieldModel field) {
    String value = _getFormFieldValue(field);
    bool isEmpty = value.isEmpty;

    return _buildFieldContainer(
      label: field.fieldName,
      isRequired: field.isRequired,
      content: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          isEmpty ? 'No value provided' : value,
          style: TextStyle(
            fontSize: 15.sp,
            color: isEmpty ? Colors.grey.shade500 : Colors.black87,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownDisplay(FormFieldModel field) {
    String selectedValue = _getFormFieldValue(field);
    bool isEmpty = selectedValue.isEmpty;

    return _buildFieldContainer(
      label: field.fieldName,
      isRequired: field.isRequired,
      content: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                isEmpty ? 'No selection made' : selectedValue,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isEmpty ? Colors.grey.shade500 : Colors.black87,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioDisplay(FormFieldModel field) {
    String selectedValue = _getFormFieldValue(field);
    bool isEmpty = selectedValue.isEmpty;

    return _buildFieldContainer(
      label: field.fieldName,
      isRequired: field.isRequired,
      content: Column(
        children:
            field.options.where((option) => option == selectedValue).map((
              option,
            ) {
              bool isSelected = selectedValue == option;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.blue.shade300
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue.shade600 : Colors.white,
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child:
                          isSelected
                              ? Icon(
                                Icons.circle,
                                size: 12.sp,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color:
                              isSelected
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCheckboxDisplay(FormFieldModel field) {
    String fieldKey = field.generateFieldId();
    List<String> selectedItems = [];

    if (_formValues[fieldKey] is List) {
      selectedItems = List<String>.from(_formValues[fieldKey]);
    } else if (_formValues[fieldKey] is String) {
      String value = _formValues[fieldKey] as String;
      selectedItems = value.isNotEmpty ? value.split(',') : [];
    }

    return _buildFieldContainer(
      label: field.fieldName,
      isRequired: field.isRequired,
      content: Column(
        children:
            field.options.where((option) => selectedItems.contains(option)).map(
              (option) {
                bool isSelected = selectedItems.contains(option);
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.green.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.green.shade600
                                    : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  size: 14.sp,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color:
                                isSelected
                                    ? Colors.green.shade700
                                    : Colors.black87,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
      ),
    );
  }

  Widget _buildFileDisplay(FormFieldModel field) {
    String fieldKey = field.generateFieldId();
    Map<String, dynamic>? fileData =
        _formValues[fieldKey] as Map<String, dynamic>?;
    String fileName = fileData?['fileName'] ?? '';
    String filePath = fileData?['filePath'] ?? '';
    return Visibility(
      visible: fileName.isNotEmpty,
      child: _buildFieldContainer(
        label: field.fieldName,
        isRequired: field.isRequired,
        content: GestureDetector(
          onTap: () => _launchUrl(filePath),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Icon(
                    Icons.attach_file,
                    color: Colors.orange.shade700,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachments',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      if (fileName.isNotEmpty)
                        Text(
                          'Tap to view file',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (fileName.isNotEmpty)
                  Icon(
                    Icons.open_in_new,
                    color: Colors.orange.shade700,
                    size: 18.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(FormFieldModel field) {
    String value = _getFormFieldValue(field);
    bool isEmpty = value.isEmpty;

    return _buildFieldContainer(
      label: field.fieldName,
      isRequired: field.isRequired,
      content: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade600,
              size: 18.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isEmpty ? 'No date selected' : value,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isEmpty ? Colors.grey.shade500 : Colors.black87,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateComment(String? value) {
    if (value != null && value.isNotEmpty) {
      if (_validateEmoji(value)) {
        return _strings['emojisNotSupported'];
      }
      if (value.length > 500) {
        return _strings['maximum500Character'];
      }
    }
    return null;
  }

  // Event Handlers
  Future<void> _launchUrl(String filePath) async {
    _setLoading(true);
    try {
      if (filePath.isNotEmpty) {
        // TODO: Implement file download/view logic
        String attachmentUrl =
            "${ref.watch(userContextProvider).userBaseUrl}/$filePath";
        var status = await getAttachmentStatus(attachmentUrl);
        if (status == "200") {
          final Uri url = Uri.parse(attachmentUrl);
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          showSnackBar(
            context: context,
            content: _strings['uploadFileMissing'] ?? 'Eorror',
          );
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<String> getAttachmentStatus(String url) async {
    try {
      var response = await Dio().get(url);
      return response.statusCode.toString();
    } catch (e) {
      return "404";
    }
  }

  // Build Methods
  List<Widget> _buildFormWidgets() {
    List<Widget> widgets = [];

    if (_formData != null) {
      for (var field in _formData!.formFieldList) {
        Widget formWidget;

        switch (field.fieldTypeCases) {
          case FormFieldType.textField:
            formWidget =
                field.isDateField
                    ? _buildDateDisplay(field)
                    : _buildTextDisplay(field);
            break;
          case FormFieldType.textArea:
            formWidget = _buildTextAreaDisplay(field);
            break;
          case FormFieldType.radio:
            formWidget = _buildRadioDisplay(field);
            break;
          case FormFieldType.dropdown:
            formWidget = _buildDropdownDisplay(field);
            break;
          case FormFieldType.checkbox:
            formWidget = _buildCheckboxDisplay(field);
            break;
          case FormFieldType.fileUpload:
            formWidget = _buildFileDisplay(field);
            break;
          default:
            formWidget = const SizedBox.shrink();
        }

        widgets.add(formWidget);
      }
    }

    // Add comment sections
    // widgets.add(
    //   _buildCommentSection(
    //     _prevComment,
    //     _strings['previousComment']!,
    //     _prevComment.isNotEmpty,
    //     // widget.fromSelf == false && _prevComment.isNotEmpty,
    //   ),
    // );

    String? finalComment;

    if (_selfComment.isNotEmpty) {
      // TODO check this approver comment !
      finalComment = _selfComment;
    } else if (_appRejComment.isNotEmpty) {
      finalComment = _appRejComment;
    } else if (_lmComment.isNotEmpty) {
      finalComment = _lmComment;
    }

    if (finalComment != null) {
      widgets.add(
        _buildCommentSection(finalComment, _strings['comment']!, true),
      );
    }

    // Add comment input field
    if (widget.show) {
      widgets.add(_buildCommentInput());
    }

    return widgets;
  }

  Widget _buildCommentInput() {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          TextFormField(
            validator: _validateComment,
            controller: _commentController,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Enter your comment here...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          100.heightBox,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: Text(widget.menuName.toString())),
      body:
          _isLoading
              ? Loader()
              : SafeArea(
                child: Padding(
                  padding: AppPadding.screenPadding,
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildFormWidgets(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      bottomSheet: Visibility(
        visible: widget.show,
        child: Padding(
          padding: AppPadding.screenBottomSheetPadding,
          child: ApproveRejectButtons(
            onApprove: () => _approveReject("A"),
            onReject: () => _approveReject("R"),
          ),
        ),
      ),
    );
  }
}
