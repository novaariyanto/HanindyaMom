class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? photoPath;
  final double? weight; // dalam kg (terakhir tercatat)
  final double? height; // dalam cm (terakhir tercatat)
  final String? gender; // 'male' atau 'female'

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.photoPath,
    this.weight,
    this.height,
    this.gender,
  });

  // Hitung umur dalam bulan dan hari
  String get ageString {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final totalDays = difference.inDays;
    final months = (totalDays / 30.44).floor(); // rata-rata hari per bulan
    final days = totalDays % 30;

    if (months == 0) {
      return '$totalDays hari';
    } else if (months < 12) {
      return '$months bulan ${days > 0 ? '$days hari' : ''}';
    } else {
      final years = (months / 12).floor();
      final remainingMonths = months % 12;
      return '$years tahun ${remainingMonths > 0 ? '$remainingMonths bulan' : ''}';
    }
  }

  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months -= 1;
    return months;
  }

  bool get isAge0To6Years => ageInMonths >= 0 && ageInMonths <= 72;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'photoPath': photoPath,
      'weight': weight,
      'height': height,
      'gender': gender,
    };
  }

  // Create from JSON
  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      photoPath: json['photoPath'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      gender: json['gender'],
    );
  }

  // Copy with
  Baby copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? photoPath,
    double? weight,
    double? height,
    String? gender,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
    );
  }
}
