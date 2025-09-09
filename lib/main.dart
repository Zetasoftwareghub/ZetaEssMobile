import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/app_theme.dart';
import 'features/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initialise();
  await _setPreferredOrientations();
  await _configureSystemUI();
  runApp(const ZetaApp());
}

Future<void> _configureSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

Future<void> _initialise() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  //
  // // Capture async errors
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  // await FirebaseNotificationService.initialize();

  await EasyLocalization.ensureInitialized();
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
                //TODO this is not working WHY? home: ConnectivityListener(child: SplashScreen()),No internet causes crash	Guard all network-dependent logic
                //TODO  Geolocator fails silently and breaks UI	Ensure connectivity before calling geolocator
              ),
        ),
      ),
    );
  }
}

// // 7. Updated main.dart
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await _initialise();
//   await _setPreferredOrientations();
//
//   // Initialize network connectivity service
//   await NetworkConnectivityService().initialize();
//
//   runApp(const ZetaApp());
// }
//
// Future<void> _initialise() async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await FirebaseNotificationService.initialize();
//   await EasyLocalization.ensureInitialized();
// }
//
// Future<void> _setPreferredOrientations() async {
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
// }
//
// class ZetaApp extends StatelessWidget {
//   const ZetaApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return EasyLocalization(
//       supportedLocales: const [
//         Locale('en'),
//         Locale('ar'),
//         Locale('hi'),
//         Locale('ml'),
//       ],
//       path: 'assets/translations',
//       fallbackLocale: const Locale('en'),
//       child: ProviderScope(
//         child: ScreenUtilInit(
//           designSize: const Size(393, 851),
//           builder:
//               (context, child) => MaterialApp(
//                 builder:
//                     (context, child) => Directionality(
//                       textDirection: ui.TextDirection.ltr,
//                       child: child!,
//                     ),
//                 locale: context.locale,
//                 supportedLocales: context.supportedLocales,
//                 localizationsDelegates: context.localizationDelegates,
//                 theme: AppTheme.lightTheme,
//                 debugShowCheckedModeBanner: false,
//                 home: NetworkConnectivityWrapper(
//                   child: SplashScreen(),
//                   onNetworkRestored: () {
//                     // Handle network restoration if needed
//                     print('Network connection restored');
//                   },
//                 ),
//               ),
//         ),
//       ),
//     );
//   }
// }
