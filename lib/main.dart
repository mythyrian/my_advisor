import 'package:flutter/material.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'pages/root.dart';
import 'constant/color.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await HiveStore.init();

  await dotenv.load(fileName: ".env");
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
