import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../models/version_check.dart';
import '../repository/home_repository.dart';

final versionFutureProvider = FutureProvider<VersionModel?>((ref) async {
  final repo = ref.read(homeRepositoryProvider);
  final userContext = ref.read(userContextProvider);
  return await repo.getVersionCheck(userContext: userContext);
});
