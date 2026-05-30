class DriverMapData {
  const DriverMapData({
    required this.activeSessions,
    required this.clampedVehicles,
  });

  final List<DriverMapActiveSession> activeSessions;
  final List<DriverMapClampedVehicle> clampedVehicles;

  bool get isEmpty => activeSessions.isEmpty && clampedVehicles.isEmpty;

  factory DriverMapData.fromJson(Map<String, dynamic> json) {
    final activeSessionsJson = json['active_sessions'] as List<dynamic>? ?? const [];
    final clampedVehiclesJson = json['clamped_vehicles'] as List<dynamic>? ?? const [];

    return DriverMapData(
      activeSessions: activeSessionsJson
          .map(
            (item) => DriverMapActiveSession.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      clampedVehicles: clampedVehiclesJson
          .map(
            (item) => DriverMapClampedVehicle.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class DriverMapActiveSession {
  const DriverMapActiveSession({
    required this.lat,
    required this.lng,
    required this.vehicleId,
    required this.expiryTime,
  });

  final double lat;
  final double lng;
  final int vehicleId;
  final DateTime? expiryTime;

  factory DriverMapActiveSession.fromJson(Map<String, dynamic> json) {
    return DriverMapActiveSession(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      vehicleId: json['vehicle_id'] as int? ?? 0,
      expiryTime: DateTime.tryParse(json['expiry_time']?.toString() ?? ''),
    );
  }
}

class DriverMapClampedVehicle {
  const DriverMapClampedVehicle({
    required this.lat,
    required this.lng,
    required this.unregisteredVehicleId,
    required this.clampedAt,
  });

  final double lat;
  final double lng;
  final int unregisteredVehicleId;
  final DateTime? clampedAt;

  factory DriverMapClampedVehicle.fromJson(Map<String, dynamic> json) {
    return DriverMapClampedVehicle(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      unregisteredVehicleId: json['unregistered_vehicle_id'] as int? ?? 0,
      clampedAt: DateTime.tryParse(json['clamped_at']?.toString() ?? ''),
    );
  }
}
