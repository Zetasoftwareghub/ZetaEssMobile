import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/services/firebase_notification.dart';
import 'core/theme/app_theme.dart';
import 'core/utils.dart';
import 'features/splash_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await _initialise();
  await _setPreferredOrientations();
  runApp(const ZetaApp());
}

Future<void> _initialise() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  await FCMService.initialize();
}

Future<void> _setPreferredOrientations() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class ZetaApp extends StatelessWidget {
  const ZetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('hi'),
        Locale('ml'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(393, 851),
          builder:
              (context, child) => MaterialApp(
                navigatorKey: navigatorKey,

                navigatorObservers: [SnackBarNavigatorObserver()],
                builder:
                    (context, child) => SafeArea(
                      // child: child!,
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: child!,
                      ),
                    ),
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                theme: AppTheme.lightTheme,
                debugShowCheckedModeBanner: false,
                home: SplashScreen(),
              ),
        ),
      ),
    );
  }
}
