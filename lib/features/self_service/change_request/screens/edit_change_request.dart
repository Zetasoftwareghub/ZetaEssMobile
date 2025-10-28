import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/buttons/approveReject_buttons.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/change_request/screens/submit_change_request.dart';

import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/theme/common_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../approval_management/approve_change_request/controller/approve_change_request_controoler.dart';
import '../../../approval_management/approve_change_request/models/approve_change_req.dart';
import '../controller/change_request_controller.dart';
import '../models/change_request_model.dart';
import '../providers/form_provider.dart';
import 'forms/bank_details.dart';
import 'forms/current_address.dart';
import 'forms/emergency_contact.dart';
import 'forms/home_country_adress.dart';
import 'forms/martial_status.dart';
import 'forms/other_change_request_form.dart';
import 'forms/passport_details_form.dart';

class EditChangeRequestScreen extends ConsumerStatefulWidget {
  final String chrqst;
  final String? employeeCode;
  final int chrqcd;
  final bool isLineManager;
  final bool isSubmittedTab;
  const EditChangeRequestScreen({
    super.key,
    required this.chrqcd,
    required this.chrqst,
    this.employeeCode,
    this.isLineManager = false,
    this.isSubmittedTab = false,
  });

  @override
  ConsumerState<EditChangeRequestScreen> createState() =>
      _EditChangeRequestScreenState();
}

class _EditChangeRequestScreenState
    extends ConsumerState<EditChangeRequestScreen> {
  Widget? screen;
  final TextEditingController commentController = TextEditingController();
  // bool isLoading = false;
  // @override
  // void initState() {
  //   super.initState();
  //   getWhichEditScreen();
  // }
  bool isLoading = true; // 👈 Initially true to show loader

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    setState(() => isLoading = true);
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // 👈 small delay (optional)
    getWhichEditScreen();
    setState(() => isLoading = false);
  }

  getWhichEditScreen() {
    switch (widget.chrqst) {
      case "O":
        screen = OtherChangeRequestForm(
          reqId: widget.chrqcd,
          isLineManager: widget.isLineManager,
          employeeCode: widget.employeeCode,
        );
        break;
      case "P":
        screen = PassportDetailsForm(
          isLineManager: widget.isLineManager,
          reqId: widget.chrqcd,
          employeeCode: widget.employeeCode,
        );
        break;
      case "E":
        screen = EmergencyContactForm(
          reqId: widget.chrqcd,
          isLineManager: widget.isLineManager,
          employeeCode: widget.employeeCode,
        );
        break;
      case "H":
        screen = HomeCountryAddressForm(
          reqId: widget.chrqcd,
          isLineManager: widget.isLineManager,
          employeeCode: widget.employeeCode,
        );
        break;
      case "C":
        screen = CurrentAddressForm(
          reqId: widget.chrqcd,
          isLineManager: widget.isLineManager,
          employeeCode: widget.employeeCode,
        );
        break;
      case "B":
        screen = BankDetailsForm(
          reqId: widget.chrqcd,
          isLineManager: widget.isLineManager,
          employeeCode: widget.employeeCode,
        );
        break;
      case "M":
        screen = MaritalStatusForm(
          reqId: widget.chrqcd,
          isLineManager: widget.isLineManager,
          employeeCode: widget.employeeCode,
        );
        break;
      default:
        screen = SubmitChangeRequestScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(
              widget.isSubmittedTab
                  ? "Approve"
                  : widget.isLineManager
                  ? 'Approve Details'
                  : "EDIT",
            ).tr(),
      ),
      body: Padding(
        padding: AppPadding.screenPadding,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height, // screen height
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  if (widget.isSubmittedTab)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleHeaderText('Approval/Reject comment'),
                        inputField(
                          hint: 'Approve/Reject Comment'.tr(),
                          controller: commentController,
                        ),
                        12.heightBox,
                      ],
                    ),

                  screen ?? const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: AppPadding.screenBottomSheetPadding,
        child:
            widget.isLineManager
                ? widget.isSubmittedTab
                    ? SafeArea(
                      child: ApproveRejectButtons(
                        onApprove:
                            () => _handleApproveReject(
                              ref: ref,
                              context: context,
                              commentController: commentController,
                              aprFlag: 'A',
                            ),
                        onReject:
                            () => _handleApproveReject(
                              ref: ref,
                              context: context,
                              commentController: commentController,
                              aprFlag: 'R',
                            ),
                      ),
                    )
                    : const SizedBox.shrink()
                : CustomElevatedButton(
                  child: Text(updateText.tr()),
                  onPressed: () {
                    final requestDetailsList = ref.watch(
                      changeRequestDetailsListProvider,
                    );

                    final user = ref.watch(userContextProvider);
                    final saveModel = ChangeRequestModel(
                      oldBaName: ref.watch(oldBanmrovider),
                      oldBcAcNm: oldBankModel?.accountName,
                      oldBcAcNo: oldBankModel?.accountNumber,
                      bankNameDetail: ref.watch(oldBanmrovider),
                      suconn: user.companyConnection ?? '',
                      sucode: user.companyCode,
                      chrqcd: widget.chrqcd,
                      chrqtp: widget.chrqst,
                      emcode: int.parse(user.empCode),
                      chrqdt: convertDateToYYmmDD(DateTime.now()),
                      bacode: ref.watch(bankCodeProvider) ?? 0,
                      bcacno: ref.watch(bankAccNoProvider),
                      bcacnm: ref.watch(bankAccNameProvider),
                      chrqst: widget.chrqst,
                      detail: requestDetailsList,
                      chrqtpText: "",
                    );

                    ref
                        .read(changeRequestControllerProvider.notifier)
                        .submitChangeRequest(
                          context: context,
                          saveModel: saveModel,
                        );
                  },
                ),
      ),
    );
  }

  void _handleApproveReject({
    required WidgetRef ref,
    required BuildContext context,
    required TextEditingController commentController,
    required String aprFlag,
  }) {
    final user = ref.watch(userContextProvider);
    final requestDetailsList = ref.watch(changeRequestDetailsListProvider);

    final saveModel = ChangeRequestModel(
      suconn: user.companyConnection ?? '',
      sucode: user.companyCode,
      chrqcd: widget.chrqcd,
      chrqtp: widget.chrqst,
      emcode: int.parse(user.empCode),
      chrqdt: convertDateToYYmmDD(DateTime.now()),
      bacode: ref.watch(bankCodeProvider) ?? 0,
      bcacno: ref.watch(bankAccNoProvider),
      bcacnm: ref.watch(bankAccNameProvider),
      chrqst: widget.chrqst,
      detail: requestDetailsList,
      chrqtpText: "",
    );

    printFullJson(saveModel.toJson());
    print('saveModel.to');

    final approveChangeRequestModel = ApproveChangeRequestModel(
      suconn: user.companyConnection,
      sucode: user.companyCode,
      chRqCd: widget.chrqcd ?? 0,
      chApBy: user.empName,
      bcSlNo: '0',
      chapnt: commentController.text,
      emCode: user.empCode,
      chtype: widget.chrqst,
      aprFlag: aprFlag,
      changeRequest: saveModel,
    );

    ref
        .read(approveChangeRequestControllerProvider.notifier)
        .approveRejectChangeRequest(
          approveChangeRequestModel: approveChangeRequestModel,
          context: context,
        );
  }
}
