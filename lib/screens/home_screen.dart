import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../controllers/theme_controller.dart';
import 'saved_sessions_screen.dart';
import 'calendar_screen.dart';
import 'theme_screen.dart';
import '../widgets/mala_counter.dart';
class HomeScreen extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());
  final ThemeController themeController = Get.put(ThemeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeColor = themeController.primaryColor.value;
      
      // Register observables tracked inside LayoutBuilder
      // Obx only tracks variables accessed synchronously in its builder!
      controller.count.value;
      controller.target.value;
      controller.todayCount.value;
      controller.streak.value;
      controller.isAudioEnabled.value;
      controller.isVibrationEnabled.value;
      controller.isWakeLockEnabled.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Counter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          ),
          backgroundColor: themeColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.palette,
              color: Colors.black,
              ),
              onPressed: () => Get.to(() => ThemeScreen()),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
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

            // Target Indicator
            GestureDetector(
              onTap: () => _showTargetDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, color: themeColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Target: ${controller.target.value}",
                      style: const TextStyle(
                        color: Color(0xFF2C3E2D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "(Tap to change)",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Main Increment Area
            MalaCounterWidget(
              count: controller.count.value,
              target: controller.target.value,
              onTap: controller.increment,
              themeColor: themeColor,
            ),

            const Spacer(),

            // Stats & Action Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.to(() => SavedSessionsScreen()),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, color: themeColor, size: 28),
                            const SizedBox(height: 4),
                            const Text(
                              'History',
                              style: TextStyle(
                                color: Color(0xFF2C3E2D),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildStatCard(
                    title: 'Streak',
                    value: '${controller.streak.value} 🔥',
                    bgColor: themeColor.withOpacity(0.15),
                    onTap: () => Get.to(() => CalendarScreen()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reset & Save Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    icon: const Icon(Icons.restart_alt, size: 20),
                    label: const Text('Reset', style: TextStyle(fontSize: 16)),
                    onPressed: controller.resetCounter,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      label: const Text(
                        'Save Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _showSaveDialog(context),
                    ),
                  ),
                ],
              ),
            ),
            //const Spacer(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2C3E2D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}