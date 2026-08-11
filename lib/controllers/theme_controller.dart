import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  // 1. Change type from MaterialColor to Color
  var primaryColor = Rx<Color>(Colors.deepOrange);
  late Box settingsBox;

  // 2. Use List<Color> instead of List<MaterialColor>
  final List<Color> availableColors = [
    Colors.deepOrange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.green,
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