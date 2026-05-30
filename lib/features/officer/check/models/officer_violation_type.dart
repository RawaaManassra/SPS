class OfficerViolationType {
  const OfficerViolationType({
    required this.id,
    required this.name,
    required this.amount,
  });

  final int id;
  final String name;
  final double amount;

  factory OfficerViolationType.fromJson(Map<String, dynamic> json) {
    return OfficerViolationType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
