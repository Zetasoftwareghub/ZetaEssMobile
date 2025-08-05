import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/employee_profile.dart';
import '../repository/employee_repository.dart';

final employeeProfileControllerProvider = AutoDisposeAsyncNotifierProvider<
  EmployeeProfileController,
  EmployeeProfile?
>(EmployeeProfileController.new);

class EmployeeProfileController
    extends AutoDisposeAsyncNotifier<EmployeeProfile?> {
  @override
  Future<EmployeeProfile?> build() async {
    final repository = ref.read(employeeRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repository.getEmployeeProfileDetails(
      userContext: userContext,
    );

    return result.fold((failure) => throw failure.errMsg, (data) => data);
  }
}
