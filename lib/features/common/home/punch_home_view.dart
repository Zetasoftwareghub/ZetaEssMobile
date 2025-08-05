import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/home/providers/punch_providers.dart';
import 'package:zeta_ess/services/location_service.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/showCase_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/common_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../models/punch_model.dart';
import '../screens/widgets/clock.dart';
import 'controller/liveLocation_controller.dart';
import 'home_screen.dart';

//TODO is this correct or not? IDK

class PunchHomeView extends ConsumerStatefulWidget {
  final ShowcaseKeys showcaseKeys;

  const PunchHomeView({super.key, required this.showcaseKeys});

  @override
  ConsumerState<PunchHomeView> createState() => _PunchHomeViewState();
}

class _PunchHomeViewState extends ConsumerState<PunchHomeView> {
  LiveLocation? currentLocation;
  final isPunchingProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
          ),
          width: 350.w,
          child: Column(
            children: [
              Text(
                "working_time".tr(),
                style: AppTextStyles.mediumFont(color: Colors.black54),
              ),
              10.heightBox,

              const RealTimeClock(),

              Text(
                '${"employee_id".tr()} : ${ref.watch(userDataProvider)?.eminid} ',
                style: AppTextStyles.smallFont(fontWeight: FontWeight.bold),
              ),
              5.heightBox,
              SizedBox(height: 45.h, child: _buildLocationRow()),

              5.heightBox,
              _buildPunchButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    final liveLocation = ref.watch(liveLocationControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CupertinoIcons.location_solid, color: AppTheme.primaryColor),
        7.widthBox,
        liveLocation.when(
          data: (loc) {
            currentLocation = loc;
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Add this

                children: [
                  Text(
                    loc.placeName,
                    style: AppTextStyles.smallFont(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Geofencing: ${loc.position.latitude}, ${loc.position.longitude} ",
                    style: AppTextStyles.smallFont(fontSize: 12.sp),
                  ),
                ],
              ),
            );
          },
          loading:
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Loader(),
                  8.widthBox,
                  TextButton(
                    onPressed:
                        () => ref.refresh(liveLocationControllerProvider),
                    child: Text('Retry'),
                  ),
                ],
              ),
          error: (e, _) {
            final errorMsg = e.toString();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200.w,
                  child: ErrorText(
                    error: errorMsg.replaceAll('Exception:', '').trim(),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.refresh(liveLocationControllerProvider),
                  child: Text('retry'.tr()),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPunchButton() {
    final punchState = ref.watch(punchDetailsProvider);
    final isPunching = ref.watch(isPunchingProvider);

    return punchState.when(
      loading: () => const Loader(),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (punchList) {
        bool isCheckIn = _shouldCheckIn(punchList);
        final inTime = getFormattedPunchTime(punchList, 'in');
        final outTime = getFormattedPunchTime(punchList, 'out');

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.done_all, color: AppTheme.greenFigColor),
                    8.widthBox,
                    Text(
                      inTime ?? 'in'.tr(),
                      style: AppTextStyles.mediumFont(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.remove_done, color: AppTheme.errorColor),
                    8.widthBox,

                    Text(
                      outTime ?? 'out'.tr(),
                      style: AppTextStyles.mediumFont(),
                    ),
                  ],
                ),
              ],
            ),
            isPunching
                ? Loader()
                : Container(
                  decoration: _punchButtonDecoration(),
                  child: ElevatedButton(
                    style: _punchButtonStyle(isCheckIn: isCheckIn),
                    onPressed:
                        isPunching
                            ? null
                            : () async {
                              ref.read(isPunchingProvider.notifier).state =
                                  true;

                              final hasPermission =
                                  await LocationService.hasPermission();
                              if (!hasPermission) {
                                showSnackBar(
                                  context: context,
                                  content:
                                      'Location is disabled or not granted',
                                );
                                ref.read(isPunchingProvider.notifier).state =
                                    false;

                                return;
                              }

                              if (currentLocation != null) {
                                final ipAddress = await getWifiIpAddress();

                                await ref
                                    .read(savePunchProvider.notifier)
                                    .save(
                                      loc: currentLocation!,
                                      isCheckIn: isCheckIn,
                                      locationTime:
                                          ref
                                              .read(locationTimeProvider)
                                              .toString(),
                                      ipAddress: ipAddress ?? '',
                                      context: context,
                                      punchDetails: punchList,
                                    );
                                ref.invalidate(punchDetailsProvider);
                              } else {
                                showSnackBar(
                                  content: 'Location is not fetched',
                                  context: context,
                                );
                              }
                              ref.read(isPunchingProvider.notifier).state =
                                  false;
                            },
                    child: CustomShowcaseWidget(
                      showcaseKey: widget.showcaseKeys.punchKey,
                      title: "Attendance Tracker",
                      description: "Tap here to punch in or out.",

                      child: Text(
                        isCheckIn ? "check_in".tr() : "check_out".tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  Future<String?> getWifiIpAddress() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiIP();
    } catch (e) {
      print("ErrorIP address: $e");
      return '';
    }
  }

  //TODO do you understadn this????
  bool _shouldCheckIn(List<PunchModel> punches) {
    if (punches.isEmpty) return true;

    final latest = punches.first;
    final type = latest.punchType?.toLowerCase();
    final mode = latest.punchMode;
    print(mode);
    print("mode");
    if (mode == "FILO") {
      return punches.isEmpty;
    }

    if (type == "in") {
      return false;
    } else {
      return true;
    }
  }

  String? getFormattedPunchTime(List<PunchModel> list, String type) {
    try {
      final punch =
          type == 'in'
              ? list.lastWhere((p) => p.punchType?.toLowerCase() == 'in')
              : list.firstWhere((p) => p.punchType?.toLowerCase() == 'out');

      if (punch.punchTime != null) {
        return convertDateTimeToHours(punch.punchTime!) +
            convertDateTimeToAMorPM(punch.punchTime!);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  BoxDecoration _punchButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade400, Colors.blue.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  ButtonStyle _punchButtonStyle({required bool isCheckIn}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isCheckIn ? AppTheme.greenFigColor : Colors.red,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }
}
