import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/other_request/screens/other_request_list_screen.dart';

import '../providers/other_request_providers.dart';

class OtherRequestFirstListingScreen extends ConsumerWidget {
  final String title;
  const OtherRequestFirstListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherRequestAsync = ref.watch(otherRequestFirstListingProvider);

    final List<Color> borderColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title.tr())),
      backgroundColor: Colors.grey.shade50,
      body: otherRequestAsync.when(
        data: (list) {
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: list.length,
            separatorBuilder: (_, __) => 12.heightBox,
            itemBuilder: (context, index) {
              final item = list[index];
              // Cycle through colors based on index
              final color = borderColors[index % borderColors.length];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w, // adjust as per design
                      height: 60.h, // match your tile height
                      decoration: BoxDecoration(
                        color: color, // your dynamic color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          bottomLeft: Radius.circular(12.r),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 3.h,
                        ),
                        title: Text(
                          (item.menuName?.toUpperCase() ?? 'No name'),

                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        trailing: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: color,
                          ),
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          NavigationService.navigateToScreen(
                            context: context,
                            screen: OtherRequestListingScreen(
                              title: item.menuName?.toUpperCase() ?? 'No Name',
                              requestId: item.lRTPAC, //rqtmcd
                              micode: item.menuId,
                            ),
                          );
                          // navigate or perform action
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Loader(),
        error: (err, _) => ErrorText(error: err.toString()),
      ),
    );
  }
}
