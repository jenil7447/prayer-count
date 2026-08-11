import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:intl/intl.dart';
import '../models/chant_session.dart';
import '../models/daily_log.dart';

class CounterController extends GetxController {
  var count = 0.obs;
  var target = 108.obs;
  var isAudioEnabled = true.obs;
  var isVibrationEnabled = true.obs;
  var isWakeLockEnabled = false.obs;
  var streak = 0.obs; // Observable streak variable

  late Box<ChantSession> sessionBox;
  late Box<DailyLog> dailyBox;
  late Box settingsBox;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  void _initHive() {
    sessionBox = Hive.box<ChantSession>('sessions');
    dailyBox = Hive.box<DailyLog>('daily_logs');
    settingsBox = Hive.box('settings');

    target.value = settingsBox.get('target', defaultValue: 108);
    isAudioEnabled.value = settingsBox.get('audio', defaultValue: true);
    isVibrationEnabled.value = settingsBox.get('vibration', defaultValue: true);

    updateStreak(); // Calculate streak on start
  }

  void increment() {
    count.value++;
    _playFeedback();
    _updateDailyLog(1);
  }

  void resetCounter() {
    count.value = 0;
  }

  void setTarget(int newTarget) {
    target.value = newTarget;
    settingsBox.put('target', newTarget);
  }

  void toggleAudio() {
    isAudioEnabled.value = !isAudioEnabled.value;
    settingsBox.put('audio', isAudioEnabled.value);
  }

  void toggleVibration() {
    isVibrationEnabled.value = !isVibrationEnabled.value;
    settingsBox.put('vibration', isVibrationEnabled.value);
  }

  void toggleWakeLock() {
    isWakeLockEnabled.value = !isWakeLockEnabled.value;
    if (isWakeLockEnabled.value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void _playFeedback() async {
    if (isVibrationEnabled.value) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) Vibration.vibrate(duration: 40);
    }
    if (isAudioEnabled.value) {
      await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
    }
  }

  void saveSession(String name) {
    if (count.value == 0) return;
    final session = ChantSession(
      name: name,
      count: count.value,
      date: DateTime.now(),
    );
    sessionBox.add(session);
    resetCounter();
  }

  void _updateDailyLog(int addCount) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DailyLog? log = dailyBox.get(today);
    if (log != null) {
      log.count += addCount;
      log.save();
    } else {
      dailyBox.put(today, DailyLog(dateKey: today, count: addCount));
    }

    updateStreak(); // Refresh streak whenever counts update
  }

  void updateStreak() {
    int currentStreak = 0;
    DateTime date = DateTime.now();
    while (true) {
      String key = DateFormat('yyyy-MM-dd').format(date);
      if (dailyBox.containsKey(key) && dailyBox.get(key)!.count > 0) {
        currentStreak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    streak.value = currentStreak; // Updates subscribers listening via Obx
  }
}