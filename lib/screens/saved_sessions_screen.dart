import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/chant_session.dart';
import '../controllers/counter_controller.dart';

class SavedSessionsScreen extends StatelessWidget {
  final CounterController controller = Get.find();

  SavedSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Sessions')),
      body: ValueListenableBuilder(
        valueListenable: controller.sessionBox.listenable(),
        builder: (context, Box<ChantSession> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No saved sessions yet.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final session = box.getAt(box.length - 1 - index); // Reverse order
              if (session == null) return const SizedBox();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(session.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(session.date)),
                  trailing: Text(
                    '${session.count}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}