enum DiaperType {
  wet('Pipis'),
  dirty('Pup'),
  mixed('Campuran');

  const DiaperType(this.displayName);
  final String displayName;
}

enum DiaperColor {
  yellow('Kuning'),
  brown('Coklat'),
  green('Hijau'),
  black('Hitam'),
  other('Lainnya');

  const DiaperColor(this.displayName);
  final String displayName;
}

enum DiaperTexture {
  soft('Lembek'),
  firm('Padat'),
  watery('Cair'),
  normal('Normal');

  const DiaperTexture(this.displayName);
  final String displayName;
}

class Diaper {
  final String id;
  final String babyId;
  final DateTime changeTime;
  final DiaperType type;
  final DiaperColor? color;
  final DiaperTexture? texture;
  final String? notes;

  Diaper({
    required this.id,
    required this.babyId,
    required this.changeTime,
    required this.type,
    this.color,
    this.texture,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'changeTime': changeTime.toIso8601String(),
      'type': type.name,
      'color': color?.name,
      'texture': texture?.name,
      'notes': notes,
    };
  }

  factory Diaper.fromJson(Map<String, dynamic> json) {
    return Diaper(
      id: json['id'],
      babyId: json['babyId'],
      changeTime: DateTime.parse(json['changeTime']),
      type: DiaperType.values.firstWhere((e) => e.name == json['type']),
      color: json['color'] != null 
          ? DiaperColor.values.firstWhere((e) => e.name == json['color'])
          : null,
      texture: json['texture'] != null
          ? DiaperTexture.values.firstWhere((e) => e.name == json['texture'])
          : null,
      notes: json['notes'],
    );
  }
}
