class AdminFine {
  const AdminFine({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.inspectorId,
    required this.violationTypeId,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.finedAt,
  });

  final int id;
  final int userId;
  final int vehicleId;
  final int inspectorId;
  final int violationTypeId;
  final String status;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final DateTime? finedAt;

  factory AdminFine.fromJson(Map<String, dynamic> json) {
    return AdminFine(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? 0,
      inspectorId: (json['inspector_id'] as num?)?.toInt() ?? 0,
      violationTypeId: (json['violation_type_id'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lng'] as num?)?.toDouble() ?? 0,
      photoUrl: json['photo_url']?.toString(),
      finedAt: json['fined_at'] == null
          ? null
          : DateTime.tryParse(json['fined_at'].toString()),
    );
  }
}
