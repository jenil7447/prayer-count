import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../controllers/theme_controller.dart';
import 'saved_sessions_screen.dart';
import 'calendar_screen.dart';
import 'theme_screen.dart';

class HomeScreen extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());
  final ThemeController themeController = Get.put(ThemeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeColor = themeController.primaryColor.value;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Japa Counter'),
          backgroundColor: themeColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.palette),
              onPressed: () => Get.to(() => ThemeScreen()),
            ),
          ],
        ),
        body: Column(
          children: [
            // Control Toggles Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(controller.isAudioEnabled.value ? Icons.volume_up : Icons.volume_off),
                    color: controller.isAudioEnabled.value ? themeColor : Colors.grey,
                    onPressed: controller.toggleAudio,
                  ),
                  IconButton(
                    icon: Icon(controller.isVibrationEnabled.value ? Icons.vibration : Icons.mobile_off),
                    color: controller.isVibrationEnabled.value ? themeColor : Colors.grey,
                    onPressed: controller.toggleVibration,
                  ),
                  IconButton(
                    icon: Icon(controller.isWakeLockEnabled.value ? Icons.screen_lock_rotation : Icons.screen_rotation),
                    color: controller.isWakeLockEnabled.value ? themeColor : Colors.grey,
                    onPressed: controller.toggleWakeLock,
                  ),
                ],
              ),
            ),

            // Navigation Quick Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  icon: const Icon(Icons.bookmark, color: Colors.white),
                  label: const Text('Saved Counts', style: TextStyle(color: Colors.white)),
                  onPressed: () => Get.to(() => SavedSessionsScreen()),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  label: const Text('Streak & Logs', style: TextStyle(color: Colors.white)),
                  onPressed: () => Get.to(() => CalendarScreen()),
                ),
              ],
            ),

            const Spacer(),

            // Target Indicator
            GestureDetector(
              onTap: () => _showTargetDialog(context),
              child: Chip(
                avatar: const Icon(Icons.flag, size: 18),
                label: Text("Target: ${controller.target.value} (Tap to change)"),
              ),
            ),

            const SizedBox(height: 10),

            // Main Increment Area
            Expanded(
              flex: 3,
              child: Center(
                child: InkWell(
                  onTap: controller.increment,
                  borderRadius: BorderRadius.circular(150),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeColor.withOpacity(0.15),
                      border: Border.all(color: themeColor, width: 8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${controller.count.value}',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'TAP TO COUNT',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Reset & Save Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text('Reset', style: TextStyle(color: Colors.red)),
                  onPressed: controller.resetCounter,
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save Session', style: TextStyle(color: Colors.white)),
                  onPressed: () => _showSaveDialog(context),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      );
    });
  }

  void _showTargetDialog(BuildContext context) {
    final textController = TextEditingController(text: controller.target.value.toString());
    Get.defaultDialog(
      title: 'Set Target Count',
      content: TextField(
        controller: textController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Target (e.g., 108)'),
      ),
      textConfirm: 'Save',
      onConfirm: () {
        int? value = int.tryParse(textController.text);
        if (value != null && value > 0) {
          controller.setTarget(value);
        }
        Get.back();
      },
    );
  }

  void _showSaveDialog(BuildContext context) {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: 'Save Chant Session',
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(labelText: 'Chant / Mantra Name'),
      ),
      textConfirm: 'Save',
      onConfirm: () {
        if (textController.text.isNotEmpty) {
          controller.saveSession(textController.text);
          Get.back();
        }
      },
    );
  }
}