// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:intl/intl.dart';
// import 'package:zeta_ess/core/api_constants/self_service_apis/leave_managment_apis.dart';
//
// import '../../../../core/common/no_server_screen.dart';
// import '../../../../core/providers/userContext_provider.dart';
// import '../controller/old_hrms_configuration_stuffs.dart';
//
// //TODO seprate to repository !
//
// class LeaveEntryEdit extends StatefulWidget {
//   String? lssNo;
//   final String? restorationId;
//
//   LeaveEntryEdit({Key? key, this.lssNo, this.restorationId}) : super(key: key);
//
//   @override
//   State<LeaveEntryEdit> createState() => _LeaveEntryEditState();
// }
//
// class Allowance {
//   String? name;
//   String? value;
//
//   Allowance({this.name, this.value});
// }
//
// class _LeaveEntryEditState extends State<LeaveEntryEdit> with RestorationMixin {
//   List allowanceypes = [
//     Allowance(name: "Not Applicable", value: "N"),
//     Allowance(name: "Ticket", value: "T"),
//     Allowance(name: "Travel Allowance", value: "A"),
//   ];
//
//   List<LeaveTypes> leaveTypes = [];
//   List totalNumberLeaves = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
//
//   String? selectedValue;
//   String? attachmentUrl;
//   String selectedLeaves = "0";
//   String allowanceType = "N";
//   bool shadowColor = false;
//   final myControllerFrom = TextEditingController();
//   final myControllerTo = TextEditingController();
//   final submittedDateController = TextEditingController();
//   final reasonController = TextEditingController();
//   final contactController = TextEditingController();
//   String onTap = 'from';
//   final _formKey = GlobalKey<FormState>();
//   final LeaveConfigurationController leaveController = Get.put(
//     LeaveConfigurationController(),
//   );
//   String? multipartFile;
//   List<LeaveConfigurationEditData> leaveConfigData = [];
//   List<LeaveConfigurationEditData> leaveConfigDataSub = [];
//   List<LeaveConfigurationEditData> leaveConfigDataCan = [];
//
//   DateTime? startDate;
//   DateTime? endDate;
//   String? fileExtension;
//   bool uploadClicked = false;
//   LeaveTypes? selectedLeaveType;
//   LeaveTypes? initialLeaveType;
//
//   @override
//   void initState() {
//     _getLeaveTypes();
//     super.initState();
//   }
//
//   _getLeaveTypes() async {
//     //.show();
//
//     var now = DateTime.now();
//     var formatter = DateFormat('dd/MM/yyyy');
//     String formattedDate = formatter.format(now);
//
//     submittedDateController.text = formattedDate.toString();
//
//     List<LeaveTypes>? d1 = await getEmployeLeaveTypes();
//     if (d1 == null) {
//       // ignore: use_build_context_synchronously
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const NoServer()),
//       );
//     }
//     List<LeaveTypes> d = d1 ?? [];
//
//     setState(() {
//       leaveTypes = d;
//     });
//     var leaveDetails = await getLeaveDetails(widget.lssNo.toString()).timeout(
//       const Duration(seconds: 60),
//       onTimeout: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const NoServer()),
//         );
//       },
//     );
//
//     if (leaveDetails.length > 0) {
//       DateTime start = DateFormat(
//         "dd/MM/yyyy",
//       ).parse(leaveDetails['d'][0]['SubLst'][0]['DLsrdtf'].toString());
//
//       DateTime end = DateFormat(
//         "dd/MM/yyyy",
//       ).parse(leaveDetails['d'][0]['SubLst'][0]['DLsrdtt'].toString());
//
//       submittedDateController.text =
//           leaveDetails['d'][0]['SubLst'][0]['DLsdate'].toString();
//
//       myControllerFrom.text =
//           "${int.parse(DateFormat.d().format(start)) > 9 ? DateFormat.d().format(start) : '0${DateFormat.d().format(start)}'}/${int.parse(DateFormat.M().format(start)) > 9 ? DateFormat.M().format(start) : '0${DateFormat.M().format(start)}'}/${DateFormat.y().format(start)}";
//
//       myControllerTo.text =
//           "${int.parse(DateFormat.d().format(end)) > 9 ? DateFormat.d().format(end) : '0${DateFormat.d().format(end)}'}/${int.parse(DateFormat.M().format(end)) > 9 ? DateFormat.M().format(end) : '0${DateFormat.M().format(end)}'}/${DateFormat.y().format(end)}";
//
//       reasonController.text =
//           leaveDetails['d'][0]['SubLst'][0]['Lsnote'].toString();
//
//       contactController.text =
//           leaveDetails['d'][0]['SubLst'][0]['Lscont'].toString();
//       attachmentUrl =
//           (leaveDetails['d'][0]['SubLst'][0]['LeaveName'] ?? "").toString();
//
//       if (leaveDetails['d'][0]['SubLst'][0]['LsRtAl'] != "null") {
//         setState(() {
//           allowanceType =
//               leaveDetails['d'][0]['SubLst'][0]['LsRtAl'].toString();
//         });
//       }
//
//       setState(() {
//         selectedValue = leaveDetails['d'][0]['SubLst'][0]['LtCode'].toString();
//         selectedLeaves =
//             leaveDetails['d'][0]['SubLst'][0]['LLsrndy'].toString();
//         startDate = start;
//         endDate = end;
//       });
//       initialLeaveType = leaveTypes.firstWhere(
//         (element) =>
//             element.typeId ==
//             leaveDetails['d'][0]['SubLst'][0]['LtCode'].toString(),
//       );
//       initialLeaveType?.ltlieu == 'Y' ? isLieuDay = true : isLieuDay = false;
//
//       List<LeaveConfigurationEditData> data = [];
//       List<LeaveConfigurationEditData> dataSub = [];
//       List<LeaveConfigurationEditData> dataCan = [];
//       for (var i in leaveDetails["d"]) {
//         for (var item in i["AppLst"]) {
//           data.add(LeaveConfigurationEditData.fromJson(item));
//         }
//         for (var item in i["SubLst"]) {
//           dataSub.add(LeaveConfigurationEditData.fromJson(item));
//         }
//         for (var item in i["CanLst"]) {
//           dataCan.add(LeaveConfigurationEditData.fromJson(item));
//         }
//       }
//
//       try {
//         dataCan.forEach((element) {
//           var item =
//               data
//                   .where((i) => i.luslno.toString() == element.iLsslno)
//                   .toList();
//           if (item.isNotEmpty) {
//             var cnt = 0.00;
//             if (item.first.dayFlag == "F") {
//               cnt = 1.00;
//             } else if (item.first.dayFlag == "H") {
//               cnt = 0.50;
//             }
//             var item1 = element.dLsdate ?? '';
//             if (item != '') {
//               var arr = item1.split('(');
//               var arr1 = arr[1].split(')');
//               var val = arr1[0];
//               double val1 = double.parse(val);
//               String str = (val1 + cnt).toStringAsFixed(2);
//               element.dLsdate = arr[0] + "(" + str + ")";
//             }
//           }
//         });
//       } catch (e) {}
//
//       setState(() {
//         leaveConfigData = data;
//         leaveConfigDataSub = dataSub;
//         leaveConfigDataCan = dataCan;
//         leaveController.setDataEdit(data);
//         leaveConfigData.isNotEmpty ? print("no tmtmttm") : print("emmm");
//       });
//     }
//     //.hide();
//   }
//
//   @override
//   String? get restorationId => widget.restorationId;
//
//   final RestorableDateTime selectedDate = RestorableDateTime(
//     DateTime(
//       DateTime.now().year.toInt(),
//       DateTime.now().month.toInt(),
//       DateTime.now().day.toInt(),
//     ),
//   );
//
//   late final RestorableRouteFuture<DateTime?> restorableDatePickerRouteFuture =
//       RestorableRouteFuture<DateTime?>(
//         onComplete: _selectDate,
//         onPresent: (NavigatorState navigator, Object? arguments) {
//           return navigator.restorablePush(
//             _datePickerRoute,
//             arguments: selectedDate.value.millisecondsSinceEpoch,
//           );
//         },
//       );
//
//   Future<DateTime> selectDate(BuildContext context, DateTime date) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: date,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2030),
//       initialEntryMode: DatePickerEntryMode.calendarOnly,
//     );
//
//     if (picked != null) {
//       date = picked;
//     }
//     return date;
//   }
//
//   static Route<DateTime> _datePickerRoute(
//     BuildContext context,
//     Object? arguments,
//   ) {
//     return DialogRoute<DateTime>(
//       context: context,
//       builder: (BuildContext context) {
//         return DatePickerDialog(
//           restorationId: 'date_picker_dialog',
//           initialEntryMode: DatePickerEntryMode.calendarOnly,
//           initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
//           firstDate: DateTime(DateTime.now().year - 1, 11),
//           lastDate: DateTime(
//             DateTime.now().year.toInt() + 2,
//             DateTime.now().month.toInt(),
//             DateTime.now().day.toInt(),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(selectedDate, 'selected_date');
//     registerForRestoration(
//       restorableDatePickerRouteFuture,
//       'date_picker_route_future',
//     );
//   }
//
//   void _selectDate(DateTime? newSelectedDate) {
//     if (newSelectedDate != null) {
//       if (onTap == 'from') {
//         myControllerFrom.text =
//             '${newSelectedDate.day}/${newSelectedDate.month}/${newSelectedDate.year}';
//       } else {
//         myControllerTo.text =
//             '${newSelectedDate.day}/${newSelectedDate.month}/${newSelectedDate.year}';
//       }
//
//       _findLeaveDays();
//       List<LeaveConfigurationEditData> tmpConfigData = [];
//
//       try {
//         leaveController.setDataEdit(tmpConfigData);
//       } catch (e) {}
//
//       setState(() {
//         selectedDate.value = newSelectedDate;
//         leaveConfigData = [];
//         //myControllerFrom.text = _selectedDate.value.toString();
//         /*ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
//             ),
//           );*/
//       });
//     }
//   }
//
//   bool validateEmoji(String text) {
//     final regex = RegExp(
//       r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
//       unicode: true,
//     );
//
//     if (regex.hasMatch(text)) {
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   _findLeaveDays() async {
//     if (selectedValue != null) {
//       if (myControllerFrom.text.isNotEmpty && myControllerTo.text.isNotEmpty) {
//         String leaveTypeValue = "";
//
//         for (var i in leaveTypes) {
//           if (selectedValue == i.type) {
//             leaveTypeValue = i.typeId.toString();
//           }
//         }
//         double l = await getLeaveDays(
//           myControllerFrom.text.toString(),
//           myControllerTo.text.toString(),
//           selectedValue.toString(),
//         ).timeout(
//           const Duration(seconds: 60),
//           onTimeout: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const NoServer()),
//             );
//           },
//         );
//
//         setState(() {
//           selectedLeaves = l.toString();
//         });
//       }
//     }
//   }
//
//   Future<void> _launchUrl(context, String filePath) async {
//     if (filePath != "") {
//       var a = filePath.split("\\");
//       var b = a.last;
//
//       String attachmentUrl = configController.baseUrl + "/" + filePath;
//
//       var status = await getAttachmentStatus(attachmentUrl);
//       if (status == "200") {
//         final Uri url = Uri.parse(attachmentUrl);
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         showCupertinoModalPopup<void>(
//           context: context,
//           builder:
//               (BuildContext context) => CupertinoAlertDialog(
//                 title: const Text(""),
//                 content: Text(
//                   "Upload File Missing.",
//                   style: BaseStyle.textDialogBody,
//                 ),
//                 actions: <CupertinoDialogAction>[
//                   CupertinoDialogAction(
//                     isDestructiveAction: true,
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text(AppLocalizations.of(context)!.ok),
//                   ),
//                 ],
//               ),
//         );
//       }
//
//       // if (!await launchUrl(_url,LaunchMode.externalApplication)) {
//       //   throw Exception('Could not launch $_url');
//       // }
//     }
//   }
//
//   Future<String> getAttachmentStatus(String url) async {
//     try {
//       var response = await dio.get(url);
//
//       return response.statusCode.toString();
//     } catch (e) {
//       return "404";
//     }
//   }
//
//   void viewAttachment(context, String filePath) {
//     if (filePath != "") {
//       String attachmentUrl = configController.baseUrl + "/" + filePath;
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => WebViewAttachment(attachmentUrl: attachmentUrl),
//         ),
//       );
//     }
//   }
//
//   bool isLieuDay = false;
//
//   void _save(_context) async {
//     //.show();
//     String jsonData = json.encode(leaveController.leaveConfigurationEditData);
//     var response = await saveLeaveApi(
//       jsonData,
//       submittedDateController.text.toString(),
//       selectedValue.toString(),
//       myControllerFrom.text.toString(),
//       myControllerTo.text.toString(),
//       reasonController.text.toString(),
//       contactController.text.toString(),
//       selectedLeaves.toString(),
//       multipartFile,
//       widget.lssNo.toString(),
//       fileExtension,
//       allowanceType,
//     );
//
//     //.hide();
//     if (response == null) {
//       // ignore: use_build_context_synchronously
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const NoServer()),
//       );
//       return;
//     }
//
//     submittedDateController.text = "";
//     myControllerFrom.text = "";
//     myControllerTo.text = "";
//     reasonController.text = "";
//     contactController.text = "";
//
//     showCupertinoModalPopup<void>(
//       context: _context,
//       barrierDismissible: false,
//       builder:
//           (BuildContext context) => CupertinoAlertDialog(
//             title: const Text(''),
//             content: Text(
//               MyApp.translate(response.toString()),
//               style: BaseStyle.textDialogBody,
//             ),
//             actions: <CupertinoDialogAction>[
//               CupertinoDialogAction(
//                 /// This parameter indicates the action would perform
//                 /// a destructive action such as deletion, and turns
//                 /// the action's text color to red.
//                 isDestructiveAction: true,
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//                 child: Text(AppLocalizations.of(context)!.ok),
//               ),
//             ],
//           ),
//     );
//   }
//
//   String imageToBase64(File file, {int? height}) {
//     final image = decodeImage(file.readAsBytesSync())!;
//     // final resizedImage = copyResize(image, height: height ?? 800);
//     return base64Encode(encodeJpg(image, quality: 100));
//   }
//
//   void _updateSelectedLeave() {
//     setState(() {
//       // selectedLeaves = double.parse(leaveController.totalLeaves.toString());
//       try {
//         if (leaveController.leaveConfigurationEditData.isNotEmpty) {
//           var lst = leaveController.leaveConfigurationEditData.where(
//             (e) => e.dayFlag != "",
//           );
//           if (lst.isNotEmpty) {
//             myControllerFrom.text = lst.first.dLsdate ?? '';
//
//             myControllerTo.text = lst.last.dLsdate ?? '';
//           }
//         }
//       } catch (e) {}
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     final double itemHeight = (size.height - kToolbarHeight - 30);
//
//     return Scaffold(
//       backgroundColor: HexColor("#D5F2FA"),
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 0.0,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: HexColor("#000000"),
//         ),
//         backgroundColor: HexColor("#D5F2FA"),
//         title: Text(
//           AppLocalizations.of(context)!.leaveEntryEdit,
//           style: GoogleFonts.roboto(
//             fontSize: 17.sp,
//             color: HexColor("#09A5D9"),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context, true);
//           },
//           icon: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: HexColor('#0E6D9B'),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () {
//             // Unfocus the text field when a tap is detected outside
//             FocusScope.of(context).unfocus();
//           },
//           child: Padding(
//             padding: EdgeInsets.only(top: 8.0.h),
//             child: Material(
//               color: HexColor('#ffffff'),
//               borderRadius: const BorderRadius.only(
//                 topRight: Radius.circular(20),
//                 topLeft: Radius.circular(20),
//               ),
//               shadowColor: HexColor("#F1F1F1").withOpacity(.9),
//               elevation: 15.0,
//               child: SizedBox(
//                 height: itemHeight,
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(20.0.w),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Text(
//                             AppLocalizations.of(context)!.submittedDate,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextFormField(
//                             readOnly: true,
//                             controller: submittedDateController,
//                             keyboardType: TextInputType.text,
//                             style: GoogleFonts.roboto(
//                               fontSize: 14.0.sp,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: "Submitted Date*",
//                               hintStyle: GoogleFonts.poppins(
//                                 color: HexColor("#D6D6D6"),
//                                 fontSize: 14.sp,
//                               ),
//                               border: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return AppLocalizations.of(
//                                   context,
//                                 )!.pleaseEnterSubmittedDate;
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: 20.h),
//                           Row(
//                             children: [
//                               Flexible(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           AppLocalizations.of(context)!.from,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const Text(
//                                           " *",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.red,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     TextFormField(
//                                       controller: myControllerFrom,
//                                       onTap: () async {
//                                         setState(() {
//                                           onTap = 'from';
//                                         });
//
//                                         //restorableDatePickerRouteFuture.present();
//                                         DateTime d = await selectDate(
//                                           context,
//                                           startDate!,
//                                         );
//                                         try {
//                                           setState(() {
//                                             startDate = d;
//                                           });
//                                           String formattedDate =
//                                               "${int.parse(DateFormat.d().format(d)) > 9 ? DateFormat.d().format(d) : '0${DateFormat.d().format(d)}'}/${int.parse(DateFormat.M().format(d)) > 9 ? DateFormat.M().format(d) : '0${DateFormat.M().format(d)}'}/${DateFormat.y().format(d)}";
//
//                                           myControllerFrom.text =
//                                               formattedDate.toString();
//
//                                           setState(() {
//                                             leaveConfigData = [];
//                                           });
//                                           List<LeaveConfigurationEditData>
//                                           tmpConfigData = [];
//
//                                           try {
//                                             leaveController.setDataEdit(
//                                               tmpConfigData,
//                                             );
//                                           } catch (e) {}
//                                         } catch (e) {}
//                                       },
//                                       readOnly: true,
//                                       keyboardType: TextInputType.text,
//                                       style: GoogleFonts.roboto(
//                                         fontSize: 14.0.sp,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       decoration: InputDecoration(
//                                         suffixIcon: Align(
//                                           widthFactor: 1.0,
//                                           heightFactor: 1.0,
//                                           child: Icon(
//                                             Icons.calendar_month,
//                                             color: HexColor('#69A4C1'),
//                                           ),
//                                         ),
//                                         hintText: "From",
//                                         hintStyle: GoogleFonts.poppins(
//                                           color: HexColor("#D6D6D6"),
//                                           fontSize: 14.sp,
//                                         ),
//                                         border: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                         focusedBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                         enabledBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                         errorBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                       ),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return AppLocalizations.of(
//                                             context,
//                                           )!.pleaseSelectFromDate;
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(width: 20.w),
//                               Flexible(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           AppLocalizations.of(context)!.to,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const Text(
//                                           " *",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.red,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     TextFormField(
//                                       onTap: () async {
//                                         setState(() {
//                                           onTap = 'to';
//                                         });
//                                         //restorableDatePickerRouteFuture.present();
//                                         DateTime d = await selectDate(
//                                           context,
//                                           endDate!,
//                                         );
//                                         try {
//                                           setState(() {
//                                             endDate = d;
//                                           });
//                                           String formattedDate =
//                                               "${int.parse(DateFormat.d().format(d)) > 9 ? DateFormat.d().format(d) : '0${DateFormat.d().format(d)}'}/${int.parse(DateFormat.M().format(d)) > 9 ? DateFormat.M().format(d) : '0${DateFormat.M().format(d)}'}/${DateFormat.y().format(d)}";
//
//                                           myControllerTo.text =
//                                               formattedDate.toString();
//                                           setState(() {
//                                             leaveConfigData = [];
//                                           });
//                                           List<LeaveConfigurationEditData>
//                                           tmpConfigData = [];
//
//                                           try {
//                                             leaveController.setDataEdit(
//                                               tmpConfigData,
//                                             );
//                                           } catch (e) {
//                                             print(e);
//                                           }
//                                         } catch (e) {}
//                                       },
//                                       controller: myControllerTo,
//                                       keyboardType: TextInputType.text,
//                                       readOnly: true,
//                                       style: GoogleFonts.roboto(
//                                         fontSize: 14.0.sp,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       decoration: InputDecoration(
//                                         suffixIcon: Align(
//                                           widthFactor: 1.0,
//                                           heightFactor: 1.0,
//                                           child: Icon(
//                                             Icons.calendar_month,
//                                             color: HexColor('#69A4C1'),
//                                           ),
//                                         ),
//                                         hintText: "To",
//                                         hintStyle: GoogleFonts.poppins(
//                                           color: HexColor("#D6D6D6"),
//                                           fontSize: 14.sp,
//                                         ),
//                                         border: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                         focusedBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                         enabledBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                         errorBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: HexColor('#0E6D9B'),
//                                             width: 1.0.w,
//                                           ),
//                                         ),
//                                       ),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return AppLocalizations.of(
//                                             context,
//                                           )!.pleaseSelectToDate;
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Text(
//                                 AppLocalizations.of(context)!.leaveType,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const Text(
//                                 " *",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Flexible(
//                                 child: DropdownButtonFormField(
//                                   validator: (value) {
//                                     if (value == null) {
//                                       return AppLocalizations.of(
//                                         context,
//                                       )!.pleaseSelectLeaveType;
//                                     }
//                                     return null;
//                                   },
//                                   icon: const Icon(Icons.keyboard_arrow_down),
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         width: 1.w,
//                                         color: HexColor('#0887A1'),
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         width: 1.w,
//                                         color: HexColor('#0887A1'),
//                                       ),
//                                     ),
//                                   ),
//                                   hint: Text(
//                                     AppLocalizations.of(context)!.leaveTypes,
//                                     style: GoogleFonts.roboto(
//                                       color: HexColor("#D6D6D6"),
//                                       fontSize: 16.sp,
//                                     ),
//                                   ),
//                                   items:
//                                       leaveTypes
//                                           .map(
//                                             (item) => DropdownMenuItem(
//                                               value: item.typeId,
//                                               child: Text(
//                                                 item.type.toString(),
//                                                 style: GoogleFonts.roboto(
//                                                   color: HexColor("#0B6E96"),
//                                                   fontSize: 18.sp,
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                           .toList(),
//                                   value: selectedValue,
//                                   onChanged: (value) {
//                                     selectedLeaveType = leaveTypes.firstWhere(
//                                       (element) => element.typeId == value,
//                                     );
//
//                                     setState(() {
//                                       List<LeaveConfigurationEditData> d = [];
//                                       leaveController.setDataEdit(d);
//                                       leaveController.setTotalLeaves("0");
//                                       selectedLeaves = "0";
//                                       leaveController.isSubmitted = false;
//
//                                       selectedValue = value.toString();
//
//                                       selectedLeaveType?.ltlieu == 'Y'
//                                           ? isLieuDay = true
//                                           : isLieuDay = false;
//                                     });
//                                     _findLeaveDays();
//                                   },
//                                   //itemHeight: 40.h,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               shape: const StadiumBorder(),
//                               backgroundColor: HexColor("#0E6D9B"),
//                             ),
//                             onPressed: () {
//                               leaveController.isSubmitted = false;
//                               if (selectedValue != null) {
//                                 if (myControllerFrom.text.isNotEmpty &&
//                                     myControllerTo.text.isNotEmpty) {
//                                   String leaveTypeValue = "";
//
//                                   for (var i in leaveTypes) {
//                                     if (selectedValue == i.type) {
//                                       leaveTypeValue = i.typeId.toString();
//                                     }
//                                   }
//                                   DateFormat dateFormat = DateFormat(
//                                     'dd/MM/yyyy',
//                                   );
//
//                                   DateTime from = dateFormat.parseStrict(
//                                     myControllerFrom.text,
//                                   );
//                                   DateTime to = dateFormat.parseStrict(
//                                     myControllerTo.text,
//                                   );
//                                   if (to.isBefore(from)) {
//                                     showCupertinoModalPopup<void>(
//                                       context: context,
//                                       builder:
//                                           (
//                                             BuildContext context,
//                                           ) => CupertinoAlertDialog(
//                                             title: const Text(''),
//                                             content: Text(
//                                               AppLocalizations.of(
//                                                 context,
//                                               )!.invalidDates,
//                                               style: BaseStyle.textDialogBody,
//                                             ),
//                                             actions: <CupertinoDialogAction>[
//                                               CupertinoDialogAction(
//                                                 /// This parameter indicates the action would perform
//                                                 /// a destructive action such as deletion, and turns
//                                                 /// the action's text color to red.
//                                                 isDestructiveAction: true,
//                                                 onPressed: () {
//                                                   Navigator.pop(context);
//                                                 },
//                                                 child: Text(
//                                                   AppLocalizations.of(
//                                                     context,
//                                                   )!.ok,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                     );
//                                   } else {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) {
//                                           return LeaveConfigurationEdit(
//                                             data: leaveConfigData,
//                                             selectedSameValues:
//                                                 selectedLeaveType ==
//                                                 initialLeaveType,
//                                             selectedLeaveType:
//                                                 selectedLeaveType ??
//                                                 initialLeaveType,
//                                             initialLeaveType: initialLeaveType,
//                                             dataSub: leaveConfigDataSub,
//                                             dataCan: leaveConfigDataCan,
//                                             showSubmit: "",
//                                             dateFrom:
//                                                 myControllerFrom.text
//                                                     .toString(),
//                                             dateTo:
//                                                 myControllerTo.text.toString(),
//                                             leaveCode: selectedValue,
//                                             fromAppTab: false,
//                                             lssNo: widget.lssNo.toString(),
//                                             isLieuDay: isLieuDay,
//                                             dCanLst: [],
//                                           );
//                                         },
//                                       ),
//                                     ).then((value) {
//                                       _updateSelectedLeave();
//                                       setState(() {
//                                         selectedLeaves =
//                                             leaveController.totalLeaves
//                                                 .toString();
//                                       });
//                                     });
//                                   }
//                                 }
//                               }
//                             },
//                             child: Text(
//                               AppLocalizations.of(context)!.configure,
//                               style: GoogleFonts.roboto(
//                                 fontSize: 15.sp,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             "${MyApp.translate("Total Number of leave")}: $selectedLeaves",
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.roboto(
//                               color: HexColor("#0E6D9B"),
//                               fontSize: 15.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: Text(
//                               AppLocalizations.of(context)!.reasonForLeave,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           TextFormField(
//                             controller: reasonController,
//                             maxLines: 4,
//                             keyboardType: TextInputType.multiline,
//                             style: GoogleFonts.roboto(
//                               fontSize: 14.0.sp,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               // hintText: "Reason For Leave",
//                               hintStyle: GoogleFonts.poppins(
//                                 color: HexColor("#D6D6D6"),
//                                 fontSize: 14.sp,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10.0.r),
//                                 ),
//                                 borderSide: const BorderSide(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10.0.r),
//                                 ),
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10.0.r),
//                                 ),
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             validator: (value) {
//                               /*if (value == null || value.isEmpty) {
//                                 return 'Please enter reason';
//                               }*/
//                               if (value != null) {
//                                 if (value.isNotEmpty) {
//                                   bool val = validateEmoji(value);
//                                   if (val == true) {
//                                     return AppLocalizations.of(
//                                       context,
//                                     )!.emojisNotSupported;
//                                   }
//                                 }
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: 20.h),
//                           Text(
//                             AppLocalizations.of(context)!.contactDetails,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextFormField(
//                             controller: contactController,
//                             keyboardType: TextInputType.text,
//                             style: GoogleFonts.roboto(
//                               fontSize: 16.0.sp,
//                               color: Colors.black,
//                             ),
//                             decoration: InputDecoration(
//                               // hintText: "Contact Details",
//                               hintStyle: GoogleFonts.poppins(
//                                 color: HexColor("#D6D6D6"),
//                                 fontSize: 14.sp,
//                               ),
//                               border: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HexColor('#0E6D9B'),
//                                   width: 1.0.w,
//                                 ),
//                               ),
//                             ),
//                             validator: (value) {
//                               /*if (value == null || value.isEmpty) {
//                                 return 'Please enter contact details';
//                               }*/
//                               if (value != null) {
//                                 if (value.isNotEmpty) {
//                                   bool val = validateEmoji(value);
//                                   if (val == true) {
//                                     return AppLocalizations.of(
//                                       context,
//                                     )!.emojisNotSupported;
//                                   }
//                                 }
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: 20.h),
//
//                           SizedBox(height: 40.h),
//                           Row(
//                             children: [
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   shape: const StadiumBorder(),
//                                   backgroundColor: HexColor("#0E6D9B"),
//                                 ),
//                                 onPressed: () async {
//                                   FocusScope.of(context).unfocus();
//                                   //.show();
//                                   FilePickerResult? result = await FilePicker
//                                       .platform
//                                       .pickFiles(
//                                         type: FileType.custom,
//                                         allowedExtensions: [
//                                           'jpg',
//                                           'jpeg',
//                                           'pdf',
//                                           'doc',
//                                           'png',
//                                         ],
//                                       );
//
//                                   if (result != null) {
//                                     File file = File(
//                                       result.files.first.path.toString(),
//                                     );
//                                     // var mFile = await MultipartFile.fromFile(
//                                     //     file.path,
//                                     //     filename: basename(file.path));
//
//                                     PlatformFile selectedFile =
//                                         result.files.first;
//                                     String base64 = "";
//
//                                     if (selectedFile.extension == 'jpg' ||
//                                         selectedFile.extension == 'jpeg' ||
//                                         selectedFile.extension == 'png') {
//                                       base64 = imageToBase64(file);
//                                     } else if (selectedFile.extension ==
//                                             'pdf' ||
//                                         selectedFile.extension == 'doc') {
//                                       final bytes = file.readAsBytesSync();
//                                       base64 = base64Encode(bytes);
//                                     }
//
//                                     setState(() {
//                                       multipartFile = base64;
//                                       fileExtension = selectedFile.extension;
//                                       uploadClicked = true;
//                                     });
//                                   } else {}
//                                   //.hide();
//                                 },
//                                 child: Text(
//                                   AppLocalizations.of(context)!.upload,
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 15.sp,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                               Visibility(
//                                 visible:
//                                     (attachmentUrl ?? "") == "" ? false : true,
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     // downloadFile(context, attachmentUrl ?? "");
//                                     // viewAttachment(context, attachmentUrl ?? "");
//                                     _launchUrl(context, attachmentUrl ?? "");
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.fromLTRB(
//                                       10,
//                                       0,
//                                       0,
//                                       0,
//                                     ),
//                                     child: Text(
//                                       AppLocalizations.of(context)!.view,
//                                       style: GoogleFonts.roboto(
//                                         color: HexColor("#0E6D9B"),
//                                         fontSize: 18.sp,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Visibility(
//                                 visible:
//                                     ((attachmentUrl ?? "") != "" ||
//                                             uploadClicked == true)
//                                         ? true
//                                         : false,
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     var result =
//                                         await getLeaveApprovalStatusMobApp(
//                                           int.parse(widget.lssNo.toString()),
//                                         );
//                                     if (result != "") {
//                                       // ignore: use_build_context_synchronously
//                                       showCupertinoModalPopup<void>(
//                                         context: context,
//                                         builder:
//                                             (
//                                               BuildContext context,
//                                             ) => CupertinoAlertDialog(
//                                               title: const Text(''),
//                                               content: Text(
//                                                 result,
//                                                 style: BaseStyle.textDialogBody,
//                                               ),
//                                               actions: <CupertinoDialogAction>[
//                                                 CupertinoDialogAction(
//                                                   isDestructiveAction: true,
//                                                   onPressed: () {
//                                                     Navigator.pop(context);
//                                                   },
//                                                   child: Text(
//                                                     AppLocalizations.of(
//                                                       context,
//                                                     )!.ok,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                       );
//                                     } else {
//                                       setState(() {
//                                         fileExtension = "aa";
//                                         attachmentUrl = "";
//                                         uploadClicked = false;
//                                       });
//                                     }
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.fromLTRB(
//                                       10,
//                                       0,
//                                       0,
//                                       0,
//                                     ),
//                                     child: Text(
//                                       AppLocalizations.of(context)!.remove,
//                                       style: GoogleFonts.roboto(
//                                         color: HexColor("#0E6D9B"),
//                                         fontSize: 18.sp,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             " jpg,jpeg,pdf,doc,png ${AppLocalizations.of(context)!.formats}",
//                             style: GoogleFonts.roboto(fontSize: 12),
//                           ),
//                           SizedBox(height: 40.h),
//                           Center(
//                             child: Visibility(
//                               visible: true,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   shape: const StadiumBorder(),
//                                   backgroundColor: HexColor("#09A5D9"),
//                                   padding: EdgeInsets.only(
//                                     top: 15.h,
//                                     bottom: 15.h,
//                                     left: 40.w,
//                                     right: 40.w,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   if (_formKey.currentState!.validate()) {
//                                     if (leaveController
//                                             .leaveConfigurationEditData
//                                             .isEmpty ||
//                                         leaveController.isSubmitted == false) {
//                                       showCupertinoModalPopup<void>(
//                                         context: context,
//                                         builder:
//                                             (
//                                               BuildContext context,
//                                             ) => CupertinoAlertDialog(
//                                               title: Text(
//                                                 AppLocalizations.of(
//                                                   context,
//                                                 )!.alert,
//                                               ),
//                                               content: Text(
//                                                 AppLocalizations.of(
//                                                   context,
//                                                 )!.pleaseConfigureYourLeaveDays,
//                                                 style: BaseStyle.textDialogBody,
//                                               ),
//                                               actions: <CupertinoDialogAction>[
//                                                 CupertinoDialogAction(
//                                                   /// This parameter indicates the action would perform
//                                                   /// a destructive action such as deletion, and turns
//                                                   /// the action's text color to red.
//                                                   isDestructiveAction: true,
//                                                   onPressed: () {
//                                                     Navigator.pop(context);
//                                                   },
//                                                   child: Text(
//                                                     AppLocalizations.of(
//                                                       context,
//                                                     )!.ok,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                       );
//                                     } else {
//                                       if (leaveController
//                                           .leaveConfigurationEditData
//                                           .isEmpty) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(
//                                             backgroundColor: Colors.red,
//                                             content: Text(
//                                               AppLocalizations.of(
//                                                 context,
//                                               )!.pleaseConfigureLeaveData,
//                                             ),
//                                           ),
//                                         );
//                                         return;
//                                       }
//
//                                       _save(context);
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             AppLocalizations.of(
//                                               context,
//                                             )!.processingData,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 },
//                                 child: Text(
//                                   AppLocalizations.of(context)!.submit,
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 15.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//      );
//   }
// }
