class Sleep {
  final String id;
  final String babyId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  Sleep({
    required this.id,
    required this.babyId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  Duration get duration => endTime.difference(startTime);

  String get durationString {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory Sleep.fromJson(Map<String, dynamic> json) {
    return Sleep(
      id: json['id'],
      babyId: json['babyId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      notes: json['notes'],
    );
  }
}
