import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/auth/screens/widgets/activationUrl_textField.dart';

import '../../../core/common/loader.dart';
import '../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../core/network_connection_checker/connectivity_service.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/common_theme.dart';
import '../controller/auth_controller.dart';

class ActivationUrlScreen extends ConsumerStatefulWidget {
  const ActivationUrlScreen({super.key});

  @override
  ConsumerState<ActivationUrlScreen> createState() =>
      _ActivationUrlScreenState();
}

class _ActivationUrlScreenState extends ConsumerState<ActivationUrlScreen> {
  final TextEditingController _activationController = TextEditingController();
  final connectivityService = ConnectivityService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternet();
    });
  }

  Future<void> _checkInternet() async {
    final hasInternet = await connectivityService.hasInternet();
    if (!hasInternet && mounted) {
      _showNoInternetPopup();
    }
  }

  Future<void> _showNoInternetPopup() async {
    showNoInternetPopup(
      context: context,
      onPressed: () async {
        Navigator.of(context).pop();

        final hasInternet = await connectivityService.hasInternet();

        if (!mounted) return;

        if (!hasInternet) {
          _showNoInternetPopup();
        } else {
          // ✅ Navigate or refresh data when connected
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This forces the widget to rebuild when locale changes
    context.locale;
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [_buildLanguageDropdown(context), 12.widthBox],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("welcomeTo".tr(), style: AppTextStyles.largeFont()),

                Text(
                  "ZETA HRMS",
                  style: AppTextStyles.largeFont(color: AppTheme.primaryColor),
                ),
                10.heightBox,

                Flexible(
                  child: Text(
                    "enterActivationLink".tr(),
                    style: AppTextStyles.smallFont(fontSize: 14.sp),
                  ),
                ),
                15.heightBox,

                ActivationUrlTextField(
                  labelText: "activationURL".tr(),
                  controller: _activationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'plsEnterUrl'.tr();
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print('Text changed: $value');
                  },
                ),
                30.heightBox,

                isLoading
                    ? Loader()
                    : CustomElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          showSnackBar(
                            content: 'plsEnterUrl'.tr(),
                            context: context,
                            color: AppTheme.errorColor,
                          );
                          return;
                        }

                        //THIS is for api calling without the https
                        final rawUrl = _activationController.text.trim();
                        final selectedProtocol = ref.read(
                          selectedProtocolProvider,
                        );

                        final cleanedUrl =
                            rawUrl.endsWith('/')
                                ? rawUrl.substring(0, rawUrl.length - 1)
                                : rawUrl;

                        final url =
                            (cleanedUrl.startsWith('http://') ||
                                    cleanedUrl.startsWith('https://'))
                                ? cleanedUrl
                                : '$selectedProtocol://$cleanedUrl';

                        ref
                            .read(authControllerProvider.notifier)
                            .activateUrl(url: url, context: context);
                      },
                      child: Text("activate".tr()),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          margin: EdgeInsets.only(top: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            color: AppTheme.primaryColor.withOpacity(0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 18, color: AppTheme.primaryColor),
              DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 3,
                  value:
                      ref.watch(localeLanguageProvider) ?? const Locale('en'),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      ref
                          .read(localeLanguageProvider.notifier)
                          .setLocale(newLocale);
                      context.setLocale(newLocale);
                    }
                  },

                  items: [
                    customDropdownMenuItem('en', 'English'),
                    customDropdownMenuItem('ar', 'العربية'),
                    customDropdownMenuItem('hi', 'हिन्दी'),
                    customDropdownMenuItem('ml', 'മലയാളം'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DropdownMenuItem<Locale> customDropdownMenuItem(
    String languageCode,
    String label,
  ) {
    return DropdownMenuItem(
      value: Locale(languageCode),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

//
// // har_generator_service.dart
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:zeta_ess/core/theme/app_theme.dart';
// import 'package:zeta_ess/core/utils.dart';
// import 'package:zeta_ess/features/auth/screens/widgets/activationUrl_textField.dart';
//
// import '../../../core/common/loader.dart';
// import '../../../core/common/widgets/customElevatedButton_widget.dart';
// import '../../../core/providers/language_provider.dart';
// import '../../../core/theme/common_theme.dart';
// import '../controller/auth_controller.dart';
//
// class HarGeneratorService {
//   static const String _version = '1.2';
//   static late Dio _dio;
//
//   /// Initialize Dio with interceptors for HAR generation
//   static void _initializeDio() {
//     _dio = Dio();
//     _dio.options.connectTimeout = const Duration(seconds: 30);
//     _dio.options.receiveTimeout = const Duration(seconds: 30);
//     _dio.options.sendTimeout = const Duration(seconds: 30);
//
//     // Add logging interceptor for debugging
//     _dio.interceptors.add(
//       LogInterceptor(
//         requestBody: true,
//         responseBody: true,
//         logPrint: (obj) => debugPrint(obj.toString()),
//       ),
//     );
//   }
//
//   /// Generates HAR file from a URL and returns the file path
//   static Future<String?> generateHarFromUrl({
//     required String url,
//     Map<String, dynamic>? headers,
//     String method = 'GET',
//     Map<String, dynamic>? data,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     try {
//       _initializeDio();
//
//       final startTime = DateTime.now();
//       Response? response;
//       RequestOptions? requestOptions;
//       DioException? dioError;
//
//       try {
//         // Configure request options
//         final options = Options(
//           method: method.toUpperCase(),
//           headers:
//               headers ??
//               {
//                 'User-Agent': 'ZETA HRMS Flutter App',
//                 'Accept': 'application/json',
//                 'Content-Type': 'application/json',
//               },
//         );
//
//         // Make the request
//         response = await _dio.request(
//           url,
//           options: options,
//           data: data,
//           queryParameters: queryParameters,
//         );
//
//         requestOptions = response.requestOptions;
//       } on DioException catch (e) {
//         dioError = e;
//         response = e.response;
//         requestOptions = e.requestOptions;
//         debugPrint('Dio Error: ${e.message}');
//         debugPrint('Error Type: ${e.type}');
//       }
//
//       final endTime = DateTime.now();
//       final duration = endTime.difference(startTime).inMilliseconds;
//
//       if (requestOptions == null) {
//         debugPrint('Failed to get request options');
//         return null;
//       }
//
//       // Generate HAR content
//       final harContent = _generateHarContent(
//         requestOptions: requestOptions,
//         response: response,
//         dioError: dioError,
//         startTime: startTime,
//         duration: duration,
//       );
//
//       // Save HAR file
//       final filePath = await _saveHarFile(harContent);
//       debugPrint('HAR file saved at: $filePath');
//       return filePath;
//     } catch (e) {
//       debugPrint('Error generating HAR: $e');
//       return null;
//     }
//   }
//
//   /// Generates HAR content structure
//   static Map<String, dynamic> _generateHarContent({
//     required RequestOptions requestOptions,
//     Response? response,
//     DioException? dioError,
//     required DateTime startTime,
//     required int duration,
//   }) {
//     final uri = requestOptions.uri;
//
//     // Build request headers
//     final requestHeaders = <String, String>{};
//     requestOptions.headers.forEach((key, value) {
//       requestHeaders[key] = value.toString();
//     });
//
//     // Build response data
//     int statusCode = 0;
//     String statusText = 'Unknown';
//     Map<String, String> responseHeaders = {};
//     String responseBody = '';
//     int responseSize = 0;
//     String mimeType = 'text/plain';
//
//     if (response != null) {
//       statusCode = response.statusCode ?? 0;
//       statusText = response.statusMessage ?? _getStatusText(statusCode);
//
//       // Response headers
//       response.headers.forEach((key, values) {
//         responseHeaders[key] = values.join(', ');
//       });
//
//       // Response body
//       if (response.data != null) {
//         if (response.data is String) {
//           responseBody = response.data;
//         } else {
//           responseBody = jsonEncode(response.data);
//         }
//         responseSize = responseBody.length;
//       }
//
//       // MIME type
//       mimeType = responseHeaders['content-type'] ?? 'application/json';
//     } else if (dioError != null) {
//       // Handle error cases
//       statusCode = dioError.response?.statusCode ?? 0;
//       statusText = dioError.message ?? 'Network Error';
//       responseBody = jsonEncode({
//         'error': dioError.message,
//         'type': dioError.type.toString(),
//       });
//       responseSize = responseBody.length;
//     }
//
//     // Build request body
//     String requestBody = '';
//     int requestBodySize = 0;
//     String requestMimeType = 'application/json';
//
//     if (requestOptions.data != null) {
//       if (requestOptions.data is String) {
//         requestBody = requestOptions.data;
//       } else if (requestOptions.data is Map || requestOptions.data is List) {
//         requestBody = jsonEncode(requestOptions.data);
//       } else {
//         requestBody = requestOptions.data.toString();
//       }
//       requestBodySize = requestBody.length;
//     }
//
//     return {
//       "log": {
//         "version": _version,
//         "creator": {"name": "Flutter HAR Generator (Dio)", "version": "1.0.0"},
//         "entries": [
//           {
//             "startedDateTime": startTime.toIso8601String(),
//             "time": duration,
//             "request": {
//               "method": requestOptions.method,
//               "url": uri.toString(),
//               "httpVersion": "HTTP/1.1",
//               "headers": _formatHeaders(requestHeaders),
//               "queryString": _formatQueryString(uri.queryParameters),
//               "postData":
//                   requestBodySize > 0
//                       ? {
//                         "mimeType": requestMimeType,
//                         "text": requestBody,
//                         "params": [],
//                       }
//                       : null,
//               "headersSize": -1,
//               "bodySize": requestBodySize,
//             },
//             "response": {
//               "status": statusCode,
//               "statusText": statusText,
//               "httpVersion": "HTTP/1.1",
//               "headers": _formatHeaders(responseHeaders),
//               "content": {
//                 "size": responseSize,
//                 "mimeType": mimeType,
//                 "text": responseBody,
//                 "encoding": "utf8",
//               },
//               "redirectURL": "",
//               "headersSize": -1,
//               "bodySize": responseSize,
//             },
//             "cache": {},
//             "timings": {
//               "send": 0,
//               "wait": duration,
//               "receive": 0,
//               "ssl": -1,
//               "connect": -1,
//               "dns": -1,
//               "blocked": 0,
//             },
//             "serverIPAddress": "",
//             "connection": "",
//             "_error":
//                 dioError != null
//                     ? {
//                       "message": dioError.message,
//                       "type": dioError.type.toString(),
//                     }
//                     : null,
//           },
//         ],
//       },
//     };
//   }
//
//   /// Formats headers for HAR format
//   static List<Map<String, String>> _formatHeaders(Map<String, String> headers) {
//     return headers.entries
//         .map((entry) => {"name": entry.key, "value": entry.value})
//         .toList();
//   }
//
//   /// Formats query string parameters for HAR format
//   static List<Map<String, String>> _formatQueryString(
//     Map<String, String> queryParams,
//   ) {
//     return queryParams.entries
//         .map((entry) => {"name": entry.key, "value": entry.value})
//         .toList();
//   }
//
//   /// Get HTTP status text
//   static String _getStatusText(int statusCode) {
//     switch (statusCode) {
//       case 200:
//         return 'OK';
//       case 201:
//         return 'Created';
//       case 204:
//         return 'No Content';
//       case 400:
//         return 'Bad Request';
//       case 401:
//         return 'Unauthorized';
//       case 403:
//         return 'Forbidden';
//       case 404:
//         return 'Not Found';
//       case 405:
//         return 'Method Not Allowed';
//       case 408:
//         return 'Request Timeout';
//       case 429:
//         return 'Too Many Requests';
//       case 500:
//         return 'Internal Server Error';
//       case 502:
//         return 'Bad Gateway';
//       case 503:
//         return 'Service Unavailable';
//       case 504:
//         return 'Gateway Timeout';
//       default:
//         return 'Unknown Status';
//     }
//   }
//
//   /// Saves HAR content to file
//   static Future<String> _saveHarFile(Map<String, dynamic> harContent) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = 'har_export_$timestamp.har';
//       final file = File('${directory.path}/$fileName');
//
//       final jsonString = const JsonEncoder.withIndent('  ').convert(harContent);
//       await file.writeAsString(jsonString, encoding: utf8);
//
//       debugPrint('HAR file created: ${file.path}');
//       debugPrint('File size: ${await file.length()} bytes');
//
//       return file.path;
//     } catch (e) {
//       debugPrint('Error saving HAR file: $e');
//       rethrow;
//     }
//   }
//
//   /// Shares the HAR file
//   static Future<void> shareHarFile(String filePath) async {
//     try {
//       final file = File(filePath);
//       if (await file.exists()) {
//         debugPrint('Sharing HAR file: $filePath');
//
//         final result = await Share.shareXFiles(
//           [XFile(filePath)],
//           subject: 'HAR Export File - Network Analysis',
//           text:
//               'Generated HAR file for network debugging and analysis.\n\nTimestamp: ${DateTime.now().toIso8601String()}',
//         );
//
//         debugPrint('Share result: ${result.status}');
//       } else {
//         debugPrint('HAR file does not exist: $filePath');
//         throw Exception('HAR file not found');
//       }
//     } catch (e) {
//       debugPrint('Error sharing HAR file: $e');
//       rethrow;
//     }
//   }
//
//   /// Generates HAR file and shares it in one step
//   static Future<bool> generateAndShareHar({
//     required String url,
//     Map<String, dynamic>? headers,
//     String method = 'GET',
//     Map<String, dynamic>? data,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     try {
//       debugPrint('Starting HAR generation for URL: $url');
//
//       final filePath = await generateHarFromUrl(
//         url: url,
//         headers: headers,
//         method: method,
//         data: data,
//         queryParameters: queryParameters,
//       );
//
//       if (filePath != null && filePath.isNotEmpty) {
//         debugPrint('HAR generated successfully, sharing...');
//         await shareHarFile(filePath);
//         return true;
//       } else {
//         debugPrint('HAR generation returned null/empty path');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Error in generateAndShareHar: $e');
//       return false;
//     }
//   }
//
//   /// Test connection to URL (useful for validation)
//   static Future<bool> testConnection(String url) async {
//     try {
//       _initializeDio();
//       final response = await _dio.head(url);
//       return response.statusCode != null && response.statusCode! < 400;
//     } catch (e) {
//       debugPrint('Connection test failed: $e');
//       return false;
//     }
//   }
// }
//
// class ActivationUrlScreen extends ConsumerWidget {
//   final TextEditingController _activationController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   ActivationUrlScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // This forces the widget to rebuild when locale changes
//     context.locale;
//     final isLoading = ref.watch(authControllerProvider);
//     return Scaffold(
//       // appBar: AppBar(
//       //   backgroundColor: Colors.transparent,
//       //   elevation: 0,
//       //   actions: [_buildLanguageDropdown(context), 12.widthBox],
//       // ),
//       body: SafeArea(
//         child: Padding(
//           padding: AppPadding.screenPadding,
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("welcomeTo".tr(), style: AppTextStyles.largeFont()),
//
//                 Text(
//                   "ZETA HRMS",
//                   style: AppTextStyles.largeFont(color: AppTheme.primaryColor),
//                 ),
//                 10.heightBox,
//
//                 Flexible(
//                   child: Text(
//                     "enterActivationLink".tr(),
//                     style: AppTextStyles.smallFont(fontSize: 14.sp),
//                   ),
//                 ),
//                 15.heightBox,
//
//                 ActivationUrlTextField(
//                   labelText: "activationURL".tr(),
//                   controller: _activationController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'plsEnterUrl'.tr();
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     print('Text changed: $value');
//                   },
//                 ),
//                 30.heightBox,
//
//                 isLoading
//                     ? Loader()
//                     : Column(
//                       children: [
//                         // Main Activate Button
//                         CustomElevatedButton(
//                           onPressed: () => _handleActivation(context, ref),
//                           child: Text("activate".tr()),
//                         ),
//
//                         10.heightBox,
//
//                         // HAR Generation Button
//                         CustomElevatedButton(
//                           onPressed: () => _generateAndShareHar(context, ref),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.share, size: 16),
//                               8.widthBox,
//                               Text("Generate & Share HAR"),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Handle the main activation process
//   void _handleActivation(BuildContext context, WidgetRef ref) {
//     if (!_formKey.currentState!.validate()) {
//       showSnackBar(
//         content: 'plsEnterUrl'.tr(),
//         context: context,
//         color: AppTheme.errorColor,
//       );
//       return;
//     }
//
//     final url = _buildCleanUrl(ref);
//
//     // Generate HAR file automatically when activating
//     _generateHarInBackground(url);
//
//     // Continue with normal activation
//     ref
//         .read(authControllerProvider.notifier)
//         .activateUrl(url: url, context: context);
//   }
//
//   /// Generate and share HAR file
//   Future<void> _generateAndShareHar(BuildContext context, WidgetRef ref) async {
//     if (!_formKey.currentState!.validate()) {
//       showSnackBar(
//         content: 'plsEnterUrl'.tr(),
//         context: context,
//         color: AppTheme.errorColor,
//       );
//       return;
//     }
//
//     final url = _buildCleanUrl(ref);
//
//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => const AlertDialog(
//             content: Row(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(width: 20),
//                 Text('Generating HAR file...'),
//               ],
//             ),
//           ),
//     );
//
//     try {
//       // Test connection first
//       final canConnect = await HarGeneratorService.testConnection(url);
//
//       if (!canConnect) {
//         Navigator.of(context).pop(); // Close loading dialog
//         showSnackBar(
//           content: 'Cannot connect to URL. Please check the URL and try again.',
//           context: context,
//           color: AppTheme.errorColor,
//         );
//         return;
//       }
//
//       final success = await HarGeneratorService.generateAndShareHar(
//         url: url,
//         method: 'GET',
//         headers: {
//           'User-Agent': 'ZETA HRMS Flutter App',
//           'Accept': 'application/json, text/plain, */*',
//           'Content-Type': 'application/json',
//           'Cache-Control': 'no-cache',
//         },
//       );
//
//       Navigator.of(context).pop(); // Close loading dialog
//
//       if (success) {
//         showSnackBar(
//           content: 'HAR file generated and shared successfully!',
//           context: context,
//           color: Colors.green,
//         );
//       } else {
//         showSnackBar(
//           content: 'Failed to generate HAR file. Check logs for details.',
//           context: context,
//           color: AppTheme.errorColor,
//         );
//       }
//     } catch (e) {
//       Navigator.of(context).pop(); // Close loading dialog
//       print('HAR Generation Error: $e');
//       showSnackBar(
//         content: 'Error: ${e.toString()}',
//         context: context,
//         color: AppTheme.errorColor,
//       );
//     }
//   }
//
//   /// Generate HAR file in background (without sharing)
//   Future<void> _generateHarInBackground(String url) async {
//     try {
//       final filePath = await HarGeneratorService.generateHarFromUrl(
//         url: url,
//         method: 'GET',
//         headers: {
//           'User-Agent': 'ZETA HRMS Flutter App',
//           'Accept': 'application/json, text/plain, */*',
//           'Content-Type': 'application/json',
//           'Cache-Control': 'no-cache',
//         },
//       );
//
//       if (filePath != null) {
//         print('HAR file generated in background: $filePath');
//       } else {
//         print('Background HAR generation failed: No file path returned');
//       }
//     } catch (e) {
//       print('Background HAR generation error: $e');
//     }
//   }
//
//   /// Build clean URL from input
//   String _buildCleanUrl(WidgetRef ref) {
//     final rawUrl = _activationController.text.trim();
//     final selectedProtocol = ref.read(selectedProtocolProvider);
//
//     final cleanedUrl =
//         rawUrl.endsWith('/') ? rawUrl.substring(0, rawUrl.length - 1) : rawUrl;
//
//     return (cleanedUrl.startsWith('http://') ||
//             cleanedUrl.startsWith('https://'))
//         ? cleanedUrl
//         : '$selectedProtocol://$cleanedUrl';
//   }
//
//   Widget _buildLanguageDropdown(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           margin: EdgeInsets.only(top: 12.h),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: AppTheme.primaryColor.withOpacity(0.2),
//               width: 1,
//             ),
//             color: AppTheme.primaryColor.withOpacity(0.05),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.language, size: 18, color: AppTheme.primaryColor),
//               DropdownButtonHideUnderline(
//                 child: DropdownButton<Locale>(
//                   icon: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: AppTheme.primaryColor,
//                     size: 20,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   elevation: 3,
//                   value:
//                       ref.watch(localeLanguageProvider) ?? const Locale('en'),
//                   onChanged: (Locale? newLocale) {
//                     if (newLocale != null) {
//                       ref
//                           .read(localeLanguageProvider.notifier)
//                           .setLocale(newLocale);
//                       context.setLocale(newLocale);
//                     }
//                   },
//
//                   items: [
//                     customDropdownMenuItem('en', 'English'),
//                     customDropdownMenuItem('ar', 'العربية'),
//                     customDropdownMenuItem('hi', 'हिन्दी'),
//                     customDropdownMenuItem('ml', 'മലയാളം'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   DropdownMenuItem<Locale> customDropdownMenuItem(
//     String languageCode,
//     String label,
//   ) {
//     return DropdownMenuItem(
//       value: Locale(languageCode),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
//         child: Text(
//           label,
//           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//         ),
//       ),
//     );
//   }
// }
