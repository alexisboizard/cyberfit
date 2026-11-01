import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logChallengeStarted({
    required String challengeId,
    required String category,
    required String difficulty,
  }) =>
      _analytics.logEvent(name: 'challenge_started', parameters: {
        'challenge_id': challengeId,
        'category': category,
        'difficulty': difficulty,
      });

  static Future<void> logChallengeCompleted({
    required String challengeId,
    required String category,
    required String difficulty,
    required int pointsEarned,
  }) =>
      _analytics.logEvent(name: 'challenge_completed', parameters: {
        'challenge_id': challengeId,
        'category': category,
        'difficulty': difficulty,
        'points_earned': pointsEarned,
      });

  static Future<void> logBadgeUnlocked({
    required String badgeId,
    required String rarity,
  }) =>
      _analytics.logEvent(name: 'badge_unlocked', parameters: {
        'badge_id': badgeId,
        'rarity': rarity,
      });

  static Future<void> logGuideOpened({
    required String guideId,
    required String category,
  }) =>
      _analytics.logEvent(name: 'guide_opened', parameters: {
        'guide_id': guideId,
        'category': category,
      });

  static Future<void> logPaywallShown({required String trigger}) =>
      _analytics.logEvent(name: 'paywall_shown', parameters: {
        'trigger': trigger,
      });

  static Future<void> logPurchaseStarted({required String packageId}) =>
      _analytics.logEvent(name: 'purchase_started', parameters: {
        'package_id': packageId,
      });

  static Future<void> logPurchaseCompleted({required String packageId}) =>
      _analytics.logEvent(name: 'purchase_completed', parameters: {
        'package_id': packageId,
      });
}
