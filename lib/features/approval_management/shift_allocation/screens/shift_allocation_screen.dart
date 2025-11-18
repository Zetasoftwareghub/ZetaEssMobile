import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import '../../../../core/theme/app_theme.dart';

// ==================== MODELS ====================
class Employee {
  final String id;
  final String name;

  Employee({required this.id, required this.name});

  Employee copyWith({String? id, String? name}) {
    return Employee(id: id ?? this.id, name: name ?? this.name);
  }
}

class ShiftDate {
  final DateTime date;
  final String dateString;
  final String day;

  ShiftDate({required this.date, required this.dateString, required this.day});
}

class ShiftAllocation {
  final String employeeId;
  final DateTime date;
  final String shiftType;
  final ShiftStatus status;

  ShiftAllocation({
    required this.employeeId,
    required this.date,
    required this.shiftType,
    required this.status,
  });

  ShiftAllocation copyWith({
    String? employeeId,
    DateTime? date,
    String? shiftType,
    ShiftStatus? status,
  }) {
    return ShiftAllocation(
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      shiftType: shiftType ?? this.shiftType,
      status: status ?? this.status,
    );
  }
}

enum ShiftStatus { normal, weeklyOff, holiday, halfDayWeeklyOff }

class ShiftFilter {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? selectedEmployeeId;

  ShiftFilter({this.fromDate, this.toDate, this.selectedEmployeeId});

  ShiftFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedEmployeeId,
  }) {
    return ShiftFilter(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedEmployeeId: selectedEmployeeId ?? this.selectedEmployeeId,
    );
  }
}

// ==================== PROVIDERS ====================

// Employee Provider
final employeesProvider =
    StateNotifierProvider<EmployeesNotifier, List<Employee>>((ref) {
      return EmployeesNotifier();
    });

class EmployeesNotifier extends StateNotifier<List<Employee>> {
  EmployeesNotifier() : super(_generateEmployees());

  static List<Employee> _generateEmployees() {
    return List.generate(10, (index) {
      final names = [
        'Vikram Kumar',
        'Barry Black',
        'Sarah Johnson',
        'Michael Chen',
        'Priya Sharma',
        'David Wilson',
        'Anita Desai',
        'Robert Taylor',
        'Meera Patel',
        'James Anderson',
      ];
      return Employee(
        id: 'EMP${(index + 1).toString().padLeft(3, '0')}',
        name: names[index],
      );
    });
  }
}

// Filter Provider
final shiftFilterProvider =
    StateNotifierProvider<ShiftFilterNotifier, ShiftFilter>((ref) {
      return ShiftFilterNotifier();
    });

class ShiftFilterNotifier extends StateNotifier<ShiftFilter> {
  ShiftFilterNotifier()
    : super(
        ShiftFilter(
          fromDate: DateTime(2025, 10, 6),
          toDate: DateTime(2025, 11, 18),
          selectedEmployeeId: 'All',
        ),
      );

  void updateFromDate(DateTime date) {
    state = state.copyWith(fromDate: date);
  }

  void updateToDate(DateTime date) {
    state = state.copyWith(toDate: date);
  }

  void updateSelectedEmployee(String employeeId) {
    state = state.copyWith(selectedEmployeeId: employeeId);
  }

  void reset() {
    state = ShiftFilter(
      fromDate: DateTime(2025, 10, 6),
      toDate: DateTime(2025, 11, 18),
      selectedEmployeeId: 'All',
    );
  }
}

// Filtered Employees Provider
final filteredEmployeesProvider = Provider<List<Employee>>((ref) {
  final employees = ref.watch(employeesProvider);
  final filter = ref.watch(shiftFilterProvider);

  if (filter.selectedEmployeeId == null || filter.selectedEmployeeId == 'All') {
    return employees;
  }

  return employees.where((emp) => emp.id == filter.selectedEmployeeId).toList();
});

// Date Range Provider
final dateRangeProvider = Provider<List<ShiftDate>>((ref) {
  final filter = ref.watch(shiftFilterProvider);

  if (filter.fromDate == null || filter.toDate == null) {
    return [];
  }

  List<ShiftDate> dates = [];
  DateTime current = filter.fromDate!;

  while (current.isBefore(filter.toDate!) ||
      current.isAtSameMomentAs(filter.toDate!)) {
    dates.add(
      ShiftDate(
        date: current,
        dateString: DateFormat('dd-MM-yyyy').format(current),
        day: DateFormat('EEE').format(current).toUpperCase(),
      ),
    );
    current = current.add(Duration(days: 1));
  }

  return dates;
});

