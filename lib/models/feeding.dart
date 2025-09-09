enum FeedingType {
  breastLeft('ASI Kiri'),
  breastRight('ASI Kanan'),
  formula('Formula'),
  pump('Pompa');

  const FeedingType(this.displayName);
  final String displayName;
}

class Feeding {
  final String id;
  final String babyId;
  final FeedingType type;
  final DateTime startTime;
  final int durationMinutes;
  final String? notes;
  final double? amount; // dalam ml untuk formula

  Feeding({
    required this.id,
    required this.babyId,
    required this.type,
    required this.startTime,
    required this.durationMinutes,
    this.notes,
    this.amount,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  String get durationString {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'amount': amount,
    };
  }

  factory Feeding.fromJson(Map<String, dynamic> json) {
    return Feeding(
      id: json['id'],
      babyId: json['babyId'],
      type: FeedingType.values.firstWhere((e) => e.name == json['type']),
      startTime: DateTime.parse(json['startTime']),
      durationMinutes: json['durationMinutes'],
      notes: json['notes'],
      amount: json['amount']?.toDouble(),
    );
  }
}
