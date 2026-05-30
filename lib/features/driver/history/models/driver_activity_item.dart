class DriverActivityItem {
  const DriverActivityItem({
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
    required this.details,
  });

  final String type;
  final DateTime? date;
  final num? amount;
  final String status;
  final Map<String, dynamic> details;

  factory DriverActivityItem.fromJson(Map<String, dynamic> json) {
    return DriverActivityItem(
      type: (json['type'] ?? '') as String,
      date: json['date'] == null ? null : DateTime.tryParse(json['date'] as String),
      amount: json['amount'] as num?,
      status: (json['status'] ?? '') as String,
      details: (json['details'] as Map<String, dynamic>?) ?? const {},
    );
  }

  bool get isSession => type == 'session';
  bool get isFine => type == 'fine';
  bool get isTransaction => type == 'transaction';

  String? get licensePlate => details['license_plate'] as String?;
  int? get durationMinutes => (details['duration_minutes'] as num?)?.toInt();
  double? get latitude => (details['lat'] as num?)?.toDouble();
  double? get longitude => (details['lng'] as num?)?.toDouble();
  String? get violationName => details['violation_name'] as String?;
  String? get photoUrl => details['photo_url'] as String?;
  String? get transactionType => details['transaction_type'] as String?;
}
