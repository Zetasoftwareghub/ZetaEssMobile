import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//
// enum AlertType { success, warning, error, info }
//
// void showCustomAlertBox(
//   BuildContext context, {
//   required String title,
//   String? content,
//   AlertType type = AlertType.warning,
//   String? primaryButtonText,
//   String? secondaryButtonText,
//   VoidCallback? onPrimaryPressed,
//   VoidCallback? onSecondaryPressed,
//   bool barrierDismissible = true,
//   bool showCloseButton = true,
//   Duration animationDuration = const Duration(milliseconds: 300),
//   Widget? customIcon,
//   Color? customColor,
//   double? maxWidth,
//   TextAlign textAlign = TextAlign.center,
//   List<Widget>? customActions,
// }) {
//   // Get screen size for responsive design
//   final screenSize = MediaQuery.of(context).size;
//   final isTablet = screenSize.width > 600;
//   final isMobile = screenSize.width <= 600;
//
//   // Responsive sizing
//   final dialogWidth = maxWidth ?? (isTablet ? 400.0 : screenSize.width * 0.85);
//   final iconSize = isTablet ? 40.0 : 32.0;
//   final titleFontSize = isTablet ? 26.0 : 22.0;
//   final contentFontSize = isTablet ? 18.0 : 16.0;
//   final buttonFontSize = isTablet ? 18.0 : 16.0;
//   final paddingValue = isTablet ? 24.0 : 20.0;
//
//   // // Get theme colors and icon based on alert type
//   Color getAlertColor() {
//     if (customColor != null) return customColor;
//     switch (type) {
//       case AlertType.success:
//         return Colors.green.shade600;
//       case AlertType.error:
//         return Colors.red.shade600;
//       case AlertType.info:
//         return AppTheme.primaryColor;
//       case AlertType.warning:
//         return Colors.amber[800]!;
//     }
//   }
//
//   IconData getAlertIcon() {
//     switch (type) {
//       case AlertType.success:
//         return Icons.check_circle_outline;
//       case AlertType.error:
//         return Icons.error_outline;
//       case AlertType.info:
//         return Icons.info_outline;
//       case AlertType.warning:
//         return Icons.warning_amber_rounded;
//     }
//   }
//
//   final alertColor = getAlertColor();
//   final alertIcon =
//       customIcon ?? Icon(getAlertIcon(), color: Colors.white, size: iconSize);
//
//   // Haptic feedback based on alert type
//   switch (type) {
//     case AlertType.success:
//       HapticFeedback.mediumImpact();
//       break;
//     case AlertType.error:
//       HapticFeedback.heavyImpact();
//       break;
//     case AlertType.warning:
//       HapticFeedback.lightImpact();
//       break;
//     case AlertType.info:
//       HapticFeedback.selectionClick();
//       break;
//   }
//
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: barrierDismissible,
//     barrierLabel: 'Dismiss',
//     barrierColor: Colors.black.withOpacity(0.6),
//     transitionDuration: animationDuration,
//     pageBuilder: (context, animation1, animation2) => const SizedBox.shrink(),
//     transitionBuilder: (context, animation1, animation2, child) {
//       return Center(
//         child: Material(
//           type: MaterialType.transparency,
//           child: ScaleTransition(
//             scale: Tween<double>(begin: 0.7, end: 1.0).animate(
//               CurvedAnimation(
//                 parent: animation1,
//                 curve: Curves.elasticOut.flipped,
//               ),
//             ),
//             child: FadeTransition(
//               opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
//                 CurvedAnimation(
//                   parent: animation1,
//                   curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//                 ),
//               ),
//               child: Container(
//                 width: dialogWidth,
//                 constraints: BoxConstraints(
//                   maxHeight: screenSize.height * 0.8,
//                   maxWidth: screenSize.width * 0.95,
//                 ),
//                 margin: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 16.0 : 32.0,
//                   vertical: 16.0,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [alertColor, alertColor.withOpacity(0.85)],
//                     stops: const [0.0, 1.0],
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: alertColor.withOpacity(0.4),
//                       blurRadius: 24,
//                       offset: const Offset(0, 12),
//                       spreadRadius: 0,
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Stack(
//                   children: [
//                     // Background pattern
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(24),
//                           gradient: RadialGradient(
//                             center: const Alignment(0.8, -0.8),
//                             radius: 1.2,
//                             colors: [
//                               Colors.white.withOpacity(0.1),
//                               Colors.transparent,
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Close button
//                     if (showCloseButton)
//                       Positioned(
//                         top: 12,
//                         right: 12,
//                         child: Material(
//                           color: Colors.transparent,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(20),
//                             onTap: () => Navigator.of(context).pop(),
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               child: Icon(
//                                 Icons.close,
//                                 color: Colors.white.withOpacity(0.8),
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                     // Main content
//                     Padding(
//                       padding: EdgeInsets.all(paddingValue),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Animated Icon with pulsing effect
//                           TweenAnimationBuilder(
//                             duration: const Duration(milliseconds: 800),
//                             tween: Tween<double>(begin: 0.0, end: 1.0),
//                             builder: (context, double value, child) {
//                               return Transform.scale(
//                                 scale: 0.5 + (value * 0.5),
//                                 child: Container(
//                                   padding: EdgeInsets.all(isTablet ? 20 : 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.25),
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white.withOpacity(0.3),
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: alertIcon,
//                                 ),
//                               );
//                             },
//                           ),
//                           SizedBox(height: isTablet ? 24 : 20),
//
//                           // Title with slide and fade animation
//                           TweenAnimationBuilder(
//                             duration: const Duration(milliseconds: 600),
//                             tween: Tween<double>(begin: 0.0, end: 1.0),
//                             builder: (context, double value, child) {
//                               return Transform.translate(
//                                 offset: Offset(0, (1 - value) * 20),
//                                 child: Opacity(
//                                   opacity: value,
//                                   child: Text(
//                                     title.tr(),
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: titleFontSize,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 0.5,
//                                       height: 1.2,
//                                     ),
//                                     textAlign: textAlign,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                           SizedBox(height: isTablet ? 16 : 12),
//
//                           if (content != null)
//                             TweenAnimationBuilder(
//                               duration: const Duration(milliseconds: 700),
//                               tween: Tween<double>(begin: 0.0, end: 1.0),
//                               builder: (context, double value, child) {
//                                 return Transform.translate(
//                                   offset: Offset(0, (1 - value) * 30),
//                                   child: Opacity(
//                                     opacity: value,
//                                     child: Text(
//                                       content.tr(),
//                                       style: TextStyle(
//                                         color: Colors.white.withOpacity(0.95),
//                                         fontSize: contentFontSize,
//                                         height: 1.5,
//                                         letterSpacing: 0.2,
//                                       ),
//                                       textAlign: textAlign,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           SizedBox(height: isTablet ? 32 : 24),
//
//                           // Action buttons or custom actions
//                           if (customActions != null)
//                             ...customActions
//                           else
//                             TweenAnimationBuilder(
//                               duration: const Duration(milliseconds: 800),
//                               tween: Tween<double>(begin: 0.0, end: 1.0),
//                               builder: (context, double value, child) {
//                                 return Transform.translate(
//                                   offset: Offset(0, (1 - value) * 20),
//                                   child: Opacity(
//                                     opacity: value,
//                                     child: _buildActionButtons(
//                                       context,
//                                       primaryButtonText,
//                                       secondaryButtonText,
//                                       onPrimaryPressed,
//                                       onSecondaryPressed,
//                                       alertColor,
//                                       buttonFontSize,
//                                       isTablet,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
//
// Widget _buildActionButtons(
//   BuildContext context,
//   String? primaryButtonText,
//   String? secondaryButtonText,
//   VoidCallback? onPrimaryPressed,
//   VoidCallback? onSecondaryPressed,
//   Color alertColor,
//   double buttonFontSize,
//   bool isTablet,
// ) {
//   final hasSecondary = secondaryButtonText != null;
//   final hasPrimary = primaryButtonText != null;
//
//   if (!hasSecondary && !hasPrimary) {
//     // Default single OK button
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () => Navigator.of(context).pop(),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           foregroundColor: alertColor,
//           padding: EdgeInsets.symmetric(
//             vertical: isTablet ? 16 : 14,
//             horizontal: 24,
//           ),
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Text(
//           'OK',
//           style: TextStyle(
//             fontSize: buttonFontSize,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ),
//     );
//   }
//
//   return Column(
//     children: [
//       if (hasSecondary && hasPrimary)
//         Row(
//           children: [
//             Expanded(
//               child: TextButton(
//                 onPressed:
//                     onSecondaryPressed ?? () => Navigator.of(context).pop(),
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.2),
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: BorderSide(
//                       color: Colors.white.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   secondaryButtonText,
//                   style: TextStyle(
//                     fontSize: buttonFontSize,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: isTablet ? 16 : 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed:
//                     onPrimaryPressed ?? () => Navigator.of(context).pop(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: alertColor,
//                   padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
//                   elevation: 0,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   primaryButtonText,
//                   style: TextStyle(
//                     fontSize: buttonFontSize,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         )
//       else if (hasPrimary)
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: alertColor,
//               padding: EdgeInsets.symmetric(
//                 vertical: isTablet ? 16 : 14,
//                 horizontal: 24,
//               ),
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Text(
//               primaryButtonText,
//               style: TextStyle(
//                 fontSize: buttonFontSize,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         )
//       else if (hasSecondary)
//         SizedBox(
//           width: double.infinity,
//           child: TextButton(
//             onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.2),
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(
//                 vertical: isTablet ? 16 : 14,
//                 horizontal: 24,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: BorderSide(
//                   color: Colors.white.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Text(
//               secondaryButtonText,
//               style: TextStyle(
//                 fontSize: buttonFontSize,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//     ],
//   );
// }
//
/*

enum AlertType { success, warning, error, info }

// TODO professional but not looking goood. !!!
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
  bool showCloseButton = false, // Changed default to false for cleaner look
  Duration animationDuration = const Duration(
    milliseconds: 250,
  ), // Faster, more professional
  Widget? customIcon,
  Color? customColor,
  double? maxWidth,
  TextAlign textAlign = TextAlign.center,
  List<Widget>? customActions,
  EdgeInsets? customPadding,
}) {
  // Get screen size for responsive design
  final screenSize = MediaQuery.of(context).size;
  final isTablet = screenSize.width > 600;
  final isMobile = screenSize.width <= 600;

  // Enhanced responsive sizing with better proportions
  final dialogWidth = maxWidth ?? (isTablet ? 420.0 : screenSize.width * 0.88);
  final iconSize =
      isTablet ? 32.0 : 28.0; // Slightly smaller for professional look
  final titleFontSize = isTablet ? 22.0 : 20.0; // More balanced sizing
  final contentFontSize = isTablet ? 16.0 : 15.0;
  final buttonFontSize = isTablet ? 16.0 : 15.0;
  final paddingValue = customPadding ?? EdgeInsets.all(isTablet ? 32.0 : 24.0);

  // Professional color palette
  Color getAlertColor() {
    if (customColor != null) return customColor;
    switch (type) {
      case AlertType.success:
        return const Color(0xFF10B981); // Modern green
      case AlertType.error:
        return const Color(0xFFEF4444); // Clean red
      case AlertType.info:
        return const Color(0xFF3B82F6); // Professional blue
      case AlertType.warning:
        return const Color(0xFFF59E0B); // Amber warning
    }
  }

  // More professional icons
  IconData getAlertIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.cancel;
      case AlertType.info:
        return Icons.info;
      case AlertType.warning:
        return Icons.warning;
    }
  }

  final alertColor = getAlertColor();
  final alertIcon =
      customIcon ?? Icon(getAlertIcon(), color: alertColor, size: iconSize);

  // Subtle haptic feedback
  switch (type) {
    case AlertType.success:
      HapticFeedback.lightImpact();
      break;
    case AlertType.error:
      HapticFeedback.mediumImpact();
      break;
    case AlertType.warning:
      HapticFeedback.selectionClick();
      break;
    case AlertType.info:
      HapticFeedback.selectionClick();
      break;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.4), // Less aggressive overlay
    transitionDuration: animationDuration,
    pageBuilder: (context, animation1, animation2) => const SizedBox.shrink(),
    transitionBuilder: (context, animation1, animation2, child) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation1, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(
              opacity: animation1,
              child: Container(
                width: dialogWidth,
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.8,
                  maxWidth: screenSize.width * 0.95,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20.0 : 40.0,
                  vertical: 20.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Modern rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Close button (when enabled)
                    if (showCloseButton)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Main content
                    Padding(
                      padding: paddingValue,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Professional icon with subtle animation
                          TweenAnimationBuilder(
                            duration: Duration(
                              milliseconds:
                                  animationDuration.inMilliseconds + 100,
                            ),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: 0.3 + (value * 0.7),
                                child: Opacity(
                                  opacity: value,
                                  child: Container(
                                    padding: EdgeInsets.all(isTablet ? 16 : 14),
                                    decoration: BoxDecoration(
                                      color: alertColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: alertIcon,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 20),

                          // Enhanced title with better typography
                          AnimatedBuilder(
                            animation: animation1,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - animation1.value) * 10),
                                child: Opacity(
                                  opacity: animation1.value,
                                  child: Text(
                                    title.tr(),
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing:
                                          -0.2, // Tighter letter spacing for modern look
                                      height: 1.3,
                                    ),
                                    textAlign: textAlign,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Content (when provided) - more subtle
                          if (content != null && content.isNotEmpty) ...[
                            SizedBox(height: isTablet ? 12 : 10),
                            AnimatedBuilder(
                              animation: animation1,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1 - animation1.value) * 10,
                                  ),
                                  child: Opacity(
                                    opacity:
                                        animation1.value *
                                        0.8, // Slightly faded
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

                          SizedBox(height: isTablet ? 32 : 28),

                          // Action buttons
                          if (customActions != null)
                            ...customActions
                          else
                            AnimatedBuilder(
                              animation: animation1,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1 - animation1.value) * 10,
                                  ),
                                  child: Opacity(
                                    opacity: animation1.value,
                                    child: _buildActionButtons(
                                      context,
                                      primaryButtonText,
                                      secondaryButtonText,
                                      onPrimaryPressed,
                                      onSecondaryPressed,
                                      alertColor,
                                      buttonFontSize,
                                      isTablet,
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
  bool isTablet,
) {
  final hasSecondary = secondaryButtonText != null;
  final hasPrimary = primaryButtonText != null;

  if (!hasSecondary && !hasPrimary) {
    // Default single OK button - more professional styling
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: alertColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 14,
            horizontal: 32,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'OK',
          style: TextStyle(
            fontSize: buttonFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
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
              child: OutlinedButton(
                onPressed:
                    onSecondaryPressed ?? () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  secondaryButtonText,
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    onPrimaryPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: alertColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  primaryButtonText,
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        )
      else if (hasPrimary)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: alertColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 14,
                horizontal: 32,
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              primaryButtonText,
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        )
      else if (hasSecondary)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 14,
                horizontal: 32,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              secondaryButtonText,
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
    ],
  );
}

// Utility extension for easy usage
extension AlertBoxExtension on BuildContext {
  void showSuccessAlert(
    String title, {
    String? content,
    VoidCallback? onConfirm,
  }) {
    showCustomAlertBox(
      this,
      title: title,
      content: content,
      type: AlertType.success,
      primaryButtonText: 'OK',
      onPrimaryPressed: onConfirm,
    );
  }

  void showErrorAlert(
    String title, {
    String? content,
    VoidCallback? onConfirm,
  }) {
    showCustomAlertBox(
      this,
      title: title,
      content: content,
      type: AlertType.error,
      primaryButtonText: 'OK',
      onPrimaryPressed: onConfirm,
    );
  }

  void showWarningAlert(
    String title, {
    String? content,
    VoidCallback? onConfirm,
  }) {
    showCustomAlertBox(
      this,
      title: title,
      content: content,
      type: AlertType.warning,
      primaryButtonText: 'OK',
      onPrimaryPressed: onConfirm,
    );
  }

  void showInfoAlert(String title, {String? content, VoidCallback? onConfirm}) {
    showCustomAlertBox(
      this,
      title: title,
      content: content,
      type: AlertType.info,
      primaryButtonText: 'OK',
      onPrimaryPressed: onConfirm,
    );
  }

  void showConfirmationAlert(
    String title, {
    String? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showCustomAlertBox(
      this,
      title: title,
      content: content,
      type: AlertType.warning,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: onCancel,
    );
  }
}
*/
enum AlertType { success, warning, error, info }

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
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: animationDuration,
    pageBuilder: (context, animation1, animation2) => const SizedBox.shrink(),
    transitionBuilder: (context, animation1, animation2, child) {
      return Center(
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
                CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
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
                                  onTap: () => Navigator.of(context).pop(),
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
                                      title,
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
                                        content,
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
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: alertColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'OK',
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
                      onSecondaryPressed ?? () => Navigator.of(context).pop(),
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
                      onPrimaryPressed ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alertColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    primaryButtonText,
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
            onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: alertColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              primaryButtonText,
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
            onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
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
