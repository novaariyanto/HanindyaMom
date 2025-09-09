class ActivityTip {
  final String id;
  final int minMonth; // umur minimum (bulan)
  final int maxMonth; // umur maksimum (bulan)
  final String title;
  final String description;

  ActivityTip({
    required this.id,
    required this.minMonth,
    required this.maxMonth,
    required this.title,
    required this.description,
  });
}

class ActivityTipsRepo {
  static List<ActivityTip> list() {
    return [
      ActivityTip(id: 'tummy_time', minMonth: 0, maxMonth: 6, title: 'Tummy Time', description: 'Perkuat otot leher dan punggung.'),
      ActivityTip(id: 'warna', minMonth: 24, maxMonth: 48, title: 'Permainan Warna', description: 'Kenalkan warna melalui permainan.'),
      ActivityTip(id: 'balok', minMonth: 36, maxMonth: 72, title: 'Balok Susun', description: 'Melatih motorik halus dan imajinasi.'),
    ];
  }

  static List<ActivityTip> forAgeMonths(int months) {
    return list().where((t) => months >= t.minMonth && months <= t.maxMonth).toList();
  }
}
