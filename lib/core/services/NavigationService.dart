import 'package:flutter/material.dart';

class NavigationService {
  static navigateToScreen({
    required BuildContext context,
    required Widget screen,
  }) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  static navigateRemoveUntil({
    required BuildContext context,
    required Widget screen,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  static navigatePushReplacement({
    required BuildContext context,
    required Widget screen,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
