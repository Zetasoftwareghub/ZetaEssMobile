import 'package:flutter/material.dart';

import '../../models/change_request_model.dart';

/// Get a detail value by its `chtype`
String? getValueFromDetails(
  List<ChangeRequestDetailModel> details,
  String chtype,
) {
  return details
      .firstWhere(
        (e) => e.chtype == chtype,
        orElse: () => ChangeRequestDetailModel(chtype: chtype, chvalu: ''),
      )
      .chvalu;
}
