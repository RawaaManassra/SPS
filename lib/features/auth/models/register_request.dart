class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.fullName,
    required this.nationalId,
    required this.drivingLicenceId,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    this.email,
  });

  final String username;
  final String fullName;
  final String nationalId;
  final String drivingLicenceId;
  final String phoneNumber;
  final String? email;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'national_id': nationalId,
      'driving_licence_id': drivingLicenceId,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }
}
