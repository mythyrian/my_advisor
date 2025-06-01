import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_advisor/constant/place_type.dart';

class HiveStore {
  static late Box _box;

  /// Inizializza Hive e apre la box
  static Future<void> init() async {
    _box = await Hive.openBox('appBox');

    if (!_box.containsKey("place_type_pref")) {
      await _box.put(
        "place_type_pref",
        PlaceType.placeTypeList.map((item) {
          return {...item, 'checked': false};
        }).toList(),
      );
    }
    if (!_box.containsKey("place_type")) {
      await _box.put(
        "place_type",
        PlaceType.placeTypeList.map((item) {
          return {...item, 'checked': false};
        }).toList(),
      );
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
