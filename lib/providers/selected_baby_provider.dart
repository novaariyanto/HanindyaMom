import 'package:flutter/foundation.dart';

class SelectedBabyProvider extends ChangeNotifier {
  String? _babyId;

  String? get babyId => _babyId;
  bool get hasBaby => _babyId != null && _babyId!.isNotEmpty;

  void setBaby(String? id) {
    if (_babyId == id) return;
    _babyId = id;
    notifyListeners();
  }
}
