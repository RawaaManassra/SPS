class AdminAddInspectorRequest {
  const AdminAddInspectorRequest({
    required this.username,
    required this.fullName,
    required this.nationalId,
    required this.phoneNumber,
    required this.password,
    this.email,
  });

  final String username;
  final String fullName;
  final String nationalId;
  final String phoneNumber;
  final String password;
  final String? email;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'national_id': nationalId,
      'phone_number': phoneNumber,
      'password': password,
      'email': email == null || email!.trim().isEmpty ? null : email!.trim(),
    };
  }
}