// Shift Allocations Provider
final shiftAllocationsProvider = StateNotifierProvider<
  ShiftAllocationsNotifier,
  Map<String, ShiftAllocation>
>((ref) {
  return ShiftAllocationsNotifier();
});

class ShiftAllocationsNotifier
    extends StateNotifier<Map<String, ShiftAllocation>> {
  ShiftAllocationsNotifier() : super({});

  String _getKey(String employeeId, DateTime date) {
    return '${employeeId}_${DateFormat('yyyy-MM-dd').format(date)}';
  }

  ShiftStatus getShiftStatus(String employeeId, DateTime date) {
    // Saturday logic
    if (date.weekday == DateTime.saturday) {
      return ShiftStatus.halfDayWeeklyOff;
    }
    // Sunday logic
    if (date.weekday == DateTime.sunday) {
      return ShiftStatus.weeklyOff;
    }
    return ShiftStatus.normal;
  }

  void addShift(String employeeId, DateTime date, String shiftType) {
    final key = _getKey(employeeId, date);
    state = {
      ...state,
      key: ShiftAllocation(
        employeeId: employeeId,
        date: date,
        shiftType: shiftType,
        status: getShiftStatus(employeeId, date),
      ),
    };
  }

  void removeShift(String employeeId, DateTime date) {
    final key = _getKey(employeeId, date);
    final newState = Map<String, ShiftAllocation>.from(state);
    newState.remove(key);
    state = newState;
  }
}

// Selected Employees Provider
final selectedEmployeesProvider =
    StateNotifierProvider<SelectedEmployeesNotifier, Set<String>>((ref) {
      return SelectedEmployeesNotifier();
    });

class SelectedEmployeesNotifier extends StateNotifier<Set<String>> {
  SelectedEmployeesNotifier() : super({});

  void toggle(String employeeId) {
    if (state.contains(employeeId)) {
      state = {...state}..remove(employeeId);
    } else {
      state = {...state, employeeId};
    }
  }

  void selectAll(List<String> employeeIds) {
    state = employeeIds.toSet();
  }

  void clearAll() {
    state = {};
  }
}

// ==================== SCREEN ====================

class ShiftAllocationScreen extends ConsumerStatefulWidget {
  const ShiftAllocationScreen({super.key});

  @override
  ConsumerState<ShiftAllocationScreen> createState() =>
      _ShiftAllocationScreenState();
}

