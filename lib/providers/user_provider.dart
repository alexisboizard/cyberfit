import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import 'auth_provider.dart';

final userStreamProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(firestoreServiceProvider).userStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final completedChallengesProvider =
    FutureProvider<List<CompletedChallenge>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Future.value([]);
      return ref.watch(firestoreServiceProvider).getCompletedChallenges(user.uid);
    },
    loading: () => Future.value([]),
    error: (_, __) => Future.value([]),
  );
});

final userActionsProvider = Provider<UserActions>((ref) => UserActions(ref));

class UserActions {
  final Ref _ref;

  UserActions(this._ref);

  Future<void> completeChallenge(ChallengeModel challenge) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    final firestore = _ref.read(firestoreServiceProvider);

    // Save completed challenge
    final completed = CompletedChallenge(
      challengeId: challenge.id,
      completedAt: DateTime.now(),
      pointsEarned: challenge.points,
      category: challenge.category,
    );
    await firestore.addCompletedChallenge(user.uid, completed);

    // Update user stats
    final currentUser = await firestore.getUser(user.uid);
    if (currentUser == null) return;

    final newPoints = currentUser.totalPoints + challenge.points;
    final newLevel = _calculateLevel(newPoints);
    final newStreak = _calculateStreak(currentUser);

    await firestore.updateUser(user.uid, {
      'totalPoints': newPoints,
      'level': newLevel,
      'currentStreak': newStreak,
      'longestStreak':
          newStreak > currentUser.longestStreak ? newStreak : currentUser.longestStreak,
      'lastActiveDate': Timestamp.now(),
    });
  }

  String _calculateLevel(int totalPoints) {
    final levelIndex = (totalPoints / AppConstants.levelThreshold)
        .floor()
        .clamp(0, AppConstants.levels.length - 1);
    return AppConstants.levels[levelIndex];
  }

  int _calculateStreak(UserModel user) {
    final now = DateTime.now();
    final lastActive = user.lastActiveDate;

    if (lastActive == null) return 1;

    final daysSince = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;

    if (daysSince <= 1) return user.currentStreak + 1;
    return 1; // Streak broken
  }

  Future<void> updateOnboarding({
    required Map<String, int> scoreBreakdown,
  }) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    final totalScore =
        scoreBreakdown.values.fold<int>(0, (sum, v) => sum + v);

    await _ref.read(firestoreServiceProvider).updateUser(user.uid, {
      'scoreBreakdown': scoreBreakdown,
      'currentScore': totalScore,
      'onboardingCompleted': true,
    });
  }
}
