class AdminViolationType {
  const AdminViolationType({
    required this.id,
    required this.name,
    required this.amount,
  });

  final int id;
  final String name;
  final double amount;

  factory AdminViolationType.fromJson(Map<String, dynamic> json) {
    return AdminViolationType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
