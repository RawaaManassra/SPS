class OfficerVehicleCheckResult {
  const OfficerVehicleCheckResult({
    this.status,
    this.message,
    required this.licensePlate,
    this.vehicleId,
    this.vehicleType,
    this.color,
    this.clampedCount,
    this.startTime,
    this.expiryTime,
    this.timeRemaining,
    this.latitude,
    this.longitude,
  });

  final String? status;
  final String? message;
  final String licensePlate;
  final int? vehicleId;
  final String? vehicleType;
  final String? color;
  final int? clampedCount;
  final DateTime? startTime;
  final DateTime? expiryTime;
  final String? timeRemaining;
  final double? latitude;
  final double? longitude;

  String get _normalizedStatus {
    final raw = '${status ?? ''} ${message ?? ''}'.toLowerCase().trim();
    return raw;
  }

  bool get isActive => status?.toLowerCase() == 'active';
  bool get isUnregistered =>
      _normalizedStatus.contains('unregistered') ||
      _normalizedStatus.contains('unrigestred') ||
      _normalizedStatus.contains('not registered');
  bool get isCurrentlyClamped {
    if (_normalizedStatus.contains('unclamped')) {
      return false;
    }
    if (_normalizedStatus.contains('clamped')) {
      return true;
    }
    return isUnregistered && (clampedCount ?? 0) > 0;
  }
  bool get hasNoActiveSession =>
      _normalizedStatus.contains('no active session');
  bool get isRegistered => vehicleId != null;

  factory OfficerVehicleCheckResult.fromJson(Map<String, dynamic> json) {
    return OfficerVehicleCheckResult(
      status: json['status'] as String?,
      message: json['message'] as String?,
      licensePlate: (json['license_plate'] ?? '') as String,
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      vehicleType: json['vehicle_type'] as String?,
      color: json['color'] as String?,
      clampedCount: (json['clamped_count'] as num?)?.toInt(),
      startTime: json['start_time'] == null
          ? null
          : DateTime.tryParse(json['start_time'] as String),
      expiryTime: json['expiry_time'] == null
          ? null
          : DateTime.tryParse(json['expiry_time'] as String),
      timeRemaining: json['time_remaining'] as String?,
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
    );
  }

  OfficerVehicleCheckResult copyWith({
    String? status,
    String? message,
    String? licensePlate,
    int? vehicleId,
    String? vehicleType,
    String? color,
    int? clampedCount,
    DateTime? startTime,
    DateTime? expiryTime,
    String? timeRemaining,
    double? latitude,
    double? longitude,
  }) {
    return OfficerVehicleCheckResult(
      status: status ?? this.status,
      message: message ?? this.message,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      color: color ?? this.color,
      clampedCount: clampedCount ?? this.clampedCount,
      startTime: startTime ?? this.startTime,
      expiryTime: expiryTime ?? this.expiryTime,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
