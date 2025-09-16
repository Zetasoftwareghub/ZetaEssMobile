import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

/// Converts `DateTime` → "dd/MM/yyyy"
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Converts "yyyyMMdd" (e.g., 20250711) → "dd/MM/yy" (e.g., 11/07/25)
String convertDateYYYMMDDtoStringDate(String? dateStr) {
  if (dateStr == null || dateStr.length != 8) return '';
  try {
    final parsedDate = DateTime.parse(dateStr); // parses yyyyMMdd
    return "${parsedDate.day.toString().padLeft(2, '0')}/"
        "${parsedDate.month.toString().padLeft(2, '0')}/"
        "${parsedDate.year.toString().substring(2)}";
  } catch (e) {
    return '';
  }
}

/// Converts "dd/MM/yyyy" → ISO8601 (e.g., "2025-07-11T00:00:00.000Z")
String convertDateToIso(String dateStr) {
  final inputFormat = DateFormat('dd/MM/yyyy');
  final date = inputFormat.parse(dateStr);
  return date.toUtc().toIso8601String();
}

/// Converts "dd/MM/yyyy HH:mm" → "hh:mm" (12-hour format)
String convertDateTimeToHours(String? timeString) {
  if (timeString == null || timeString.isEmpty) return '--:--';
  try {
    final parsed = DateFormat('dd/MM/yyyy HH:mm').parse(timeString);
    return DateFormat('hh:mm').format(parsed);
  } catch (_) {
    return '--:--';
  }
}

/// Converts "dd/MM/yyyy HH:mm" → "AM"/"PM"
String convertDateTimeToAMorPM(String? timeString) {
  if (timeString == null || timeString.isEmpty) return '';
  try {
    final parsed = DateFormat('dd/MM/yyyy HH:mm').parse(timeString);
    return DateFormat('a').format(parsed).toUpperCase();
  } catch (_) {
    return '';
  }
}

/// Converts "MMM yyyy" (e.g., "Jul 2025") → "MM-yyyy" (e.g., "07-2025")
String convertMonthYearToMMYYYY(String? input) {
  if (input == null || input.trim().isEmpty) return '';
  try {
    final inputFormat = DateFormat('MMM yyyy', 'en_US');
    final outputFormat = DateFormat('MM-yyyy');
    final date = inputFormat.parse(input);
    return outputFormat.format(date);
  } catch (e) {
    return '';
  }
}

/// Converts raw date string
///  (e.g., "2025-07-11T00:00:00.000Z") to formatted string July 11 2025
String convertRawDateToString(String? rawDate) {
  if (rawDate == null) return '';
  final date = DateTime.parse(rawDate);
  return DateFormat("dd/MM/yyyy").format(date);
}

String convertRawDateAndTimeToDate(String rawDate) {
  DateTime parsedDate = DateFormat("M/d/yyyy h:mm:ss a").parse(rawDate);

  String formattedDate = DateFormat("dd/MM/yyyy").format(parsedDate);
  return formattedDate;
}

String convertDateToYYmmDD(DateTime date) {
  return DateFormat("yyyy/MM/dd").format(date);
}
