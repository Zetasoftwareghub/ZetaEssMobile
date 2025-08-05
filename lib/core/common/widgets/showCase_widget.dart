import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../theme/app_theme.dart';

class CustomShowcaseWidget extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String? description;
  final Widget child;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? descriptionTextStyle;
  final EdgeInsets? padding;

  const CustomShowcaseWidget({
    required this.showcaseKey,
    required this.title,
    this.description,
    required this.child,
    this.backgroundColor,
    this.titleTextStyle,
    this.descriptionTextStyle,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      titleTextStyle:
          titleTextStyle ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
      descTextStyle:
          descriptionTextStyle ??
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      tooltipBackgroundColor: backgroundColor ?? AppTheme.primaryColor,
      titlePadding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
