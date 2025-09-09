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
