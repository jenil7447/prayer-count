import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:intl/intl.dart';

import '../models/chant_session.dart';
import '../models/daily_log.dart';

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
    final todayKey =
    DateFormat('yyyy-MM-dd').format(
      DateTime.now(),
    );

    final existingLog = dailyBox.get(todayKey);

    // ------------------------------------------------------------
    // CASE 1:
    // Today's log already exists
    // ------------------------------------------------------------

    if (existingLog != null) {
      // Remember whether today was previously inactive.
      final wasZero = existingLog.count == 0;

      // Increase today's total.
      existingLog.count++;

      // Save updated Hive object.
      existingLog.save();

      // Update reactive UI immediately.
      todayCount.value = existingLog.count;

      // ----------------------------------------------------------
      // IMPORTANT OPTIMIZATION
      //
      // Only update the streak when today changes from:
      //
      //     0 chants → 1 chant
      //
      // Subsequent taps don't need to recalculate the streak.
      // ----------------------------------------------------------

      if (wasZero) {
        _updateStreakAfterFirstChant();
      }

      return;
    }

    // ------------------------------------------------------------
    // CASE 2:
    // No log exists for today
    // ------------------------------------------------------------

    final newLog = DailyLog(
      dateKey: todayKey,
      count: 1,
    );

    dailyBox.put(
      todayKey,
      newLog,
    );

    // Update today's count in UI.
    todayCount.value = 1;

    // This is the first chant of the day,
    // so streak needs to be updated.
    _updateStreakAfterFirstChant();
  }

  // ============================================================
  // UPDATE STREAK AFTER FIRST CHANT OF THE DAY
  // ============================================================

  void _updateStreakAfterFirstChant() {
    final today = DateTime.now();

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final yesterdayKey =
    DateFormat('yyyy-MM-dd').format(
      yesterday,
    );

    final yesterdayLog =
    dailyBox.get(yesterdayKey);

    // ------------------------------------------------------------
    // If yesterday had chanting:
    //
    //     yesterday = active
    //     today = active
    //
    // Extend the streak.
    // ------------------------------------------------------------

    if (yesterdayLog != null &&
        yesterdayLog.count > 0) {
      streak.value++;
    }

    // ------------------------------------------------------------
    // If yesterday didn't have chanting:
    //
    //     today starts a new streak.
    // ------------------------------------------------------------

    else {
      streak.value = 1;
    }
  }

  // ============================================================
  // REBUILD STREAK FROM DATABASE
  // ============================================================

  void updateStreak() {
    int currentStreak = 0;

    DateTime date = DateTime.now();

    // ------------------------------------------------------------
    // Update today's count
    // ------------------------------------------------------------

    final todayKey =
    DateFormat('yyyy-MM-dd').format(date);

    final todayLog = dailyBox.get(todayKey);

    todayCount.value = todayLog?.count ?? 0;

    // ------------------------------------------------------------
    // Calculate streak
    //
    // Start from today and move backwards until we find
    // a day where the user didn't chant.
    // ------------------------------------------------------------

    while (true) {
      final key =
      DateFormat('yyyy-MM-dd').format(date);

      final log = dailyBox.get(key);

      // If the day exists and the user chanted,
      // this day belongs to the streak.
      if (log != null && log.count > 0) {
        currentStreak++;

        // Move to previous day.
        date = date.subtract(
          const Duration(days: 1),
        );
      }

      // First inactive day → streak ends.
      else {
        break;
      }
    }

    streak.value = currentStreak;
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