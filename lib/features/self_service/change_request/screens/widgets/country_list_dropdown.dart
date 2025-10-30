import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/features/self_service/change_request/models/country_details_model.dart';
import 'package:zeta_ess/features/self_service/change_request/providers/change_request_providers.dart';

import '../../../../../core/common/widgets/customDropDown_widget.dart';

class CustomCountryDropDown extends ConsumerWidget {
  final String countryCode;
  final void Function(String? code, String? name, String? oldName)? onChanged;
  const CustomCountryDropDown({
    super.key,
    required this.countryCode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(countryListProvider)
        .when(
          data: (countryList) {
            final selectedCountry = countryList.firstWhere(
              (element) => element.countryCode == countryCode,
              orElse:
                  () => CountryDetailsModel(countryCode: '', countryName: ''),
            );

            final oldCountryName = selectedCountry.countryName ?? '';

            // 🔼 Automatically notify parent (if needed)
            if (onChanged != null && oldCountryName.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onChanged!(countryCode, oldCountryName, oldCountryName);
              });
            }

            return CustomDropdown(
              hintText: onChanged == null ? "No value" : "Select Country".tr(),
              value:
                  countryCode == '0'
                      ? null
                      : countryCode.isEmpty
                      ? null
                      : countryCode,
              items:
                  countryList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.countryCode,
                          child: Text(e.countryName),
                        ),
                      )
                      .toList(),

              onChanged: (value) {
                if (value != null) {
                  final name =
                      countryList
                          .firstWhere((c) => c.countryCode == value)
                          .countryName;
                  onChanged?.call(value, name, oldCountryName);
                } // if (onChanged != null) {
                //   final selected = countryList.firstWhere(
                //     (element) => element.countryCode == v,
                //   );
                //   onChanged!(v, selected.countryName);
                // }
              },
            );
          },
          error: (err, stack) => ErrorText(error: err.toString()),
          loading: () => Loader(),
        );
  }
}
