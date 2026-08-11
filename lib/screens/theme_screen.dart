import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeScreen extends StatelessWidget {
  final ThemeController themeController = Get.find();

  ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Theme Color')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: themeController.availableColors.length,
        itemBuilder: (context, index) {
          final color = themeController.availableColors[index];
          return GestureDetector(
            onTap: () => themeController.changeTheme(color),
            child: Obx(() {
              bool isSelected = themeController.primaryColor.value.value == color.value;
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.black, width: 4) : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 36)
                    : null,
              );
            }),
          );
        },
      ),
    );
  }
}