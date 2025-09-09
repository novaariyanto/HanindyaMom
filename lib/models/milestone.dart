class Milestone {
  final String id;
  final String babyId;
  final int month; // usia dalam bulan target milestone
  final String title;
  final String description;
  final bool achieved;
  final DateTime? achievedAt;

  Milestone({
    required this.id,
    required this.babyId,
    required this.month,
    required this.title,
    required this.description,
    this.achieved = false,
    this.achievedAt,
  });

  Milestone copyWith({
    bool? achieved,
    DateTime? achievedAt,
  }) => Milestone(
        id: id,
        babyId: babyId,
        month: month,
        title: title,
        description: description,
        achieved: achieved ?? this.achieved,
        achievedAt: achievedAt ?? this.achievedAt,
      );
}

class MilestoneTemplates {
  // Mock milestone per usia (contoh ringkas)
  static List<Milestone> generateForBaby(String babyId) {
    final data = <Map<String, dynamic>>[
      {'m': 6, 't': 'Duduk', 'd': 'Mulai bisa duduk tanpa bantuan.'},
      {'m': 9, 't': 'Merangkak', 'd': 'Mulai merangkak menjelajah.'},
      {'m': 12, 't': 'Berjalan', 'd': 'Mulai berjalan beberapa langkah.'},
      {'m': 24, 't': 'Kata Dua Suku', 'd': 'Mampu menyusun 2 kata.'},
      {'m': 36, 't': 'Bicara Jelas', 'd': 'Menyebut nama benda dan warna.'},
      {'m': 48, 't': 'Motorik Halus', 'd': 'Menggambar garis sederhana.'},
      {'m': 60, 't': 'Hitung Sederhana', 'd': 'Menghitung 1-10.'},
      {'m': 72, 't': 'Koordinasi Baik', 'd': 'Melompat, berlari, melempar.'},
    ];
    return data
        .map((e) => Milestone(
              id: '${e['m']}_${e['t']}',
              babyId: babyId,
              month: e['m'],
              title: e['t'],
              description: e['d'],
            ))
        .toList();
  }
}
