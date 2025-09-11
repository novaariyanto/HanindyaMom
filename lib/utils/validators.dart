class Validators {
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  static bool isUuid(String? value) {
    if (value == null) return false;
    if (value.length != 36) return false;
    return _uuidRegex.hasMatch(value);
    }
}


