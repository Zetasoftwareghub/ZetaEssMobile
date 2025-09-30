import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/features/self_service/change_request/providers/change_request_providers.dart';

import '../../../../../core/common/widgets/customDropDown_widget.dart';

class CustomCountryDropDown extends ConsumerWidget {
  final String value;
  final void Function(String?)? onChanged;
  const CustomCountryDropDown(this.value, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(countryListProvider)
        .when(
          data: (countryList) {
            return CustomDropdown(
              hintText: "Select Country".tr(),
              value:
                  value == '0'
                      ? null
                      : value.isEmpty
                      ? null
                      : value,
              items:
                  countryList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.countryCode,
                          child: Text(e.countryName),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            );
          },
          error: (err, stack) => ErrorText(error: err.toString()),
          loading: () => Loader(),
        );
  }
}
