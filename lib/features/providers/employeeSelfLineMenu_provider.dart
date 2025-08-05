import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/models/employeeMenu_model.dart';

import '../../core/providers/userContext_provider.dart';
import '../common/repository/employee_repository.dart';

final employeeSelfLineMenusProvider =
    FutureProvider.autoDispose<EmployeeMenuModel>((ref) async {
      final repo = ref.read(employeeRepositoryProvider);
      final userContext = ref.read(userContextProvider);

      final result = await repo.getEmployeeSelfLineMenus(
        userContext: userContext,
      );

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (menus) => menus,
      );
    });
