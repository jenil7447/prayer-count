import 'package:hive/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 1)
class DailyLog extends HiveObject {
  @HiveField(0)
  String dateKey; // Format: YYYY-MM-DD

  @HiveField(1)
  int count;

  DailyLog({required this.dateKey, required this.count});
}