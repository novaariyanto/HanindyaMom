class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  ApiResponse({required this.success, this.message, this.data});
}

class BabyApiModel {
  final String id;
  final String name;
  final String birthDate; // yyyy-mm-dd
  final String? photo;
  final String? birthWeight;
  final String? birthHeight;
  BabyApiModel({
    required this.id,
    required this.name,
    required this.birthDate,
    this.photo,
    this.birthWeight,
    this.birthHeight,
  });
  factory BabyApiModel.fromJson(Map<String, dynamic> j) => BabyApiModel(
        id: j['id'] as String,
        name: j['name'] as String,
        birthDate: j['birth_date'] as String,
        photo: j['photo'] as String?,
        birthWeight: (j['birth_weight'] as String),
        birthHeight: (j['birth_height'] as String),
      );
}

class FeedingLogApiModel {
  final String id;
  final String babyId;
  final String type;
  final String startTime; // iso8601
  final int durationMinutes;
  final String? notes;
  FeedingLogApiModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.startTime,
    required this.durationMinutes,
    this.notes,
  });
  factory FeedingLogApiModel.fromJson(Map<String, dynamic> j) => FeedingLogApiModel(
        id: j['id'] as String,
        babyId: j['baby_id'] as String,
        type: j['type'] as String,
        startTime: j['start_time'] as String,
        durationMinutes: j['duration_minutes'] as int,
        notes: j['notes'] as String?,
      );
}

class DiaperLogApiModel {
  final String id;
  final String babyId;
  final String type;
  final String time;
  final String? color;
  final String? texture;
  final String? notes;
  DiaperLogApiModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.time,
    this.color,
    this.texture,
    this.notes,
  });
  factory DiaperLogApiModel.fromJson(Map<String, dynamic> j) => DiaperLogApiModel(
        id: j['id'] as String,
        babyId: j['baby_id'] as String,
        type: j['type'] as String,
        time: j['time'] as String,
        color: j['color'] as String?,
        texture: j['texture'] as String?,
        notes: j['notes'] as String?,
      );
}

class SleepLogApiModel {
  final String id;
  final String babyId;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String? notes;
  SleepLogApiModel({
    required this.id,
    required this.babyId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.notes,
  });
  factory SleepLogApiModel.fromJson(Map<String, dynamic> j) => SleepLogApiModel(
        id: j['id'] as String,
        babyId: j['baby_id'] as String,
        startTime: j['start_time'] as String,
        endTime: j['end_time'] as String,
        durationMinutes: j['duration_minutes'] as int,
        notes: j['notes'] as String?,
      );
}

class GrowthLogApiModel {
  final String id;
  final String babyId;
  final String date; // yyyy-mm-dd
  final double weight;
  final double height;
  final double? headCircumference;
  GrowthLogApiModel({
    required this.id,
    required this.babyId,
    required this.date,
    required this.weight,
    required this.height,
    this.headCircumference,
  });
  factory GrowthLogApiModel.fromJson(Map<String, dynamic> j) => GrowthLogApiModel(
        id: j['id'] as String,
        babyId: j['baby_id'] as String,
        date: j['date'] as String,
        weight: (j['weight'] as num).toDouble(),
        height: (j['height'] as num).toDouble(),
        headCircumference: (j['head_circumference'] as num?)?.toDouble(),
      );
}

class VaccineScheduleApiModel {
  final String id;
  final String babyId;
  final String vaccineName;
  final String scheduleDate;
  final String status;
  final String? notes;
  VaccineScheduleApiModel({
    required this.id,
    required this.babyId,
    required this.vaccineName,
    required this.scheduleDate,
    required this.status,
    this.notes,
  });
  factory VaccineScheduleApiModel.fromJson(Map<String, dynamic> j) => VaccineScheduleApiModel(
        id: j['id'] as String,
        babyId: j['baby_id'] as String,
        vaccineName: j['vaccine_name'] as String,
        scheduleDate: j['schedule_date'] as String,
        status: j['status'] as String,
        notes: j['notes'] as String?,
      );
}

class SettingsApiModel {
  final String id;
  final String timezone;
  final String unit;
  final bool notifications;
  SettingsApiModel({
    required this.id,
    required this.timezone,
    required this.unit,
    required this.notifications,
  });
  factory SettingsApiModel.fromJson(Map<String, dynamic> j) => SettingsApiModel(
        id: j['id'] as String,
        timezone: j['timezone'] as String,
        unit: j['unit'] as String,
        notifications: j['notifications'] as bool,
      );
}
