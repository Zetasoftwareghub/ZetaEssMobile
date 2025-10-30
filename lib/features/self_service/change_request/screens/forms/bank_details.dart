import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../../../../core/common/error_text.dart';
import '../../../../../core/common/loader.dart';
import '../../../../../core/common/widgets/customDropDown_widget.dart';
import '../../models/bank_model.dart';
import '../../models/change_request_model.dart';
import '../../providers/change_request_providers.dart';

BankDetailsModel? oldBankModel;

final bankAccNoProvider = StateProvider<String?>((ref) => null);
final bankCodeProvider = StateProvider<int?>((ref) => null);
final bankNameProvider = StateProvider<String?>((ref) => null);
final bankAccNameProvider = StateProvider<String?>((ref) => null);
final oldBankCodeProvider = StateProvider<String?>((ref) => null);
final oldBankNameProvider = StateProvider<String?>((ref) => null);

class BankDetailsForm extends ConsumerStatefulWidget {
  final int? reqId;
  final bool? isLineManager;
  final String? employeeCode;

  const BankDetailsForm({
    super.key,
    this.employeeCode,
    this.reqId,
    this.isLineManager,
  });

  @override
  ConsumerState<BankDetailsForm> createState() => _BankDetailsFormState();
}

class _BankDetailsFormState extends ConsumerState<BankDetailsForm> {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  bool _isInitialized = false;
  String? comment;
  bool _isBankDetailsInitialized = false;

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;
    ref.read(bankNameProvider.notifier).state ??= changeRequest.bankNameDetail;

    if (changeRequest.bcacno != null) {
      accountNumberController.text = changeRequest.bcacno!;
      ref.read(bankAccNoProvider.notifier).state = changeRequest.bcacno!;
    }
    if (changeRequest.bcacnm != null) {
      accountNameController.text = changeRequest.bcacnm!;
      ref.read(bankAccNameProvider.notifier).state = changeRequest.bcacnm!;
    }
    if (changeRequest.bacode != 0) {
      ref.read(bankCodeProvider.notifier).state = changeRequest.bacode;
    }
    _isInitialized = true;
    setState(() => comment = changeRequest.comment);
  }

  void _initializeFromBankDetails(BankDetailsModel bankDetails) {
    if (_isBankDetailsInitialized) return;
    oldBankModel = bankDetails;

    ref.read(oldBankCodeProvider.notifier).state ??=
        bankDetails.bankCode.toString();
    ref.read(bankAccNoProvider.notifier).state ??= bankDetails.accountNumber;
    ref.read(bankCodeProvider.notifier).state ??= bankDetails.bankCode;
    ref.read(bankAccNameProvider.notifier).state ??= bankDetails.accountName;

    _isBankDetailsInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reqId != null) {
      ref.listen<AsyncValue<ChangeRequestModel>>(
        changeRequestDetailsFetchProvider(widget.reqId!),
        (prev, next) {
          next.whenData((changeRequest) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeFromChangeRequest(changeRequest);
            });
          });
        },
      );
    }

    // Watch bank details provider
    final bankDetailsAsync = ref.watch(
      banksDetailsProvider(widget.employeeCode),
    );

    // Listen to bank details provider to initialize dependent states
    ref.listen<AsyncValue<BankDetailsModel>>(
      banksDetailsProvider(widget.employeeCode),
      (prev, next) {
        next.whenData((bankDetails) {
          _initializeFromBankDetails(bankDetails);
        });
      },
    );
    // final bankDetailsAsync = ref.watch(
    //   banksDetailsProvider(widget.employeeCode),
    // );

    return bankDetailsAsync.when(
      data: (bankDetails) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formSection(
              title: "Old Value",
              readOnly: true,
              bankCode: bankDetails.bankCode,
              accountNumber: bankDetails.accountNumber,
              accountName: bankDetails.accountName,
            ),
            _formSection(
              title: "New Value",
              readOnly: widget.isLineManager ?? false,
              bankCode: ref.watch(bankCodeProvider) ?? 0,
              accountNumber:
                  ref.watch(bankAccNoProvider) ?? bankDetails.accountNumber,
              accountName:
                  ref.watch(bankAccNameProvider) ?? bankDetails.accountName,
            ),
            if ((widget.isLineManager ?? false) &&
                (comment?.isNotEmpty ?? false))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleHeaderText("Comment"),
                  labelText(comment ?? ''),
                ],
              ),
          ],
        );
      },
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => Loader(),
    );
  }

  Widget _formSection({
    required String title,
    required bool readOnly,
    required int bankCode,
    required String accountNumber,
    required String accountName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHeaderText(title),
        labelText("Bank Name"),
        ref
            .watch(banksListProvider)
            .when(
              data: (bankList) {
                if (readOnly) {
                  Future.microtask(
                    () =>
                        ref.read(oldBankNameProvider.notifier).state =
                            bankList
                                .firstWhere(
                                  (element) => element.bankCode == bankCode,
                                )
                                .bankDisplayName,
                  );
                }
                return CustomDropdown<int>(
                  hintText: 'Bank not selected',
                  value: bankCode == 0 ? null : bankCode,
                  onChanged:
                      readOnly
                          ? null
                          : (v) {
                            ref.read(bankNameProvider.notifier).state =
                                bankList
                                    .firstWhere(
                                      (element) => element.bankCode == v,
                                    )
                                    .bankDisplayName;
                            ref.read(bankCodeProvider.notifier).state = v;
                          },
                  items:
                      bankList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.bankCode,
                              child: Text(e.bankDisplayName),
                            ),
                          )
                          .toList(),
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => Loader(),
            ),
        labelText("Account Number"),
        readOnly
            ? labelText(accountNumber)
            : inputField(
              hint: "Enter account number",
              controller: accountNumberController,
              keyboardType: TextInputType.number,
              onChanged:
                  (val) => ref.read(bankAccNoProvider.notifier).state = val,
            ),
        labelText("Account Name"),
        readOnly
            ? labelText(accountName)
            : inputField(
              hint: "Enter account name",
              controller: accountNameController,
              onChanged:
                  (val) => ref.read(bankAccNameProvider.notifier).state = val,
            ),
      ],
    );
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    accountNameController.dispose();
    super.dispose();
  }
}
