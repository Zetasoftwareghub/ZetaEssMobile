import 'package:flutter/material.dart';

TimeOfDay? formatTime24toAmPmString(String? timeString) {
  if (timeString == null || timeString.isEmpty) return null;
  try {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    return null;
  }
}
