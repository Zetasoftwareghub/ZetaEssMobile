import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/change_request_model.dart';

// Holds final details to send
final changeRequestDetailsListProvider =
    StateProvider<List<ChangeRequestDetailModel>>((ref) => []);

void updateField(WidgetRef ref, String field, String value) {
  final list = [...ref.read(changeRequestDetailsListProvider)];
  final index = list.indexWhere((e) => e.chtype == field);

  if (index >= 0) {
    // update existing
    list[index] = ChangeRequestDetailModel(chtype: field, chvalu: value);
  } else {
    // add new
    list.add(ChangeRequestDetailModel(chtype: field, chvalu: value));
  }

  ref.read(changeRequestDetailsListProvider.notifier).state = list;
}
