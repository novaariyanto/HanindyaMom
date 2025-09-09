import 'package:flutter/material.dart';

enum ActivityType { feeding, diaper, sleep, growth, milestone, nutrition }

class TimelineActivity {
  final String id;
  final ActivityType type;
  final DateTime time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  TimelineActivity({
    required this.id,
    required this.type,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
