class OfficerHistoryItem {
  const OfficerHistoryItem({
    required this.type,
    required this.date,
    this.licensePlate,
    this.violationName,
    this.amount,
    this.status,
    this.reason,
    this.photoUrl,
    this.latitude,
    this.longitude,
  });

  final String type;
  final DateTime? date;
  final String? licensePlate;
  final String? violationName;
  final double? amount;
  final String? status;
  final String? reason;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;

  bool get isFine => type.toLowerCase() == 'fine';
  bool get isClamp => type.toLowerCase() == 'clamp';

  String get displayTitle {
    if (isFine) {
      return violationName == null || violationName!.trim().isEmpty
          ? 'مخالفة'
          : 'مخالفة: $violationName';
    }

    if (isClamp) {
      return status?.toLowerCase() == 'unclamped'
          ? 'إزالة كلبشة'
          : 'كلبشة مركبة';
    }

    return 'نشاط';
  }

  String get displaySubtitle {
    final parts = <String>[];

    if (licensePlate != null && licensePlate!.trim().isNotEmpty) {
      parts.add('اللوحة: $licensePlate');
    }

    if (isFine && amount != null) {
      parts.add(
        'القيمة: ${amount!.toStringAsFixed(amount! % 1 == 0 ? 0 : 2)} شيكل',
      );
    }

    if (isClamp && localizedReason.trim().isNotEmpty) {
      parts.add(localizedReason);
    }

    if (parts.isEmpty) {
      return 'لا توجد تفاصيل إضافية';
    }

    return parts.join(' • ');
  }

  String get localizedReason {
    final text = (reason ?? '').trim();
    if (text.isEmpty) return '';

    switch (text.toLowerCase()) {
      case 'vehicle not registered in the system':
        return 'المركبة غير مسجلة في النظام';
      case 'not registered':
        return 'المركبة غير مسجلة';
      default:
        return text;
    }
  }

  factory OfficerHistoryItem.fromJson(Map<String, dynamic> json) {
    return OfficerHistoryItem(
      type: (json['type'] ?? '').toString(),
      date: json['date'] == null
          ? null
          : DateTime.tryParse(json['date'].toString()),
      licensePlate: json['license_plate']?.toString(),
      violationName: json['violation_name']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      reason: json['reason']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
    );
  }
}
