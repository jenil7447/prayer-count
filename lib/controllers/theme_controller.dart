import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  // 1. Change type from MaterialColor to Color
  var primaryColor = Rx<Color>(Colors.deepOrange);
  late Box settingsBox;

  // 2. Use List<Color> instead of List<MaterialColor>
  final List<Color> availableColors = [
    const Color(0xFF3F5F4A), // Sage Forest Green
    const Color(0xFFB76E79), // Muted Lotus Pink
    const Color(0xFFB66A4C), // Warm Terracotta
    const Color(0xFF2F6F6D), // Deep Teal
    const Color(0xFF705477), // Muted Plum
    const Color(0xFFC49A3A), // Golden Ochre
  ];

  @override
  void onInit() {
    super.onInit();
    settingsBox = Hive.box('settings');
    int colorValue = settingsBox.get('themeColor', defaultValue: Colors.deepOrange.value);

    // 3. Removed the invalid "as MaterialColor" cast
    primaryColor.value = Color(colorValue);
  }

  void changeTheme(Color color) {
    primaryColor.value = color;
    settingsBox.put('themeColor', color.value);
  }
}