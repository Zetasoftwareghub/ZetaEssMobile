import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/loders/customScreen_loader.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/common/models/download_model.dart';

import '../../providers/common_ui_providers.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('downloads'.tr())),
      body: downloadsAsync.when(
        loading: () => CustomScreenLoader(loadingText: 'loading_menus'),
        error:
            (err, stack) => Center(
              child: Container(
                margin: EdgeInsets.all(32.r),
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Oops! Something went wrong'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Unable to load your downloads'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onErrorContainer.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(downloadListProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        data: (downloads) {
          if (downloads.isEmpty) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(32.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'No downloads yet'.tr(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Your downloaded files will appear here\nonce you start downloading'
                          .tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Beautiful stats header
              Container(
                margin: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 8.r),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.download_done_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${downloads.length} ${downloads.length == 1 ? 'File' : 'Files'}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Successfully downloaded'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amazing downloads list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 24.r),
                  itemCount: downloads.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final doc = downloads[index];
                    return _AwesomeDownloadTile(
                      doc: doc,
                      index: index,
                      onTap: () => _handleFileTap(context, doc, ref),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleFileTap(
    BuildContext context,
    DocumentModel doc,
    WidgetRef ref,
  ) async {
    final fullUrl =
        '${ref.watch(userContextProvider).userBaseUrl}/DownloadFormats/${doc.fileKey}';
    final uri = Uri.parse(fullUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $fullUrl");
    }
  }
}

class _AwesomeDownloadTile extends StatelessWidget {
  final dynamic doc;
  final int index;
  final VoidCallback onTap;

  const _AwesomeDownloadTile({
    required this.doc,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileIcon = _getFileIcon();
    final iconColor = _getIconColor(theme);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                // Stunning file icon
                Hero(
                  tag: 'file_icon_$index',
                  child: Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          iconColor.withOpacity(0.2),
                          iconColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(fileIcon, size: 28, color: iconColor),
                  ),
                ),

                SizedBox(width: 16.w),

                // File details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.fileName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (doc.description.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          doc.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      SizedBox(height: 12.h),

                      // Beautiful file key chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.6,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.key_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.8),
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                _truncateFileKey(doc.fileKey),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Elegant arrow indicator
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    final fileName = doc.fileName.toLowerCase();
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx'))
      return Icons.description_rounded;
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx'))
      return Icons.table_chart_rounded;
    if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx'))
      return Icons.slideshow_rounded;
    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif'))
      return Icons.image_rounded;
    if (fileName.endsWith('.mp4') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mov'))
      return Icons.video_file_rounded;
    if (fileName.endsWith('.mp3') ||
        fileName.endsWith('.wav') ||
        fileName.endsWith('.m4a'))
      return Icons.audio_file_rounded;
    if (fileName.endsWith('.zip') ||
        fileName.endsWith('.rar') ||
        fileName.endsWith('.7z'))
      return Icons.folder_zip_rounded;
    if (fileName.endsWith('.txt')) return Icons.text_snippet_rounded;
    if (fileName.endsWith('.json') || fileName.endsWith('.xml'))
      return Icons.code_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _getIconColor(ThemeData theme) {
    final fileName = doc.fileName.toLowerCase();
    if (fileName.endsWith('.pdf')) return Colors.red.shade600;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx'))
      return Colors.blue.shade600;
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx'))
      return Colors.green.shade600;
    if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx'))
      return Colors.orange.shade600;
    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif'))
      return Colors.purple.shade600;
    if (fileName.endsWith('.mp4') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mov'))
      return Colors.indigo.shade600;
    if (fileName.endsWith('.mp3') ||
        fileName.endsWith('.wav') ||
        fileName.endsWith('.m4a'))
      return Colors.pink.shade600;
    if (fileName.endsWith('.zip') ||
        fileName.endsWith('.rar') ||
        fileName.endsWith('.7z'))
      return Colors.amber.shade700;
    if (fileName.endsWith('.txt')) return Colors.grey.shade600;
    if (fileName.endsWith('.json') || fileName.endsWith('.xml'))
      return Colors.teal.shade600;
    return theme.colorScheme.primary;
  }

  String _truncateFileKey(String fileKey) {
    if (fileKey.length <= 16) return fileKey;
    return '${fileKey.substring(0, 6)}...${fileKey.substring(fileKey.length - 6)}';
  }
}
