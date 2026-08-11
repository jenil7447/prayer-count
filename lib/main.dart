import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/chant_session.dart';
import 'models/daily_log.dart';
import 'controllers/theme_controller.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await Hive.initFlutter();
  Hive.registerAdapter(ChantSessionAdapter());
  Hive.registerAdapter(DailyLogAdapter());

  await Hive.openBox<ChantSession>('sessions');
  await Hive.openBox<DailyLog>('daily_logs');
  await Hive.openBox('settings');

  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chant Counter',
      theme: ThemeData(
        colorSchemeSeed: themeController.primaryColor.value,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    ));
  }
}