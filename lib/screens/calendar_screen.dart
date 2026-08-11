import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../controllers/counter_controller.dart';
import '../models/daily_log.dart';

class CalendarScreen extends StatelessWidget {
  final CounterController controller = Get.find();

  CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak & Activity')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Streak Card - Reads reactive controller.streak.value directly inside Obx
            Obx(() => Card(
              color: Theme.of(context).primaryColor,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
                    const SizedBox(width: 10),
                    Text(
                      '${controller.streak.value} Days Streak!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 20),

            // Calendar
            ValueListenableBuilder(
              valueListenable: controller.dailyBox.listenable(),
              builder: (context, Box<DailyLog> box, _) {
                return TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      String key = DateFormat('yyyy-MM-dd').format(date);
                      DailyLog? log = box.get(key);
                      if (log != null && log.count > 0) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${log.count}',
                              style: const TextStyle(color: Colors.white, fontSize: 8),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}