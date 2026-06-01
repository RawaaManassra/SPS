class OfficerUserProfile {
  const OfficerUserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.nationalId,
    required this.phoneNumber,
    required this.email,
  });

  final int id;
  final String username;
  final String fullName;
  final String nationalId;
  final String phoneNumber;
  final String? email;

  factory OfficerUserProfile.fromJson(Map<String, dynamic> json) {
    return OfficerUserProfile(
      id: json['id'] as int,
      username: (json['username'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      nationalId: (json['national_id'] ?? '') as String,
      phoneNumber: (json['phone_number'] ?? '') as String,
      email: json['email'] as String?,
    );
  }
}
