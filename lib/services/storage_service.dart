import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';
  static const _keyLastChallengeDate = 'last_challenge_date';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(_keyOnboardingDone, value);

  // Notifications
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotificationsEnabled, value);

  int get reminderHour => _prefs.getInt(_keyReminderHour) ?? 9;
  Future<void> setReminderHour(int value) =>
      _prefs.setInt(_keyReminderHour, value);

  int get reminderMinute => _prefs.getInt(_keyReminderMinute) ?? 0;
  Future<void> setReminderMinute(int value) =>
      _prefs.setInt(_keyReminderMinute, value);

  // Last challenge date (for streak tracking)
  String? get lastChallengeDate => _prefs.getString(_keyLastChallengeDate);
  Future<void> setLastChallengeDate(String value) =>
      _prefs.setString(_keyLastChallengeDate, value);
}
