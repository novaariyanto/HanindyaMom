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

class VaccineEntry {
  final String id;
  final String babyId;
  final String vaccineName;
  final String scheduleDate; // YYYY-MM-DD
  final String status; // 'scheduled' | 'done'
  final String? notes;

  VaccineEntry({
    required this.id,
    required this.babyId,
    required this.vaccineName,
    required this.scheduleDate,
    required this.status,
    this.notes,
  });

  factory VaccineEntry.fromJson(Map<String, dynamic> j) => VaccineEntry(
        id: (j['id'] ?? '').toString(),
        babyId: j['baby_id'] as String,
        vaccineName: j['vaccine_name'] as String,
        scheduleDate: j['schedule_date'] as String,
        status: j['status'] as String,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'baby_id': babyId,
        'vaccine_name': vaccineName,
        'schedule_date': scheduleDate,
        'status': status,
        if (notes != null) 'notes': notes,
      };
}
