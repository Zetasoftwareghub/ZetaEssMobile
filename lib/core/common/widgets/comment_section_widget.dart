import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../common_ui_stuffs.dart';

class CommentSection extends StatelessWidget {
  final String? lmComment;
  final String? prevComment;
  final String? finalComment;

  final bool isSelf;
  final bool isApproveTab;
  final bool isLineManagerSelfTab;

  const CommentSection({
    super.key,
    this.lmComment,
    this.prevComment,
    this.finalComment,
    this.isSelf = false,
    this.isApproveTab = false,
    this.isLineManagerSelfTab = false,
  });

  /// Helper to check and return a labeled comment widget
  Widget? _buildComment(String? text) {
    if (text?.trim().isEmpty ?? true) return null;
    return Text(text ?? 'No comment');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> commentWidgets = [];

    if (isLineManagerSelfTab) {
      final widget = _buildComment(lmComment);
      if (widget != null) commentWidgets.add(widget);
    }

    if (isApproveTab) {
      final widget = _buildComment(prevComment);
      if (widget != null) commentWidgets.add(widget);
    }

    if (isSelf) {
      final widget = _buildComment(finalComment);
      if (widget != null) commentWidgets.add(widget);
    }

    if (commentWidgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHeaderText('comment'.tr()),
        const SizedBox(height: 8),
        ...commentWidgets,
      ],
    );
  }
}
