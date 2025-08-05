import 'dart:convert';
import 'dart:typed_data';

class EmployeeProfile {
  final String employeeId;
  final String employeeName;
  final String department;
  final String designation;
  final String dateOfJoining;
  final String divisionName;
  final String categoryName;
  final String? lineManagerName, gradeName;

  final Uint8List? profileImage;
  final List<EmployeeSalary> employeeSalary;
  final List<EmployeeAllowance> employeeAllowance;
  final List<EmployeeDeduction> employeeDeduction;

  const EmployeeProfile({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.designation,
    required this.dateOfJoining,
    required this.divisionName,
    required this.categoryName,
    required this.employeeSalary,
    required this.employeeAllowance,
    required this.employeeDeduction,
    this.profileImage,
    this.gradeName,
    this.lineManagerName,
  });

  factory EmployeeProfile.fromJson(
    Map<String, dynamic> json,
    List<dynamic> salaryList,
    List<dynamic> allowanceList,
    List<dynamic> deductionList,
  ) {
    return EmployeeProfile(
      employeeId: json['eminid'] ?? '',
      profileImage:
          (json['EMPImage'] != null && json['EMPImage'] != '')
              ? base64Decode(json['EMPImage'])
              : null,
      employeeName: json['emname'] ?? '',
      department: json['dpname'] ?? '',
      designation: json['dename'] ?? '',
      dateOfJoining: json['emdojn'] ?? '',
      divisionName: json['diname'] ?? '',
      categoryName: json['ecname'] ?? '',
      lineManagerName: json['lnname'] ?? '',
      gradeName: json['gdname'] ?? '',
      employeeSalary:
          salaryList.map((e) => EmployeeSalary.fromJson(e)).toList(),
      employeeAllowance:
          allowanceList.map((e) => EmployeeAllowance.fromJson(e)).toList(),
      employeeDeduction:
          deductionList.map((e) => EmployeeDeduction.fromJson(e)).toList(),
    );
  }
}

class EmployeeSalary {
  final String salaryName;
  final double amount;

  EmployeeSalary({required this.salaryName, required this.amount});

  factory EmployeeSalary.fromJson(Map<String, dynamic> json) {
    return EmployeeSalary(
      salaryName: json['scname'] ?? '',
      amount: double.tryParse(json['epamnt1'].toString()) ?? 0.0,
    );
  }
}

class EmployeeAllowance {
  final String name;
  final double amount;

  EmployeeAllowance({required this.name, required this.amount});

  factory EmployeeAllowance.fromJson(Map<String, dynamic> json) {
    return EmployeeAllowance(
      name: json['alname'] ?? '',
      amount: double.tryParse(json['epamnt1'].toString()) ?? 0.0,
    );
  }
}

class EmployeeDeduction {
  final String name;
  final double amount;

  EmployeeDeduction({required this.name, required this.amount});

  factory EmployeeDeduction.fromJson(Map<String, dynamic> json) {
    return EmployeeDeduction(
      name: json['dtname'] ?? '',
      amount: double.tryParse(json['epamnt1'].toString()) ?? 0.0,
    );
  }
}
