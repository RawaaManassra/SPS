class DriverFine {
  const DriverFine({
    required this.id,
    required this.status,
    required this.finedAt,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.licensePlate,
    required this.violationName,
    required this.amount,
  });

  final int id;
  final String status;
  final DateTime? finedAt;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String licensePlate;
  final String violationName;
  final int amount;

  bool get isPaid => status.toLowerCase() == 'paid';

  factory DriverFine.fromJson(Map<String, dynamic> json) {
    return DriverFine(
      id: json['id'] as int,
      status: (json['status'] ?? '') as String,
      finedAt: json['fined_at'] == null
          ? null
          : DateTime.tryParse(json['fined_at'] as String),
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      licensePlate: (json['license_plate'] ?? 'غير معروف') as String,
      violationName: (json['violation_name'] ?? 'مخالفة مرورية') as String,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }

  DriverFine copyWith({
    String? status,
  }) {
    return DriverFine(
      id: id,
      status: status ?? this.status,
      finedAt: finedAt,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
      licensePlate: licensePlate,
      violationName: violationName,
      amount: amount,
    );
  }
}