class _ShiftAllocationScreenState extends ConsumerState<ShiftAllocationScreen> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  bool _isHeaderScrolling = false;
  bool _isBodyScrolling = false;

  @override
  void initState() {
    super.initState();
    _setupScrollSync();
  }

  void _setupScrollSync() {
    _headerScrollController.addListener(() {
      if (_isBodyScrolling) return;
      _isHeaderScrolling = true;
      if (_bodyScrollController.hasClients) {
        _bodyScrollController.jumpTo(_headerScrollController.offset);
      }
      _isHeaderScrolling = false;
    });

    _bodyScrollController.addListener(() {
      if (_isHeaderScrolling) return;
      _isBodyScrolling = true;
      if (_headerScrollController.hasClients) {
        _headerScrollController.jumpTo(_bodyScrollController.offset);
      }
      _isBodyScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Employee Shift Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(shiftFilterProvider.notifier).reset(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(child: _buildScheduleTable()),
          _buildLegend(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    final filter = ref.watch(shiftFilterProvider);
    final employees = ref.watch(employeesProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEmployeeDropdown(employees, filter.selectedEmployeeId ?? 'All'),
          12.heightBox,
          Row(
            children: [
              Expanded(
                child: CustomDateField(
                  hintText: 'From',
                  initialDate: formatDate(filter.fromDate ?? DateTime.now()),
                  onDateSelected: (date) {
                    ref
                        .read(shiftFilterProvider.notifier)
                        .updateFromDate(DateTime.parse(date));
                  },
                ),
              ),
              12.widthBox,
              Expanded(
                child: CustomDateField(
                  hintText: 'To',
                  initialDate: formatDate(filter.toDate ?? DateTime.now()),
                  onDateSelected: (date) {
                    ref
                        .read(shiftFilterProvider.notifier)
                        .updateToDate(DateTime.parse(date));
                  },
                ),
              ),
            ],
          ),
          12.heightBox,
          CustomElevatedButton(onPressed: _bindData, child: Text('Bind Data')),
        ],
      ),
    );
  }

  Widget _buildEmployeeDropdown(
    List<Employee> employees,
    String selectedValue,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.people, color: AppTheme.primaryColor, size: 20.sp),
          8.widthBox,
          Expanded(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              underline: SizedBox(),
              items: [
                DropdownMenuItem(value: 'All', child: Text('All Employees')),
                ...employees.map(
                  (e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('${e.id} - ${e.name}'),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(shiftFilterProvider.notifier)
                      .updateSelectedEmployee(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    final filteredEmployees = ref.watch(filteredEmployeesProvider);
    final dates = ref.watch(dateRangeProvider);

    if (dates.isEmpty) {
      return Center(
        child: Text('Please select date range and click "Bind Data"'),
      );
    }

    return Container(
      margin: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(dates),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _bodyScrollController,
              child: SingleChildScrollView(
                child: _buildTableBody(filteredEmployees, dates),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(List<ShiftDate> dates) {
    final selectedEmployees = ref.watch(selectedEmployeesProvider);
    final filteredEmployees = ref.watch(filteredEmployeesProvider);
    final allSelected =
        selectedEmployees.length == filteredEmployees.length &&
        filteredEmployees.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _headerScrollController,

        child: Row(
          children: [
            _buildHeaderCell(
              'Employee',
              isFirst: true,
              width: 180.w,
              showCheckbox: true,
              checkboxValue: allSelected,
              onCheckboxChanged: (val) {
                if (val == true) {
                  ref
                      .read(selectedEmployeesProvider.notifier)
                      .selectAll(filteredEmployees.map((e) => e.id).toList());
                } else {
                  ref.read(selectedEmployeesProvider.notifier).clearAll();
                }
              },
            ),
            Row(
              children:
                  dates
                      .map(
                        (d) => _buildHeaderCell(
                          '${d.dateString}\n${d.day}',
                          width: 110.w,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    bool isFirst = false,
    required double width,
    bool showCheckbox = false,
    bool checkboxValue = false,
    Function(bool?)? onCheckboxChanged,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showCheckbox)
            Checkbox(
              value: checkboxValue,
              onChanged: onCheckboxChanged,
              fillColor: WidgetStateProperty.all(Colors.white),
              checkColor: AppTheme.primaryColor,
            ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: isFirst ? TextAlign.left : TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(List<Employee> employees, List<ShiftDate> dates) {
    return Column(
      children: employees.map((emp) => _buildEmployeeRow(emp, dates)).toList(),
    );
  }

  Widget _buildEmployeeRow(Employee emp, List<ShiftDate> dates) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmployeeCell(emp),
            ...dates.map((date) => _buildShiftCell(emp, date)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCell(Employee emp) {
    final selectedEmployees = ref.watch(selectedEmployeesProvider);
    final isSelected = selectedEmployees.contains(emp.id);

    return Container(
      width: 180.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppTheme.lightBlueColor.withOpacity(0.3)
                : Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (val) {
              ref.read(selectedEmployeesProvider.notifier).toggle(emp.id);
            },
            activeColor: AppTheme.primaryColor,
          ),
          8.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.id,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                2.heightBox,
                Text(
                  emp.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCell(Employee emp, ShiftDate date) {
    final shiftNotifier = ref.read(shiftAllocationsProvider.notifier);
    final status = shiftNotifier.getShiftStatus(emp.id, date.date);

    return Container(
      width: 110.w,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShiftButton('sh1', emp.id, date.date),
          6.heightBox,
          _buildAddButton(emp.id, date.date),
        ],
      ),
    );
  }

  Color _getStatusColor(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.weeklyOff:
        return Colors.red;
      case ShiftStatus.holiday:
        return Colors.green;
      case ShiftStatus.halfDayWeeklyOff:
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildShiftButton(String text, String employeeId, DateTime date) {
    return InkWell(
      onTap: () => _showShiftOptions(employeeId, date),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.25),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(String employeeId, DateTime date) {
    return InkWell(
      onTap: () => _addShift(employeeId, date),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Add',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend:',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          8.heightBox,
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _buildLegendItem(Colors.red, 'Weekly Off'),
              _buildLegendItem(Colors.green, 'Holiday'),
              _buildLegendItem(Colors.yellow, 'Half Day Weekly Off'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        6.widthBox,
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final selectedEmployees = ref.watch(selectedEmployeesProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Email',
              Icons.email_outlined,
              AppTheme.primaryColor,
              selectedEmployees.isEmpty,
            ),
          ),
          12.widthBox,
          Expanded(
            child: _buildActionButton(
              'Bulk Edit',
              Icons.edit_outlined,
              AppTheme.greenFigColor,
              selectedEmployees.isEmpty,
            ),
          ),
          12.widthBox,
          Expanded(
            child: _buildActionButton(
              'Close',
              Icons.close,
              AppTheme.errorColor,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    bool disabled,
  ) {
    return ElevatedButton(
      onPressed: disabled ? null : () => _handleAction(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? Colors.grey.shade300 : color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: disabled ? 0 : 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp),
          6.widthBox,
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _bindData() {
    final filter = ref.read(shiftFilterProvider);

    if (filter.fromDate == null || filter.toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both from and to dates')),
      );
      return;
    }

    if (filter.fromDate!.isAfter(filter.toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('From date must be before To date')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data loaded successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _addShift(String employeeId, DateTime date) {
    ref
        .read(shiftAllocationsProvider.notifier)
        .addShift(employeeId, date, 'sh1');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shift added successfully'),
        duration: Duration(seconds: 1),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showShiftOptions(String employeeId, DateTime date) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shift Options',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                20.heightBox,
                ListTile(
                  leading: Icon(Icons.edit, color: AppTheme.primaryColor),
                  title: Text('Edit Shift'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: AppTheme.errorColor),
                  title: Text('Remove Shift'),
                  onTap: () {
                    ref
                        .read(shiftAllocationsProvider.notifier)
                        .removeShift(employeeId, date);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _handleAction(String action) {
    final selectedEmployees = ref.read(selectedEmployeesProvider);

    switch (action) {
      case 'Email':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email sent to ${selectedEmployees.length} employees',
            ),
          ),
        );
        break;
      case 'Bulk Edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bulk edit for ${selectedEmployees.length} employees',
            ),
          ),
        );
        break;
      case 'Close':
        Navigator.pop(context);
        break;
    }
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }
} // import 'package:flutter/material.dart';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
// import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
// import 'package:zeta_ess/core/utils.dart';
//
// import '../../../../core/theme/app_theme.dart';
//
// class ShiftAllocationScreen extends StatefulWidget {
//   const ShiftAllocationScreen({super.key});
//
//   @override
//   State<ShiftAllocationScreen> createState() => _ShiftAllocationScreenState();
// }
//
// class _ShiftAllocationScreenState extends State<ShiftAllocationScreen> {
//   final TextEditingController _fromDateController = TextEditingController(
//     text: '06/10/2025',
//   );
//   final TextEditingController _toDateController = TextEditingController(
//     text: '18/11/2025',
//   );
//   String _selectedEmployee = 'All';
//   final Set<String> _selectedEmployees = {};
//
//   final List<Employee> employees = [
//     Employee(id: 'vi12', name: 'Vikram'),
//     Employee(id: 'vi15', name: 'Barry Black'),
//   ];
//
//   final List<ShiftDate> dates = [
//     ShiftDate(date: '06-10-2025', day: 'MON'),
//     ShiftDate(date: '07-10-2025', day: 'TUE'),
//     ShiftDate(date: '08-10-2025', day: 'WED'),
//     ShiftDate(date: '09-10-2025', day: 'THU'),
//     ShiftDate(date: '10-10-2025', day: 'FRI'),
//     ShiftDate(date: '11-10-2025', day: 'SAT'),
//     ShiftDate(date: '12-10-2025', day: 'SUN'),
//     ShiftDate(date: '13-10-2025', day: 'MON'),
//     ShiftDate(date: '14-10-2025', day: 'TUE'),
//     ShiftDate(date: '15-10-2025', day: 'WED'),
//   ];
//
//   Color _getShiftColor(int dateIndex, int employeeIndex) {
//     if (dateIndex == 5) return Colors.yellow.shade600;
//     if (dateIndex == 6) return Colors.red;
//     return Colors.transparent;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Employee Shift Schedule')),
//       body: Column(
//         children: [
//           _buildFiltersSection(),
//           Expanded(child: _buildScheduleTable()),
//           _buildLegend(),
//           _buildActionButtons(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFiltersSection() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//
//       child: Column(
//         children: [
//           _buildEmployeeDropdown(),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               Expanded(child: CustomDateField(hintText: 'From',initialDate: ,onDateSelected: ,),),
//               12.widthBox,
//               Expanded(child: CustomDateField(hintText: 'To',initialDate: ,onDateSelected: ,)),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           CustomElevatedButton(onPressed: () {}, child: Text('Bind Data')),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmployeeDropdown() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.r),
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 12.w),
//       child: Row(
//         children: [
//           Icon(Icons.people, color: AppTheme.primaryColor, size: 20.sp),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: DropdownButton<String>(
//               value: _selectedEmployee,
//               isExpanded: true,
//               underline: SizedBox(),
//               items: [
//                 DropdownMenuItem(value: 'All', child: Text('All')),
//                 ...employees.map(
//                   (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
//                 ),
//               ],
//               onChanged: (value) => setState(() => _selectedEmployee = value!),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScheduleTable() {
//     return Container(
//       margin: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildTableHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SingleChildScrollView(child: _buildTableBody()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTableHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primaryColor,
//             AppTheme.primaryColor.withOpacity(0.8),
//           ],
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(12.r),
//           topRight: Radius.circular(12.r),
//         ),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _buildHeaderCell('Employee', isFirst: true, width: 150.w),
//             ...dates.map(
//               (d) => _buildHeaderCell('${d.date}\n${d.day}', width: 100.w),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderCell(
//     String text, {
//     bool isFirst = false,
//     required double width,
//   }) {
//     return Container(
//       width: width,
//       padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
//       decoration: BoxDecoration(
//         border: Border(
//           right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           if (isFirst)
//             Checkbox(
//               value: false,
//               onChanged: (_) {},
//               fillColor: WidgetStateProperty.all(Colors.white),
//             ),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: isFirst ? TextAlign.left : TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTableBody() {
//     return Column(
//       children:
//           employees.asMap().entries.map((entry) {
//             int empIndex = entry.key;
//             Employee emp = entry.value;
//             return _buildEmployeeRow(emp, empIndex);
//           }).toList(),
//     );
//   }
//
//   Widget _buildEmployeeRow(Employee emp, int empIndex) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: AppTheme.lightBlueColor, width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           _buildEmployeeCell(emp),
//           ...dates.asMap().entries.map((entry) {
//             int dateIndex = entry.key;
//             return _buildShiftCell(dateIndex, empIndex);
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmployeeCell(Employee emp) {
//     return Container(
//       width: 150.w,
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         border: Border(right: BorderSide(color: AppTheme.lightBlueColor)),
//       ),
//       child: Row(
//         children: [
//           Checkbox(
//             value: _selectedEmployees.contains(emp.id),
//             onChanged: (val) {
//               setState(() {
//                 if (val!)
//                   _selectedEmployees.add(emp.id);
//                 else
//                   _selectedEmployees.remove(emp.id);
//               });
//             },
//           ),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   emp.id,
//                   style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//                 ),
//                 Text(
//                   emp.name,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShiftCell(int dateIndex, int empIndex) {
//     return Container(
//       width: 100.w,
//       padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
//       color: _getShiftColor(dateIndex, empIndex),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildShiftButton('sh1'),
//           SizedBox(height: 4.h),
//           _buildAddButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShiftButton(String text) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.purple.shade400, Colors.purple.shade600],
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(text, style: TextStyle(color: Colors.white, fontSize: 11.sp)),
//     );
//   }
//
//   Widget _buildAddButton() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Text(
//         'Add',
//         style: TextStyle(color: Colors.grey.shade700, fontSize: 11.sp),
//       ),
//     );
//   }
//
//   Widget _buildLegend() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: Wrap(
//         spacing: 12.w,
//         runSpacing: 8.h,
//         children: [
//           _buildLegendItem(Colors.red, 'Weekly off'),
//           _buildLegendItem(Colors.green, 'Holiday'),
//           _buildLegendItem(Colors.yellow.shade600, 'Half day Weekly Off'),
//           _buildLegendItem(Colors.purple.shade400, 'Default Shift'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(Color color, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 16.w,
//           height: 16.w,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4.r),
//           ),
//         ),
//         SizedBox(width: 6.w),
//         Text(
//           label,
//           style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildActionButton('Email', Icons.email, Colors.blue),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: _buildActionButton('Bulk Edit', Icons.edit, Colors.green),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(child: _buildActionButton('Close', Icons.close, Colors.red)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(String label, IconData icon, Color color) {
//     return ElevatedButton(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: EdgeInsets.symmetric(vertical: 12.h),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         elevation: 3,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 16.sp),
//           SizedBox(width: 6.w),
//           Text(
//             label,
//             style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _fromDateController.dispose();
//     _toDateController.dispose();
//     super.dispose();
//   }
// }
//
// class Employee {
//   final String id;
//   final String name;
//   Employee({required this.id, required this.name});
// }
//
// class ShiftDate {
//   final String date;
//   final String day;
//   ShiftDate({required this.date, required this.day});
// }
