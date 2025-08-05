class EmployeeMenuItemModel {
  final String micode;
  final String menuName;
  final String moduleName;

  EmployeeMenuItemModel({
    required this.micode,
    required this.menuName,
    required this.moduleName,
  });

  factory EmployeeMenuItemModel.fromJson(Map<String, dynamic> json) {
    final rawMdname = json['mdname'] ?? '';
    String cleanedModuleName = _cleanMdname(rawMdname);

    if (cleanedModuleName == 'Other Request') {
      cleanedModuleName = 'other_requests';
    }

    return EmployeeMenuItemModel(
      micode: json['micode'] ?? '',
      menuName: json['miname'] ?? '',
      moduleName: cleanedModuleName,
    );
  }

  static String _cleanMdname(String rawMdname) {
    final cleaned = rawMdname.replaceAll(RegExp(r'<i[^>]*>.*?<\/i>'), '');
    return cleaned.trim();
  }
}

class EmployeeMenuModel {
  final Map<String, List<EmployeeMenuItemModel>> selfService;
  final Map<String, List<EmployeeMenuItemModel>> lineManager;

  EmployeeMenuModel({required this.selfService, required this.lineManager});

  factory EmployeeMenuModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'];
    final List<dynamic> selfList = data[0];
    final List<dynamic> lineList = data[1];

    return EmployeeMenuModel(
      selfService: _groupByMdname(selfList),
      lineManager: _groupByMdname(lineList),
    );
  }

  static Map<String, List<EmployeeMenuItemModel>> _groupByMdname(
    List<dynamic> items,
  ) {
    final Map<String, List<EmployeeMenuItemModel>> grouped = {};

    for (var item in items) {
      final menuItem = EmployeeMenuItemModel.fromJson(item);
      final key = menuItem.moduleName;

      grouped.putIfAbsent(key, () => []).add(menuItem);
    }

    // Move 'other_requests' to the end
    if (grouped.containsKey('other_requests')) {
      final otherRequests = grouped.remove('other_requests');
      grouped['other_requests'] = otherRequests!;
    }

    return grouped;
  }

  static String _cleanMdname(String rawMdname) {
    final cleaned = rawMdname.replaceAll(RegExp(r'<i[^>]*>.*?<\/i>'), '');
    return cleaned.trim();
  }
}
