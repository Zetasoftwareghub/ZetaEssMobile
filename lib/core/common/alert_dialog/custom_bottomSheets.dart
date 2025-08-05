import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//TODO modify and use in the bottom sheet screen
void showCustomDraggableBottomSheet({
  required BuildContext context,
  required Widget child,
  double initialSize = 0.5,
  double minSize = 0.3,
  double maxSize = 0.9,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: child,
          );
        },
      );
    },
  );
}

void showCustomBottomSheet({
  required BuildContext context,
  required Widget child,
  double heightFraction = 0.5,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * heightFraction,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: SingleChildScrollView(child: child),
      );
    },
  );
}
