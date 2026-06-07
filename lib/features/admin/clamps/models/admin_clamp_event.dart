class AdminClampEvent {
  const AdminClampEvent({
    required this.id,
    this.userId,
    this.vehicleId,
    this.unregisteredVehicleId,
    required this.inspectorId,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.photoUrl,
    this.reason,
    this.clampedAt,
    this.unclampedAt,
  });

  final int id;
  final int? userId;
  final int? vehicleId;
  final int? unregisteredVehicleId;
  final int inspectorId;
  final double latitude;
  final double longitude;
  final String status;
  final String? photoUrl;
  final String? reason;
  final DateTime? clampedAt;
  final DateTime? unclampedAt;

  factory AdminClampEvent.fromJson(Map<String, dynamic> json) {
    return AdminClampEvent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      unregisteredVehicleId:
          (json['unregistered_vehicle_id'] as num?)?.toInt(),
      inspectorId: (json['inspector_id'] as num?)?.toInt() ?? 0,
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lng'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? '').toString(),
      photoUrl: json['photo_url']?.toString(),
      reason: json['reason']?.toString(),
      clampedAt: json['clamped_at'] == null
          ? null
          : DateTime.tryParse(json['clamped_at'].toString()),
      unclampedAt: json['unclamped_at'] == null
          ? null
          : DateTime.tryParse(json['unclamped_at'].toString()),
    );
  }
}
