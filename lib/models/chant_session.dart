import 'package:hive/hive.dart';

part 'chant_session.g.dart';

@HiveType(typeId: 0)
class ChantSession extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int count;

  @HiveField(2)
  DateTime date;

  ChantSession({required this.name, required this.count, required this.date});
}