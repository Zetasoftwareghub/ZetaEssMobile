import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2595CD);
  static const Color lightBlueColor = Color(0xE2A6E1F6);
  static const Color greenFigColor = Color(0xFF04A839);
  static const Color scaffoldBackgroundColor = Color(0xFFF6F6F6);
  static const Color successColor = Color(0xFF04A839);
  static const Color errorColor = Colors.red;

  static final CalendarStyle commonTableCalenderStyle = CalendarStyle(
    // Selected range styles
    rangeStartDecoration: BoxDecoration(
      color: AppTheme.primaryColor,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    rangeEndDecoration: BoxDecoration(
      color: AppTheme.primaryColor,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    withinRangeDecoration: BoxDecoration(
      color: AppTheme.primaryColor.withOpacity(0.2),
      shape: BoxShape.circle,
    ),

    // Today style
    todayDecoration: BoxDecoration(
      gradient: LinearGradient(
        // colors: [Colors.redAccent.shade100, Colors.redAccent.shade400],
        colors: [Colors.green.shade100, Colors.greenAccent.shade400],
      ),
      shape: BoxShape.circle,
    ),
    todayTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 13.sp,
    ),

    // Selected day style
    selectedDecoration: BoxDecoration(
      color: AppTheme.primaryColor,
      shape: BoxShape.circle,
    ),
    selectedTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 13.sp,
    ),

    // Default day style
    defaultTextStyle: TextStyle(fontSize: 13.sp, color: Colors.black87),

    // Weekend style
    weekendTextStyle: TextStyle(
      fontSize: 13.sp,
      color: Colors.redAccent.shade200,
    ),

    // Outside days (from previous/next month)
    outsideTextStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),

    // Disable dots/highlight on disabled days
    disabledTextStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade300),

    // Cell margin/padding for spacing
    cellMargin: EdgeInsets.all(4),
    cellPadding: EdgeInsets.all(4),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Urbanist',
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        titleTextStyle: AppTextStyles.mediumFont(),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      splashColor: lightBlueColor,

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.5),
        selectionHandleColor: primaryColor,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),

      tabBarTheme: TabBarThemeData(
        indicatorColor: AppTheme.primaryColor,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        dividerColor: Colors.grey.shade200,
        labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12.sp,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          side: BorderSide(color: AppTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: primaryColor),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        labelStyle: TextStyle(fontSize: 14.sp),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10.r),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(10.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
      ),
    );
  }
}
