import '../models/badge_model.dart';
import '../models/challenge_model.dart';
import '../models/user_model.dart';

class BadgeService {
  List<BadgeModel> evaluateNewBadges({
    required UserModel user,
    required List<CompletedChallenge> completed,
    required List<BadgeModel> allBadges,
  }) {
    final newBadges = <BadgeModel>[];

    for (final badge in allBadges) {
      if (user.badges.contains(badge.id)) continue;
      if (_evaluateCondition(badge.condition, user, completed)) {
        newBadges.add(badge);
      }
    }

    return newBadges;
  }

  bool _evaluateCondition(
    String condition,
    UserModel user,
    List<CompletedChallenge> completed,
  ) {
    // complete_N_challenge(s)
    final completeMatch = RegExp(r'^complete_(\d+)_challenge').firstMatch(condition);
    if (completeMatch != null) {
      final n = int.parse(completeMatch.group(1)!);
      return completed.length >= n;
    }

    // complete_all_{category}
    final categoryMatch = RegExp(r'^complete_all_(\w+)$').firstMatch(condition);
    if (categoryMatch != null) {
      final category = categoryMatch.group(1)!;
      final completedInCategory =
          completed.where((c) => c.category == category).length;
      return completedInCategory >= _challengeCountForCategory(category);
    }

    // streak_N
    final streakMatch = RegExp(r'^streak_(\d+)$').firstMatch(condition);
    if (streakMatch != null) {
      final n = int.parse(streakMatch.group(1)!);
      return user.currentStreak >= n || user.longestStreak >= n;
    }

    // score_N
    final scoreMatch = RegExp(r'^score_(\d+)$').firstMatch(condition);
    if (scoreMatch != null) {
      final n = int.parse(scoreMatch.group(1)!);
      return user.currentScore >= n;
    }

    // reach_level_{level}
    final levelMatch = RegExp(r'^reach_level_(\w+)$').firstMatch(condition);
    if (levelMatch != null) {
      final targetLevel = levelMatch.group(1)!;
      return _levelIndex(user.level) >= _levelIndex(targetLevel);
    }

    return false;
  }

  int _challengeCountForCategory(String category) {
    const counts = {
      'passwords': 3,
      'authentication': 3,
      'social': 3,
      'email': 3,
      'device': 3,
      'navigation': 3,
    };
    return counts[category] ?? 3;
  }

  int _levelIndex(String level) {
    const levels = ['beginner', 'initiated', 'confirmed', 'expert', 'master'];
    return levels.indexOf(level);
  }
}
