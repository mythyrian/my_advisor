import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalDatabaseStore {

Future<File> _getJsonFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/data.json');
}


Future<dynamic> readValue(String key) async {
  final file = await _getJsonFile();

  if (!(await file.exists())) return null;

  final contents = await file.readAsString();
  final data = json.decode(contents);

  return data[key];
}

Future<void> writeValue(String key, dynamic value) async {
  final file = await _getJsonFile();

  Map<String, dynamic> data = {};

  if (await file.exists()) {
    final contents = await file.readAsString();
    data = json.decode(contents);
  }

  data[key] = value;

  await file.writeAsString(json.encode(data));
}

Future<void> deleteValue(String key) async {
  final file = await _getJsonFile();

  if (!(await file.exists())) return;

  final contents = await file.readAsString();
  final data = json.decode(contents);

  data.remove(key);

  await file.writeAsString(json.encode(data));
}

}
