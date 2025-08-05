class MainMenuModel {
  final bool showCheckInOut;
  final bool selfService;
  final bool lineManager;
  final List<String> quickActions;

  MainMenuModel({
    required this.showCheckInOut,
    required this.selfService,
    required this.lineManager,
    required this.quickActions,
  });

  factory MainMenuModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;

    // 1. Check-in/out status
    String checkInOutRaw = 'False';
    if (data.isNotEmpty && data[0] is List && (data[0] as List).isNotEmpty) {
      checkInOutRaw = data[0][0]['Status']?.toString() ?? 'False';
    }
    final showCheckInOut = checkInOutRaw.toLowerCase() == 'true';
    // 2. Quick Actions (miname list)
    final quickActionsList =
        (data[1] as List<dynamic>)
            .map((item) => item['miname'].toString())
            .toList();

    // 3. Determine if selfService or lineManager exists
    bool selfService = false;
    bool lineManager = false;
    final menuList = data[2] as List<dynamic>;
    for (var item in menuList) {
      final name = item['miname'].toString().toLowerCase();
      if (name.contains('self service')) selfService = true;
      if (name.contains('approval')) lineManager = true;
    }

    return MainMenuModel(
      showCheckInOut: showCheckInOut,
      selfService: selfService,
      lineManager: lineManager,
      quickActions: quickActionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkInOut': showCheckInOut,
      'selfService': selfService,
      'lineManager': lineManager,
      'quickActions': quickActions,
    };
  }
}
