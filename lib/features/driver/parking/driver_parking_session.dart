import 'package:flut/features/driver/vehicles/models/driver_vehicle.dart';

class DriverParkingSession {
  const DriverParkingSession({
    required this.vehicleId,
    required this.vehiclePlateNumber,
    required this.vehicleModel,
    required this.locationLabel,
    required this.paymentMethodLabel,
    required this.durationMinutes,
    required this.totalPrice,
    required this.startedAt,
    required this.endsAt,
  });

  final int vehicleId;
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

  factory DriverParkingSession.fromBackendJson(
    Map<String, dynamic> json, {
    required DriverVehicle vehicle,
  }) {
    final startedAt = _parseBackendDateTime(json['start_time']) ?? DateTime.now();
    final endsAt = _parseBackendDateTime(json['expiry_time']) ?? DateTime.now();
    final rawDurationMinutes = endsAt.difference(startedAt).inMinutes;
    final durationMinutes = rawDurationMinutes < 0 ? 0 : rawDurationMinutes;

    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();

    return DriverParkingSession(
      vehicleId: vehicle.id,
      vehiclePlateNumber: vehicle.plateNumber,
      vehicleModel: vehicle.vehicleType,
      locationLabel: _locationLabelForCoordinates(lat, lng),
      paymentMethodLabel: 'المحفظة',
      durationMinutes: durationMinutes,
      totalPrice: (json['amount_paid'] as num?)?.toInt() ?? 0,
      startedAt: startedAt,
      endsAt: endsAt,
    );
  }

  DriverParkingSession copyWith({
    int? vehicleId,
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
      vehicleId: vehicleId ?? this.vehicleId,
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

  static String _locationLabelForCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return 'موقع غير محدد';
    }

    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  static DateTime? _parseBackendDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;

    if (raw.endsWith('Z') || raw.contains('+')) {
      return parsed.toLocal();
    }

    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).toLocal();
  }
}
