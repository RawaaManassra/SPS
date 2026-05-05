class DriverParkingSession {
  const DriverParkingSession({
    required this.vehiclePlateNumber,
    required this.vehicleModel,
    required this.locationLabel,
    required this.paymentMethodLabel,
    required this.durationMinutes,
    required this.totalPrice,
    required this.startedAt,
    required this.endsAt,
  });

  final String vehiclePlateNumber;
  final String vehicleModel;
  final String locationLabel;
  final String paymentMethodLabel;
  final int durationMinutes;
  final int totalPrice;
  final DateTime startedAt;
  final DateTime endsAt;

  int get remainingMinutes {
    final difference = endsAt.difference(DateTime.now()).inMinutes;
    return difference < 0 ? 0 : difference;
  }

  DriverParkingSession copyWith({
    String? vehiclePlateNumber,
    String? vehicleModel,
    String? locationLabel,
    String? paymentMethodLabel,
    int? durationMinutes,
    int? totalPrice,
    DateTime? startedAt,
    DateTime? endsAt,
  }) {
    return DriverParkingSession(
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      locationLabel: locationLabel ?? this.locationLabel,
      paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalPrice: totalPrice ?? this.totalPrice,
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
    );
  }
}
