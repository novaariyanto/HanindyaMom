import 'package:flutter/material.dart';
import 'package:hanindyamom/models/timeline.dart';

class TimelineRepository extends ChangeNotifier {
  final List<TimelineActivity> _items = [];

  List<TimelineActivity> get items => List.unmodifiable(_items);

  void add(TimelineActivity activity) {
    _items.add(activity);
    _items.sort((a, b) => b.time.compareTo(a.time));
    notifyListeners();
  }

  void removeById(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void seedMock() {
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    _items.addAll([
      TimelineActivity(
        id: 'seed1',
        type: ActivityType.feeding,
        time: now.subtract(const Duration(minutes: 30)),
        title: 'ASI Kiri',
        subtitle: '15 menit',
        icon: Icons.restaurant,
        color: Colors.blue,
      ),
      TimelineActivity(
        id: 'seed2',
        type: ActivityType.nutrition,
        time: now.subtract(const Duration(hours: 2)),
        title: 'Menu Harian',
        subtitle: 'Bubur ayam + sayur',
        icon: Icons.restaurant_menu,
        color: Colors.green,
      ),
    ]);
    notifyListeners();
  }
}
