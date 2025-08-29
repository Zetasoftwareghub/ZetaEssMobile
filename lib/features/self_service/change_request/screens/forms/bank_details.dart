import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../../../../core/common/error_text.dart';
import '../../../../../core/common/loader.dart';
import '../../../../../core/common/widgets/customDropDown_widget.dart';
import '../../models/change_request_model.dart';
import '../../providers/change_request_providers.dart';

final bankAccNoProvider = StateProvider<String?>((ref) => null);
final bankCodeProvider = StateProvider<int?>((ref) => null);
final bankAccNameProvider = StateProvider<String?>((ref) => null);

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

  void _initializeFromChangeRequest(ChangeRequestModel changeRequest) {
    if (_isInitialized) return;

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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reqId != null) {
      final changeRequestAsync = ref.watch(
        changeRequestDetailsFetchProvider(widget.reqId!),
      );

      // Initialize from change request when data is available
      changeRequestAsync.whenData((changeRequest) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeFromChangeRequest(changeRequest);
        });
      });
    }

    final bankDetailsAsync = ref.watch(
      banksDetailsProvider(widget.employeeCode),
    );

    return bankDetailsAsync.when(
      data: (bankDetails) {
        return Column(
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
              bankCode: ref.watch(bankCodeProvider) ?? bankDetails.bankCode,
              accountNumber:
                  ref.watch(bankAccNoProvider) ?? bankDetails.accountNumber,
              accountName:
                  ref.watch(bankAccNameProvider) ?? bankDetails.accountName,
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
                return CustomDropdown<int>(
                  hintText: 'Bank not selected',
                  value: bankCode == 0 ? null : bankCode,
                  onChanged:
                      readOnly
                          ? null
                          : (v) =>
                              ref.read(bankCodeProvider.notifier).state = v,
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

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
  );

  @override
  void dispose() {
    accountNumberController.dispose();
    accountNameController.dispose();
    super.dispose();
  }
}
