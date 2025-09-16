import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/features/common/screens/main_screen.dart';

class NoServer extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoServer({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your SVG or Lottie animation
              Text(
                'No Connection',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'We are unable to reach the server right now. Please check your internet connection or try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 28.h),
              ElevatedButton(
                onPressed:
                    onRetry ??
                    () {
                      NavigationService.navigateRemoveUntil(
                        context: context,
                        screen: MainScreen(),
                      );
                    },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Try Again', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
