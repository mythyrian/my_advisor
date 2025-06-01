import 'package:hive_flutter/hive_flutter.dart';

class HiveStore {
  static late Box _box;

  /// Inizializza Hive e apre la box
  static Future<void> init() async {
    _box = await Hive.openBox('appBox');

    if (!_box.containsKey("place_type_pref")) {
      await _box.put("place_type_pref", {});
    }
    if (!_box.containsKey("range_reviw_pref")) {
      await _box.put("range_review_pref", {"min": 1, "max": 5});
    }
  }

  /// Salva un valore con una chiave
  static Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  /// Recupera un valore dato una chiave
  static T? get<T>(String key) {
    return _box.get(key);
  }

  /// Elimina un valore
  static Future<void> delete(String key) async {
    await _box.delete(key);
  }
}
