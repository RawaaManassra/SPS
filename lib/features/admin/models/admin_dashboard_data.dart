class AdminDashboardData {
  const AdminDashboardData({
    required this.activeSessionsCount,
    required this.clampEventsCount,
    required this.finesCount,
    required this.dailyRevenue,
    required this.inspectors,
  });

  final int activeSessionsCount;
  final int clampEventsCount;
  final int finesCount;
  final double dailyRevenue;
  final List<AdminInspectorPerformance> inspectors;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final inspectorsJson = json['inspectors'];

    return AdminDashboardData(
      activeSessionsCount: _readInt(json['active_sessions_count']),
      clampEventsCount: _readInt(json['clamp_events_count']),
      finesCount: _readInt(json['fines_count']),
      dailyRevenue: _readDouble(json['daily_revenue']),
      inspectors: inspectorsJson is List
          ? inspectorsJson
              .whereType<Map<String, dynamic>>()
              .map(AdminInspectorPerformance.fromJson)
              .toList()
          : const [],
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminInspectorPerformance {
  const AdminInspectorPerformance({
    required this.inspectorName,
    required this.finesCount,
    required this.clampsCount,
  });

  final String inspectorName;
  final int finesCount;
  final int clampsCount;

  int get totalActions => finesCount + clampsCount;

  factory AdminInspectorPerformance.fromJson(Map<String, dynamic> json) {
    return AdminInspectorPerformance(
      inspectorName: (json['inspector_name'] ?? 'مفتش غير محدد').toString(),
      finesCount: _readInt(json['fines_count']),
      clampsCount: _readInt(json['clamps_count']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
