import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Rappel quotidien',
      channelDescription: 'Rappel pour compléter votre défi du jour',
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.periodicallyShow(
      0,
      'CyberFit',
      'Votre défi cyber du jour vous attend ! 🛡️',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> showBadgeUnlocked(String badgeName) async {
    const androidDetails = AndroidNotificationDetails(
      'badges',
      'Badges',
      channelDescription: 'Notifications de badges débloqués',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Badge débloqué !',
      'Vous avez obtenu le badge "$badgeName" 🏆',
      details,
    );
  }

  static Future<void> showStreakWarning(int currentStreak) async {
    const androidDetails = AndroidNotificationDetails(
      'streak_warning',
      'Streak en danger',
      channelDescription: 'Alerte quand votre streak risque de se perdre',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      2,
      'Votre streak est en danger !',
      'Vous avez $currentStreak jours de suite. Ne perdez pas votre série, '
      'complétez un défi aujourd\'hui !',
      details,
    );
  }

  static Future<void> showInactivityReminder(int daysSinceLastActive) async {
    const androidDetails = AndroidNotificationDetails(
      'inactivity',
      'Rappel d\'inactivité',
      channelDescription: 'Rappel après une période d\'inactivité',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final message = daysSinceLastActive >= 7
        ? 'Cela fait plus d\'une semaine ! Vos compétences cyber ont besoin d\'entraînement.'
        : 'Vous n\'avez pas été actif depuis $daysSinceLastActive jours. Un petit défi ?';

    await _plugin.show(
      3,
      'Vous nous manquez !',
      message,
      details,
    );
  }

  static Future<void> showNewChallengeAvailable() async {
    const androidDetails = AndroidNotificationDetails(
      'new_challenge',
      'Nouveau défi',
      channelDescription: 'Notification quand un nouveau défi est disponible',
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      4,
      'Nouveau défi disponible !',
      'Un nouveau défi cyber vous attend. Prêt à l\'affronter ?',
      details,
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
