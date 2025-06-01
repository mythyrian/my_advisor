import 'package:flutter/material.dart';
import 'pages/root.dart';
import 'constant/color.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Advisor App',
      theme: ThemeData(primaryColor: AppColor.primary),
      home: const RootApp(),
    );
  }
}
