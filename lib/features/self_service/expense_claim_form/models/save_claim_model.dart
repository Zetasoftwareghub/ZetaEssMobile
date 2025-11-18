// import 'expense_detail_model.dart';
//
// class SaveExpenseClaimModel {
//   final String suconn;
//   final int exmtid; // Always 0
//   final int hfEmcode;
//   final String reqDate;
//   final int reqNo; // Always 0
//   final String advPay; // "Y"/"N"
//   final String busGift; // "Y"/"N"
//   final int paymentMode;
//   final String mth;
//   final String paymentMonth;
//   final String comments;
//   final int emcode;
//   final double amtpad;
//   final String exstype;
//   final String exsdisplay;
//   final String repMnth;
//   final String repayCashDate;
//   final List<ClaimDetail> expDetls;
//   final List<BusinessGiftModel> bsnsGft;
//   final List<AdvancePaymentModel> cashAdvnc;
//   final List<ClaimAttachmentModel> attachments;
//   final String baseDirectory;
//   final double extotl;
//   final double bgtotl;
//   final double sbtotl;
//   final double adtotl;
//   final double ampaid;
//
//   SaveExpenseClaimModel({
//     required this.suconn,
//     required this.exmtid,
//     required this.hfEmcode,
//     required this.reqDate,
//     required this.reqNo,
//     required this.advPay,
//     required this.busGift,
//     required this.paymentMode,
//     required this.mth,
//     required this.paymentMonth,
//     required this.comments,
//     required this.emcode,
//     required this.amtpad,
//     required this.exstype,
//     required this.exsdisplay,
//     required this.repMnth,
//     required this.repayCashDate,
//     required this.expDetls,
//     required this.bsnsGft,
//     required this.cashAdvnc,
//     required this.attachments,
//     required this.baseDirectory,
//     required this.extotl,
//     required this.bgtotl,
//     required this.sbtotl,
//     required this.adtotl,
//     required this.ampaid,
//   });
//
//   Map<String, dynamic> toJson() => {
//     "suconn": suconn,
//     "exmtid": exmtid,
//     "hfEmcode": hfEmcode,
//     "reqDate": reqDate,
//     "reqNo": reqNo,
//     "advPay": advPay,
//     "busGift": busGift,
//     "paymentMode": paymentMode,
//     "mth": mth,
//     "paymentMonth": paymentMonth,
//     "comments": comments,
//     "emcode": emcode,
//     "amtpad": amtpad,
//     "exstype": exstype,
//     "exsdisplay": exsdisplay,
//     "repMnth": repMnth,
//     "repayCashDate": repayCashDate,
//     "expDetls": expDetls.map((e) => e.toJson()).toList(),
//     "bsnsGft": bsnsGft.map((e) => e.toJson()).toList(),
//     "cashAdvnc": cashAdvnc.map((e) => e.toJson()).toList(),
//     "attachments": attachments.map((e) => e.toJson()).toList(),
//     "baseDirectory": baseDirectory,
//     "extotl": extotl,
//     "bgtotl": bgtotl,
//     "sbtotl": sbtotl,
//     "adtotl": adtotl,
//     "ampaid": ampaid,
//   };
// }
