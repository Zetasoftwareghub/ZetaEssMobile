import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/change_request_model.dart';

// Holds final details to send
final changeRequestDetailsListProvider =
    StateProvider<List<ChangeRequestDetailModel>>((ref) => []);
//
// void updateField(
//   WidgetRef ref,
//   String field,
//   String value, {
//   String? chtext,
//   String? oldChtext,
//   String? oldChvalu,
// }) {
//   print(oldChtext);
//   print("value");
//   print(value);
//   final list = [...ref.read(changeRequestDetailsListProvider)];
//   final index = list.indexWhere((e) => e.chtype == field);
//   if (index >= 0) {
//     // update existing
//     list[index] = ChangeRequestDetailModel(
//       chtype: field,
//       chvalu: value,
//       oldChvalu: oldChvalu,
//       chtext: chtext,
//       oldChtext: oldChtext,
//     );
//   } else {
//     // add new
//     list.add(
//       ChangeRequestDetailModel(
//         chtype: field,
//         chvalu: value,
//         oldChvalu: oldChvalu,
//         chtext: chtext,
//         oldChtext: oldChtext,
//       ),
//     );
//   }
//
//   ref.read(changeRequestDetailsListProvider.notifier).state = list;
// }
void updateField(
  WidgetRef ref,
  String field,
  String value, {
  String? chtext,
  String? oldChtext,
  String? oldChvalu,
}) {
  final list = [...ref.read(changeRequestDetailsListProvider)];
  final index = list.indexWhere((e) => e.chtype == field);

  if (index >= 0) {
    final existing = list[index];

    // 🔥 KEEP EXISTING oldChtext — DO NOT override
    final finalOldChtext = existing.oldChtext ?? oldChtext;

    list[index] = ChangeRequestDetailModel(
      chtype: field,
      chvalu: value,
      chtext: chtext ?? existing.chtext,
      oldChvalu: oldChvalu ?? existing.oldChvalu,
      oldChtext: finalOldChtext,
    );
  } else {
    // first time add → store the passed oldChtext
    list.add(
      ChangeRequestDetailModel(
        chtype: field,
        chvalu: value,
        chtext: chtext,
        oldChvalu: oldChvalu,
        oldChtext: oldChtext, // first-time value
      ),
    );
  }

  ref.read(changeRequestDetailsListProvider.notifier).state = list;
}
