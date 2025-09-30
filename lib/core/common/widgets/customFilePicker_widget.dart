import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';

class FileUploadButton extends ConsumerWidget {
  final String? editFileUrl;
  final String? uploadInstructionText; // Custom text below upload button

  const FileUploadButton({
    super.key,
    this.editFileUrl,
    this.uploadInstructionText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileUploadProvider);
    final notifier = ref.read(fileUploadProvider.notifier);

    final selectedFile = fileState.value?.platformFile;
    final hasExistingFile = editFileUrl != null && editFileUrl!.isNotEmpty;
    final hasNewFile = selectedFile != null;
    final showExistingFile =
        hasExistingFile && !hasNewFile && !fileState.value!.isCleared;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fileState.isLoading)
          const Loader()
        else if (showExistingFile)
          // Show existing file
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(_getFileIcon(editFileUrl!), color: AppTheme.primaryColor),
                10.widthBox,
                Expanded(
                  child: Text(
                    _getFileNameFromUrl(editFileUrl!),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.widthBox,
                // View button for existing file
                if (_isImage(editFileUrl!))
                  InkWell(
                    onTap: () => _showFullImage(context, editFileUrl!),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () => _launchFile(editFileUrl!),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.open_in_new,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                  ),
                4.widthBox,
                InkWell(
                  onTap: () {
                    notifier.clearExistingFile();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ],
            ),
          )
        else if (hasNewFile)
          // Show newly selected file with size info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  color: AppTheme.primaryColor,
                ),
                10.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedFile.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatFileSize(selectedFile.size),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                8.widthBox,
                InkWell(
                  onTap: () {
                    notifier.clearFile();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ],
            ),
          )
        else
          // Show upload button
          OutlinedButton.icon(
            onPressed: () {
              notifier.pickFile();
            },
            icon: const Icon(
              Icons.upload_file_outlined,
              color: AppTheme.primaryColor,
            ),
            label: Text(
              "upload_file".tr(),
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 14.sp),
            ),
          ),
        5.heightBox,
        // Show error message if file size exceeded
        if (fileState.hasError && fileState.error is FileSizeException)
          Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: Text(
              fileState.error.toString(),
              style: TextStyle(fontSize: 12.sp, color: Colors.redAccent),
            ),
          ),
        // Custom instruction text or default
        Text(
          uploadInstructionText ?? '*${'upload_1_supported_file'.tr()}',
          style: TextStyle(fontSize: 12.sp, color: AppTheme.primaryColor),
        ),
        // File size limit info
        Text(
          'Maximum file size: 10MB'.tr(), // Add this to your localization files
          style: TextStyle(
            fontSize: 11.sp,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    int i = (bytes.bitLength - 1) ~/ 10;
    return "${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}";
  }

  String _getFileNameFromUrl(String url) {
    // Extract filename from URL
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      return segments.last;
    }
    return 'attachment';
  }

  IconData _getFileIcon(String url) {
    final extension = path.extension(url).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  bool _isImage(String url) {
    final extension = path.extension(url).toLowerCase();
    return ['.jpg', '.jpeg', '.png'].contains(extension);
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Could not load image',
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _launchFile(String fileUrl) async {
    final url = Uri.parse(fileUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Handle error - could show a snackbar or dialog
      debugPrint('Could not launch $fileUrl');
    }
  }
}

// Custom exception for file size validation
class FileSizeException implements Exception {
  final String message;
  FileSizeException(this.message);

  @override
  String toString() => message;
}

//File providers !
final fileUploadProvider =
    AutoDisposeAsyncNotifierProvider<FileUploadNotifier, FileUploadState>(
      FileUploadNotifier.new,
    );

class FileUploadState {
  final String? base64;
  final String? extension;
  final PlatformFile? platformFile;
  final bool isCleared; // Track if existing file was cleared

  FileUploadState({
    this.base64,
    this.extension,
    this.platformFile,
    this.isCleared = false,
  });

  FileUploadState copyWith({
    String? base64,
    String? extension,
    PlatformFile? platformFile,
    bool? isCleared,
  }) {
    return FileUploadState(
      base64: base64 ?? this.base64,
      extension: extension ?? this.extension,
      platformFile: platformFile ?? this.platformFile,
      isCleared: isCleared ?? this.isCleared,
    );
  }
}

class FileUploadNotifier extends AutoDisposeAsyncNotifier<FileUploadState> {
  static const int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB

  @override
  FileUploadState build() {
    return FileUploadState();
  }

  Future<void> pickFile() async {
    state = const AsyncValue.loading();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc'],
      );

      if (result != null) {
        final selectedFile = result.files.first;

        // Validate file size
        if (selectedFile.size > maxFileSizeInBytes) {
          state = AsyncValue.error(
            FileSizeException(
              'file_too_large_10mb'.tr(),
            ), // Add this to your localization
            StackTrace.current,
          );
          return;
        }

        final file = File(selectedFile.path!);
        final bytes = await file.readAsBytes();
        final base64 = base64Encode(bytes);

        state = AsyncValue.data(
          FileUploadState(
            base64: base64,
            extension: selectedFile.extension,
            platformFile: selectedFile,
            isCleared: false,
          ),
        );
      } else {
        // Cancelled - maintain current state
        if (state.hasValue) {
          state = AsyncValue.data(state.value!);
        } else {
          state = AsyncValue.data(FileUploadState());
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearFile() {
    state = AsyncValue.data(FileUploadState()); // Reset state completely
  }

  void clearExistingFile() {
    // Mark existing file as cleared but don't reset everything
    state = AsyncValue.data(FileUploadState(isCleared: true));
  }

  // Helper method to check if there's any file (new or existing)
  bool hasFile(String? existingFileUrl) {
    final currentState = state.value;
    if (currentState == null) return false;

    // Has new file
    if (currentState.platformFile != null) return true;

    // Has existing file that's not cleared
    if (existingFileUrl != null &&
        existingFileUrl.isNotEmpty &&
        !currentState.isCleared) {
      return true;
    }

    return false;
  }

  // Helper method to get the current file data for API calls
  Map<String, dynamic>? getFileData(String? existingFileUrl) {
    final currentState = state.value;
    if (currentState == null) return null;

    // Return new file data if available
    if (currentState.platformFile != null) {
      return {
        'base64': currentState.base64,
        'extension': currentState.extension,
        'fileName': currentState.platformFile!.name,
        'isNew': true,
      };
    }

    // Return existing file data if not cleared
    if (existingFileUrl != null &&
        existingFileUrl.isNotEmpty &&
        !currentState.isCleared) {
      return {'url': existingFileUrl, 'isNew': false};
    }

    return null;
  }
}
