import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';

Future<File> _getJsonFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/local-database.json');
}

Future<dynamic> readValue(String key) async {
  final file = await _getJsonFile();

  if (!(await file.exists())) return null;

  final contents = await file.readAsString();
  final data = json.decode(contents);

  return data[key];
}

Future<void> writeValue(String key, dynamic value) async {
  try {
    final file = await _getJsonFile();
    Map<String, dynamic> data = {};

    if (await file.exists()) {
      final contents = await file.readAsString();
      data = json.decode(contents);
    }

    data[key] = value;
    await file.writeAsString(json.encode(data));
  } catch (e) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text('Errore in writeValue!'),
      description: RichText(text: TextSpan(text: "Errore in writeValue: $e")),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}

Future<void> deleteValue(String key) async {
  final file = await _getJsonFile();

  if (!(await file.exists())) return;

  final contents = await file.readAsString();
  final data = json.decode(contents);

  data.remove(key);

  await file.writeAsString(json.encode(data));
}

Future<void> appendToList(String key, dynamic newValue) async {
  final file = await _getJsonFile();

  Map<String, dynamic> data = {};

  if (await file.exists()) {
    final contents = await file.readAsString();

    if (contents.trim().isNotEmpty) {
      try {
        data = json.decode(contents);
      } catch (e) {
        print("Errore di parsing JSON: $e");
        data = {};
      }
    }
  }

  final list = List.from(data[key] ?? []);
  list.add(newValue);
  data[key] = list;

  await file.writeAsString(json.encode(data));
}

