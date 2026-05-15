class DriverWallet {
  const DriverWallet({
    required this.id,
    required this.userId,
    required this.balance,
  });

  final int id;
  final int userId;
  final double balance;

  factory DriverWallet.fromJson(Map<String, dynamic> json) {
    final rawBalance = json['balance'];
    return DriverWallet(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      balance: rawBalance is int
          ? rawBalance.toDouble()
          : (rawBalance as num?)?.toDouble() ?? 0,
    );
  }
}
