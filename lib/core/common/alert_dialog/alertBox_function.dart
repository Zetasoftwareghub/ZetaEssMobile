import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AlertType { success, warning, error, info }

bool isPopping = false;

void showCustomAlertBox(
  BuildContext context, {
  required String title,
  String? content,
  AlertType type = AlertType.warning,
  String? primaryButtonText,
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
  bool barrierDismissible = true,
  bool showCloseButton = true,
  Duration animationDuration = const Duration(milliseconds: 300),
  Widget? customIcon,
  Color? customColor,
  double? maxWidth,
  TextAlign textAlign = TextAlign.center,
  List<Widget>? customActions,
}) {
  // Get screen size for responsive design
  final screenSize = MediaQuery.of(context).size;
  final isTablet = screenSize.width > 600;

  // Compact sizing
  final dialogWidth = maxWidth ?? (isTablet ? 320.0 : screenSize.width * 0.75);
  final iconSize = 20.0;
  final titleFontSize = isTablet ? 18.0 : 16.0;
  final contentFontSize = isTablet ? 15.0 : 14.0;
  final buttonFontSize = isTablet ? 15.0 : 14.0;

  // Get theme colors and icon based on alert type
  Color getAlertColor() {
    if (customColor != null) return customColor;
    switch (type) {
      case AlertType.success:
        return Colors.green.shade600;
      case AlertType.error:
        return Colors.red.shade600;
      case AlertType.info:
        return Colors.blue.shade600;
      case AlertType.warning:
        return Colors.amber[800]!;
    }
  }

  IconData getAlertIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.info:
        return Icons.info;
      case AlertType.warning:
        return Icons.warning;
    }
  }

  final alertColor = getAlertColor();
  final alertIcon =
      customIcon ?? Icon(getAlertIcon(), color: alertColor, size: iconSize);

  // Haptic feedback based on alert type
  switch (type) {
    case AlertType.success:
      HapticFeedback.mediumImpact();
      break;
    case AlertType.error:
      HapticFeedback.heavyImpact();
      break;
    case AlertType.warning:
      HapticFeedback.lightImpact();
      break;
    case AlertType.info:
      HapticFeedback.selectionClick();
      break;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss'.tr(),
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: animationDuration,
    pageBuilder: (context, animation1, animation2) => const SizedBox.shrink(),
    transitionBuilder: (context, animation1, animation2, child) {
      return Center(
        child: WillPopScope(
          onWillPop: () async => false,
          child: Material(
            type: MaterialType.transparency,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation1,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation1,
                  child: Container(
                    width: dialogWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: alertColor.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with colored top border and icon
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          decoration: BoxDecoration(
                            color: alertColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            border: Border(
                              top: BorderSide(color: alertColor, width: 3),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Close button (if enabled)
                              if (showCloseButton)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isPopping) return;
                                      isPopping = true;
                                      Navigator.of(context).pop();
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          isPopping = false;
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),

                              SizedBox(height: showCloseButton ? 8 : 0),

                              // Animated Icon with bounce effect
                              TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: 0.5 + (value * 0.5),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: alertColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: alertColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: alertIcon,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              // Title with slide animation
                              TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 500),
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                builder: (context, double value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (1 - value) * 10),
                                    child: Opacity(
                                      opacity: value,
                                      child: Text(
                                        title.tr(),
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: textAlign,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Content area
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            children: [
                              if (content != null) ...[
                                const SizedBox(height: 8),
                                TweenAnimationBuilder(
                                  duration: const Duration(milliseconds: 600),
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  builder: (context, double value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, (1 - value) * 15),
                                      child: Opacity(
                                        opacity: value,
                                        child: Text(
                                          content.tr(),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: contentFontSize,
                                            height: 1.4,
                                            letterSpacing: 0.1,
                                          ),
                                          textAlign: textAlign,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Action buttons
                              if (customActions != null)
                                ...customActions
                              else
                                TweenAnimationBuilder(
                                  duration: const Duration(milliseconds: 700),
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  builder: (context, double value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, (1 - value) * 10),
                                      child: Opacity(
                                        opacity: value,
                                        child: _buildActionButtons(
                                          context,
                                          primaryButtonText,
                                          secondaryButtonText,
                                          onPrimaryPressed,
                                          onSecondaryPressed,
                                          alertColor,
                                          buttonFontSize,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildActionButtons(
  BuildContext context,
  String? primaryButtonText,
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
  Color alertColor,
  double buttonFontSize,
) {
  final hasSecondary = secondaryButtonText != null;
  final hasPrimary = primaryButtonText != null;
  if (!hasSecondary && !hasPrimary) {
    // Default single OK button
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          if (isPopping) return;
          isPopping = true;
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 500), () {
            isPopping = false;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: alertColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'OK'.tr(),
          style: TextStyle(
            fontSize: buttonFontSize,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  return Column(
    children: [
      if (hasSecondary && hasPrimary)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed:
                      onSecondaryPressed ??
                      () {
                        if (isPopping) return;
                        isPopping = true;
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          isPopping = false;
                        });
                      },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    secondaryButtonText,
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed:
                      onPrimaryPressed ??
                      () {
                        if (isPopping) return;
                        isPopping = true;
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          isPopping = false;
                        });
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alertColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    primaryButtonText.tr(),
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      else if (hasPrimary)
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed:
                onPrimaryPressed ??
                () {
                  if (isPopping) return;
                  isPopping = true;
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    isPopping = false;
                  });
                },
            style: ElevatedButton.styleFrom(
              backgroundColor: alertColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              primaryButtonText.tr(),
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        )
      else if (hasSecondary)
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed:
                onSecondaryPressed ??
                () {
                  if (isPopping) return;
                  isPopping = true;
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    isPopping = false;
                  });
                },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              secondaryButtonText,
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
    ],
  );
}
