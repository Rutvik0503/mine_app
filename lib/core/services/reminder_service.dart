import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../server_model/machine/model/user_machine_model.dart';
import '../server_model/mining/model/mining_session_model.dart';
import '../server_model/notification/repository/notification_repository.dart';
import 'supabase_service.dart';

/// Local (on-device) reminder notifications - scheduled by the phone itself,
/// so they fire on time even offline and need no server.
///
/// Everything is re-planned each time the app opens ([planDaily]), so a
/// player who opens the app every day only ever sees the useful ones; the
/// streak / "we miss you" reminders only fire if they *didn't* come back.
/// All of it is switched off by Settings > Notifications.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _prefsKey = 'notifications_enabled';
  // Every scheduled reminder, so the ones that have gone off can be copied
  // to the Notifications screen (see flushDelivered).
  static const _ledgerKey = 'reminder_ledger';

  // Notification ids, one per reminder (re-scheduling replaces the old one).
  static const _idStreak = 100;
  static const _idDailyBonus = 101;
  static const _idMiningDone = 102;
  static const _idMissYou = 103;
  static const _idMiningLive = 104;
  static const _idStreakLastChance = 105;
  static const _idDailyBonusExtra = 106; // 106, 107: days 2 and 3 ahead
  static const _bonusDaysAhead = 3;
  static const _idRentalBase = 110; // 110..129, one per rental
  static const _maxRentals = 20;

  // Local times of day.
  static const _streakHour = 19; // 7 PM
  static const _lastChanceHour = 21; // 9:30 PM - the streak day ends at local midnight
  static const _lastChanceMinute = 30;
  static const _bonusHour = 10; // 10 AM

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _enabled = true;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminders',
      'Daily reminders',
      channelDescription: 'Streak, mining complete, daily bonus and rental reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  bool get isEnabled => _enabled;

  final NotificationRepository _notificationRepository = NotificationRepository();
  bool _flushing = false;

  static String _typeFor(int id) {
    if (id == _idStreak || id == _idStreakLastChance) return 'streak';
    if (id == _idDailyBonus || (id >= _idDailyBonusExtra && id < _idDailyBonusExtra + 2)) return 'daily_bonus';
    if (id == _idMiningDone) return 'mining';
    if (id == _idMissYou) return 'reengagement';
    if (id >= _idRentalBase && id < _idRentalBase + _maxRentals) return 'rental';
    return 'general';
  }

  Future<Map<String, dynamic>> _readLedger() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return Map<String, dynamic>.from(jsonDecode(prefs.getString(_ledgerKey) ?? '{}') as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeLedger(Map<String, dynamic> ledger) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ledgerKey, jsonEncode(ledger));
  }

  /// Copies reminders whose time has passed - so the phone already showed
  /// them - to the player's Notifications screen, then forgets them. Runs
  /// before every re-plan, so nothing is overwritten before it's logged.
  Future<void> flushDelivered() async {
    if (_flushing || !SupabaseService.isLoggedIn) return;
    _flushing = true;
    try {
      final ledger = await _readLedger();
      final now = DateTime.now();
      final done = <String>[];
      for (final entry in ledger.entries) {
        final e = Map<String, dynamic>.from(entry.value as Map);
        final at = DateTime.fromMillisecondsSinceEpoch(e['at'] as int);
        if (at.isAfter(now)) continue;
        try {
          await _notificationRepository.logShownReminder(
            title: e['title'] as String,
            body: e['body'] as String,
            type: e['type'] as String,
            shownAt: at,
            ref: 'local:${entry.key}:${at.millisecondsSinceEpoch}',
          );
          done.add(entry.key);
        } catch (err) {
          debugPrint('Logging reminder ${entry.key} failed: $err'); // retried next time
        }
      }
      if (done.isNotEmpty) {
        for (final k in done) {
          ledger.remove(k);
        }
        await _writeLedger(ledger);
      }
    } finally {
      _flushing = false;
    }
  }

  /// Cancels a scheduled reminder that hasn't gone off yet.
  Future<void> _cancel(int id) async {
    await _plugin.cancel(id);
    final ledger = await _readLedger();
    if (ledger.remove('$id') != null) await _writeLedger(ledger);
  }

  Future<void> init() async {
    if (_ready) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? true;

      tz_data.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('ReminderService.init failed: $e');
    }
  }

  /// Settings > Notifications. Off cancels every scheduled reminder.
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    if (!value) {
      await init();
      if (_ready) await _plugin.cancelAll();
      await _writeLedger({});
    }
  }

  /// On logout / account deletion - reminders belong to that player.
  Future<void> cancelAll() async {
    await init();
    if (_ready) await _plugin.cancelAll();
    await _writeLedger({});
  }

  /// Call whenever the app opens / the home screen loads: the player is
  /// here today, so the streak reminder moves to tomorrow evening, the
  /// daily bonus to tomorrow morning, and "we miss you" two days out.
  Future<void> planDaily({required int streakDays}) async {
    if (!await _canSchedule()) return;
    await flushDelivered();
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = now.add(const Duration(days: 1));

    await _schedule(
      _idStreak,
      streakDays > 0
          ? 'streakReminderTitle'.trParams({'days': '$streakDays'})
          : 'streakStartTitle'.tr,
      'streakReminderBody'.tr,
      _at(tomorrow, _streakHour),
    );
    // "Last chance" only when there's a streak to lose.
    if (streakDays > 0) {
      await _schedule(
        _idStreakLastChance,
        'streakLastChanceTitle'.tr,
        'streakLastChanceBody'.trParams({'days': '$streakDays'}),
        _at(tomorrow, _lastChanceHour, _lastChanceMinute),
      );
    } else {
      await _cancel(_idStreakLastChance);
    }

    // Daily bonus for the next few mornings, so a player who skips a day
    // still hears about it (each app open pushes them all forward again).
    for (var day = 1; day <= _bonusDaysAhead; day++) {
      await _schedule(
        day == 1 ? _idDailyBonus : _idDailyBonusExtra + day - 2,
        'dailyBonusTitle'.tr,
        'dailyBonusBody'.tr,
        _at(now.add(Duration(days: day)), _bonusHour),
      );
    }
    await _schedule(
      _idMissYou,
      'missYouTitle'.tr,
      'missYouBody'.tr,
      _at(now.add(const Duration(days: 2)), _streakHour + 1),
    );
  }

  /// While [session] runs: a silent, live countdown in the notification bar
  /// ("Mining in progress - 42:10 left") that removes itself when the
  /// session ends, plus the "Mining complete!" alert at that moment.
  /// Cancels both when there's nothing to wait for.
  Future<void> planMiningDone(MiningSessionModel? session) async {
    if (!await _canSchedule()) return;
    await flushDelivered();
    if (session == null || !session.isActive || session.remaining == Duration.zero) {
      await _cancel(_idMiningDone);
      await _plugin.cancel(_idMiningLive);
      return;
    }
    await _showMiningLive(session);
    await _schedule(
      _idMiningDone,
      'miningDoneTitle'.tr,
      'miningDoneBody'.tr,
      tz.TZDateTime.from(session.expectedEndAt, tz.local),
    );
  }

  Future<void> _showMiningLive(MiningSessionModel session) async {
    final remaining = session.remaining;
    try {
      await _plugin.show(
        _idMiningLive,
        'miningLiveTitle'.tr,
        'miningLiveBody'.trParams({
          'hashrate': session.hashrateSnapshot.toStringAsFixed(2),
        }),
        NotificationDetails(
          android: AndroidNotificationDetails(
            // Default importance keeps it in the main notification list
            // (Low lands it in "Silent"); no sound or vibration, no pop-up.
            'mining_live_v2',
            'Mining in progress',
            channelDescription: 'Live countdown while a mining session runs',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: false,
            enableVibration: false,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            showWhen: true,
            when: session.expectedEndAt.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
            // Gone once the session ends - "Mining complete!" takes over.
            timeoutAfter: remaining.inMilliseconds,
          ),
          iOS: const DarwinNotificationDetails(presentAlert: false, presentSound: false),
        ),
      );
    } catch (e) {
      debugPrint('Showing mining countdown failed: $e');
    }
  }

  /// A day before each rental ends: "renew to keep it mining".
  Future<void> planRentalExpiry(List<UserMachineModel> machines) async {
    if (!await _canSchedule()) return;
    await flushDelivered();
    for (var i = 0; i < _maxRentals; i++) {
      await _cancel(_idRentalBase + i);
    }
    final now = DateTime.now();
    final rentals = machines
        .where((m) => m.expiresAt != null && m.expiresAt!.subtract(const Duration(days: 1)).isAfter(now))
        .take(_maxRentals)
        .toList();
    for (var i = 0; i < rentals.length; i++) {
      final m = rentals[i];
      await _schedule(
        _idRentalBase + i,
        'rentalEndingTitle'.trParams({'name': m.machine?.name ?? 'Miner'}),
        'rentalEndingBody'.tr,
        tz.TZDateTime.from(m.expiresAt!.subtract(const Duration(days: 1)), tz.local),
      );
    }
  }

  Future<bool> _canSchedule() async {
    await init();
    return _ready && _enabled;
  }

  tz.TZDateTime _at(tz.TZDateTime day, int hour, [int minute = 0]) =>
      tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute);

  Future<void> _schedule(int id, String title, String body, tz.TZDateTime when) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        // Inexact: no exact-alarm permission needed; may arrive a few minutes late.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      final ledger = await _readLedger();
      ledger['$id'] = {'title': title, 'body': body, 'type': _typeFor(id), 'at': when.millisecondsSinceEpoch};
      await _writeLedger(ledger);
    } catch (e) {
      debugPrint('Scheduling reminder $id failed: $e');
    }
  }
}
