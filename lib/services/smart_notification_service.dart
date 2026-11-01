import '../models/user_model.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class SmartNotificationService {
  static Future<void> checkAndNotify({
    required UserModel user,
    required StorageService storage,
  }) async {
    if (!storage.notificationsEnabled) return;

    final now = DateTime.now();
    final lastActive = user.lastActiveDate;

    if (lastActive == null) return;

    final daysSinceActive = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;

    // Streak warning: user was active yesterday but not yet today
    if (daysSinceActive == 1 && user.currentStreak >= 3) {
      await NotificationService.showStreakWarning(user.currentStreak);
      return;
    }

    // Inactivity reminder: 3+ days without activity
    if (daysSinceActive >= 3) {
      await NotificationService.showInactivityReminder(daysSinceActive);
      return;
    }
  }
}
