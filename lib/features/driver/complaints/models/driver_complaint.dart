class DriverComplaint {
  const DriverComplaint({
    required this.id,
    required this.userId,
    required this.complaintType,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String complaintType;
  final String? description;
  final String status;
  final DateTime? createdAt;

  factory DriverComplaint.fromJson(Map<String, dynamic> json) {
    return DriverComplaint(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      complaintType: (json['complaint_type'] ?? '') as String,
      description: json['description'] as String?,
      status: (json['status'] ?? '') as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }
}
