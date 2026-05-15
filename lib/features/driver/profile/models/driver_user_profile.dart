class DriverUserProfile {
  const DriverUserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.nationalId,
    required this.phoneNumber,
    required this.email,
    required this.drivingLicenceId,
  });

  final int id;
  final String username;
  final String fullName;
  final String nationalId;
  final String phoneNumber;
  final String? email;
  final String? drivingLicenceId;

  factory DriverUserProfile.fromJson(Map<String, dynamic> json) {
    return DriverUserProfile(
      id: json['id'] as int,
      username: (json['username'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      nationalId: (json['national_id'] ?? '') as String,
      phoneNumber: (json['phone_number'] ?? '') as String,
      email: json['email'] as String?,
      drivingLicenceId: json['driving_licence_id'] as String?,
    );
  }

  DriverUserProfile copyWith({
    String? username,
    String? fullName,
    String? nationalId,
    String? phoneNumber,
    String? email,
    String? drivingLicenceId,
  }) {
    return DriverUserProfile(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      drivingLicenceId: drivingLicenceId ?? this.drivingLicenceId,
    );
  }
}
