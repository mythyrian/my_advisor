import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'package:my_advisor/utils/location_logger_service.dart';
import 'pages/root.dart';
import 'constant/color.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await LocationLoggerService.runBackgroundTask();
    return Future.value(true);
  });
}

Timer? _foregroundTimer;

void startForegroundTracking() {
  _foregroundTimer?.cancel();
  _foregroundTimer = Timer.periodic(Duration(minutes: 15), (_) {
    LocationLoggerService.runBackgroundTask();
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await HiveStore.init();

  await dotenv.load(fileName: ".env");

  startForegroundTracking();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await Workmanager().registerPeriodicTask(
    'log-location-task',
    'logLocation',
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 10),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Advisor App',
        theme: ThemeData(primaryColor: Color(AppColor.primary)),
        home: const RootApp(),
      ),
    );
  }
}
