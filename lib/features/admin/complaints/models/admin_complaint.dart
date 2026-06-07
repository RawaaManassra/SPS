class AdminComplaint {
  const AdminComplaint({
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

  factory AdminComplaint.fromJson(Map<String, dynamic> json) {
    return AdminComplaint(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      complaintType: (json['complaint_type'] ?? '').toString(),
      description: json['description']?.toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
