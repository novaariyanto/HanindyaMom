class NutritionEntry {
  final String id;
  final String babyId;
  final DateTime time;
  final String title; // nama menu
  final String? photoPath;
  final String? notes;

  NutritionEntry({
    required this.id,
    required this.babyId,
    required this.time,
    required this.title,
    this.photoPath,
    this.notes,
  });

  factory NutritionEntry.fromJson(Map<String, dynamic> j) => NutritionEntry(
        id: (j['id'] ?? '').toString(),
        babyId: j['baby_id'] as String,
        time: DateTime.tryParse(j['time'] as String) ?? DateTime.now(),
        title: j['title'] as String,
        photoPath: (j['photo_path'] ?? j['photo']) as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'baby_id': babyId,
        'time': time.toIso8601String(),
        'title': title,
        if (photoPath != null) 'photo_path': photoPath,
        if (notes != null) 'notes': notes,
      };
}

class NutritionRecommendations {
  static List<String> forAgeMonths(int months) {
    if (months < 6) {
      return ['ASI eksklusif'];
    } else if (months < 12) {
      return ['MPASI: bubur saring, pure sayur', 'Protein: ayam, telur, ikan'];
    } else if (months < 36) {
      return ['Makanan keluarga lunak', 'Buah & sayur bervariasi'];
    } else {
      return ['Makanan keluarga seimbang', 'Batasi gula & garam'];
    }
  }
}
