class GrowthRecord {
  final String id;
  final String babyId;
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double? headCircumferenceCm;

  GrowthRecord({
    required this.id,
    required this.babyId,
    required this.date,
    required this.weightKg,
    required this.heightCm,
    this.headCircumferenceCm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'headCircumferenceCm': headCircumferenceCm,
      };

  factory GrowthRecord.fromJson(Map<String, dynamic> json) => GrowthRecord(
        id: json['id'],
        babyId: json['babyId'],
        date: DateTime.parse(json['date']),
        weightKg: (json['weightKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
        headCircumferenceCm: json['headCircumferenceCm'] != null
            ? (json['headCircumferenceCm'] as num).toDouble()
            : null,
      );
}

enum WhoStatus { normal, underweight, overweight }

class GrowthUtils {
  // NOTE: Ini mock sederhana. Untuk akurasi, gunakan kurva WHO referensi.
  static WhoStatus classifyByBmi({required double weightKg, required double heightCm}) {
    final h = heightCm / 100.0;
    final bmi = weightKg / (h * h);
    if (bmi < 14) return WhoStatus.underweight; // mock threshold anak
    if (bmi > 19) return WhoStatus.overweight; // mock threshold anak
    return WhoStatus.normal;
  }

  static String statusText(WhoStatus status) {
    switch (status) {
      case WhoStatus.normal:
        return 'Normal';
      case WhoStatus.underweight:
        return 'Underweight';
      case WhoStatus.overweight:
        return 'Overweight';
    }
  }
}
