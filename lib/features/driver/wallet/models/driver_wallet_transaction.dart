class DriverWalletTransaction {
  const DriverWalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.transactionType,
    required this.createdAt,
    this.sessionId,
  });

  final int id;
  final int userId;
  final int amount;
  final int? sessionId;
  final String transactionType;
  final DateTime? createdAt;

  factory DriverWalletTransaction.fromJson(Map<String, dynamic> json) {
    return DriverWalletTransaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      amount: json['amount'] as int,
      sessionId: json['session_id'] as int?,
      transactionType: (json['transaction_type'] ?? '') as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }
}
