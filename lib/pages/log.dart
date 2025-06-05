import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_advisor/utils/database_service.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String jsonOutput = '';

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    final data = await readValue("placeVisited") ?? [];
    final formatted = const JsonEncoder.withIndent('  ').convert(data);

    setState(() {
      jsonOutput = formatted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contenuto JSON')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            jsonOutput,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        ),
      ),
    );
  }
}
