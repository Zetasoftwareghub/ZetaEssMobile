import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/lieuDay_notifier.dart';
import '../models/lieuDay_listing_model.dart';

final lieuDayListProvider =
    AutoDisposeAsyncNotifierProvider<LieuDayListNotifier, LieuDayListResponse>(
      LieuDayListNotifier.new,
    );
