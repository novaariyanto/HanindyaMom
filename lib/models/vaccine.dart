class Vaccine {
  final String id;
  final String name;
  final int recommendedMonth; // usia disarankan (bulan)
  final String description;

  Vaccine({
    required this.id,
    required this.name,
    required this.recommendedMonth,
    required this.description,
  });
}

class VaccineScheduleIDAI {
  static List<Vaccine> list() {
    return [
      Vaccine(id: 'hep_b', name: 'Hepatitis B', recommendedMonth: 0, description: 'Dosis pertama saat lahir'),
      Vaccine(id: 'bcg', name: 'BCG', recommendedMonth: 1, description: 'Perlindungan terhadap TBC'),
      Vaccine(id: 'polio', name: 'Polio', recommendedMonth: 2, description: 'Beberapa dosis bertahap'),
      Vaccine(id: 'dpt', name: 'DPT', recommendedMonth: 2, description: 'Difteri, Pertusis, Tetanus'),
      Vaccine(id: 'hib', name: 'Hib', recommendedMonth: 2, description: 'Haemophilus influenzae tipe b'),
      Vaccine(id: 'pcv', name: 'PCV', recommendedMonth: 2, description: 'Pneumokokus'),
      Vaccine(id: 'campak', name: 'Campak', recommendedMonth: 9, description: 'Campak / MR'),
    ];
  }
}
