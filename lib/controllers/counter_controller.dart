import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/chant_session.dart';
import '../models/daily_log.dart';
import '../utils/streak_calculator.dart';

class CounterController extends GetxController {
  // ============================================================
  // REACTIVE STATE
  // ============================================================

  var count = 0.obs;
  var target = 108.obs;

  var isAudioEnabled = true.obs;
  var isVibrationEnabled = true.obs;
  var isWakeLockEnabled = false.obs;

  var streak = 0.obs;
  var todayCount = 0.obs;

  // ============================================================
  // HIVE
  // ============================================================

  late Box<ChantSession> sessionBox;
  late Box<DailyLog> dailyBox;
  late Box settingsBox;

  // ============================================================
  // SERVICES
  // ============================================================

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Cache vibrator availability.
  // We don't want to call Vibration.hasVibrator()
  // on every single tap.
  bool _hasVibrator = false;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _initHive();
    _initVibration();
  }

  // ============================================================
  // HIVE INITIALIZATION
  // ============================================================

  void _initHive() {
    sessionBox = Hive.box<ChantSession>('sessions');
    dailyBox = Hive.box<DailyLog>('daily_logs');
    settingsBox = Hive.box('settings');

    // Load saved settings
    target.value = settingsBox.get(
      'target',
      defaultValue: 108,
    );

    isAudioEnabled.value = settingsBox.get(
      'audio',
      defaultValue: true,
    );

    isVibrationEnabled.value = settingsBox.get(
      'vibration',
      defaultValue: true,
    );

    // Calculate the correct streak when app starts.
    //
    // This is okay because we only need to rebuild the streak
    // from the database when the controller starts.
    updateStreak();
  }

  // ============================================================
  // VIBRATION INITIALIZATION
  // ============================================================

  Future<void> _initVibration() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  // ============================================================
  // MAIN COUNTER
  // ============================================================

  void increment() {
    // 1. Increase current session count
    count.value++;

    // 2. Play sound/vibration
    _playFeedback();

    // 3. Update today's total
    _updateDailyLog();
  }

  // ============================================================
  // RESET CURRENT SESSION
  // ============================================================

  void resetCounter() {
    count.value = 0;
  }

  // ============================================================
  // TARGET
  // ============================================================

  void setTarget(int newTarget) {
    target.value = newTarget;

    settingsBox.put(
      'target',
      newTarget,
    );
  }

  // ============================================================
  // AUDIO
  // ============================================================

  void toggleAudio() {
    isAudioEnabled.value = !isAudioEnabled.value;

    settingsBox.put(
      'audio',
      isAudioEnabled.value,
    );
  }

  // ============================================================
  // VIBRATION
  // ============================================================

  void toggleVibration() {
    isVibrationEnabled.value =
    !isVibrationEnabled.value;

    settingsBox.put(
      'vibration',
      isVibrationEnabled.value,
    );
  }

  // ============================================================
  // WAKE LOCK
  // ============================================================

  void toggleWakeLock() {
    isWakeLockEnabled.value =
    !isWakeLockEnabled.value;

    if (isWakeLockEnabled.value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  // Future<void> _playFeedback() async {
  //   // -------------------------
  //   // VIBRATION
  //   // -------------------------
  //
  //   if (isVibrationEnabled.value && _hasVibrator) {
  //     Vibration.vibrate(
  //       duration: 40,
  //     );
  //   }
  //
  //   // -------------------------
  //   // AUDIO
  //   // -------------------------
  //
  //   if (isAudioEnabled.value) {
  //     await _audioPlayer.play(
  //       AssetSource('sounds/tick.mp3'),
  //     );
  //   }
  // }
  Future<void> _playFeedback() async {
    // Vibration
    if (isVibrationEnabled.value && _hasVibrator) {
      Vibration.vibrate(duration: 40);
    }

    // Audio
    if (isAudioEnabled.value) {
      await _audioPlayer.stop();

      if (count.value > 0 && count.value % target.value == 0) {
        await _audioPlayer.play(
          AssetSource('sounds/target-reached.mp3'),
        );
      } else {
        await _audioPlayer.play(
          AssetSource('sounds/tick.mp3'),
        );
      }
    }
  }

  // ============================================================
  // SAVE SESSION
  // ============================================================

  void saveSession(String name) {
    // Don't save empty sessions.
    if (count.value == 0) {
      return;
    }

    final session = ChantSession(
      name: name,
      count: count.value,
      date: DateTime.now(),
    );

    sessionBox.add(session);

    // Reset only the current session.
    //
    // IMPORTANT:
    // Today's total is NOT reset.
    resetCounter();
  }

  // ============================================================
  // UPDATE DAILY LOG
  // ============================================================

  void _updateDailyLog() {
    final todayKey = dailyLogDateKey(DateTime.now());
    final existingLog = dailyBox.get(todayKey);

    if (existingLog != null) {
      // Increase the persisted total for today.
      existingLog.count++;
      existingLog.save();
      todayCount.value = existingLog.count;
    } else {
      // Record the first chant for today.
      dailyBox.put(
        todayKey,
        DailyLog(dateKey: todayKey, count: 1),
      );
      todayCount.value = 1;
    }

    // Always derive the streak from persisted logs instead of
    // incrementing a potentially stale in-memory value.
    updateStreak();
  }

  // ============================================================
  // REBUILD STREAK FROM DATABASE
  // ============================================================

  void updateStreak() {
    final todayKey = dailyLogDateKey(DateTime.now());
    final todayLog = dailyBox.get(todayKey);

    todayCount.value = todayLog?.count ?? 0;

    // Calculate from saved daily logs every time. This avoids stale
    // in-memory streak values and handles app opens on a new day.
    streak.value = calculateCurrentStreak(
      now: DateTime.now(),
      todayCount: todayCount.value,
      dailyCountForDate: (dateKey) => dailyBox.get(dateKey)?.count ?? 0,
    );
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void onClose() {
    _audioPlayer.dispose();

    // Make sure wake lock is disabled when
    // the controller is destroyed.
    WakelockPlus.disable();

    super.onClose();
  }
}