class DriverVehicle {
  const DriverVehicle({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.isDefault,
    this.color,
  });

  final int id;
  final String plateNumber;
  final String vehicleType;
  final String? color;
  final bool isDefault;

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      id: json['id'] as int,
      plateNumber: (json['license_plate'] ?? '') as String,
      vehicleType: (json['vehicle_type'] ?? '') as String,
      color: json['color'] as String?,
      isDefault: (json['is_default'] ?? false) as bool,
    );
  }
}
