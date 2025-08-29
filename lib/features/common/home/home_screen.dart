import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/features/common/home/calender_home_view.dart';
import 'package:zeta_ess/features/common/home/widgets/quickAction_widget.dart';
import 'package:zeta_ess/features/common/screens/widgets/customDrawer.dart';

import 'attendance_history.dart';
import 'home_header_section.dart';

final toggleCalendarProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  final bool showCheckInOut;
  final List<String> quickActions;

  const HomeScreen({
    super.key,
    required this.showCheckInOut,
    required this.quickActions,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _showcaseKeys = ShowcaseKeys();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    //TODO check this and implemetn show case in new build
    //_initializeShowcase();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /*  TODO IS THIS NEEDED IF AM USING STREAM PROVIDER ?@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.showCheckInOut) {
      debugPrint("App resumed, checking location status...");
      ref.invalidate(liveLocationProvider);
    }
  }*/

  //TODO check this and implemetn show case in new build
  // Future<void> _initializeShowcase() async {
  //   const storage = FlutterSecureStorage();
  //   final hasShown =
  //       await storage.read(key: StorageKeys.hasShownShowcase) == 'true';
  //
  //   if (!hasShown) {
  //     Future.delayed(const Duration(milliseconds: 100), () {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         ShowCaseWidget.of(context).startShowCase(_showcaseKeys.getAllKeys());
  //       });
  //     });
  //     await storage.write(key: StorageKeys.hasShownShowcase, value: 'true');
  //   }
  // }

  bool isCheckIn = true;

  @override
  Widget build(BuildContext context) {
    final showCalendar = ref.watch(toggleCalendarProvider);

    return showCalendar
        ? CalendarHomeView(showCheckInOut: widget.showCheckInOut)
        : Scaffold(
          key: _scaffoldKey,
          drawerEdgeDragWidth: 75.w,
          extendBodyBehindAppBar: true,
          drawer: CustomDrawer(),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSection(scaffoldKey: _scaffoldKey),

                  if (widget.quickActions.isNotEmpty)
                    QuickActionsSection(
                      showcaseKey: _showcaseKeys.quickViewKey,
                      quickActionItems: widget.quickActions,
                    ),
                  AttendanceHistorySection(
                    showcaseKey: _showcaseKeys.historyView,
                  ),
                  AttendanceListSection(),
                ],
              ),
            ),
          ),
        );
  }
}

class ShowcaseKeys {
  final GlobalKey menuKey = GlobalKey();
  final GlobalKey punchKey = GlobalKey();
  final GlobalKey quickViewKey = GlobalKey();
  final GlobalKey historyView = GlobalKey();
  final GlobalKey notificationKey = GlobalKey();

  List<GlobalKey> getAllKeys() => [
    punchKey,
    menuKey,
    quickViewKey,
    historyView,
    notificationKey,
  ];
}
