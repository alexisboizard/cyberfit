import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

enum LeaderboardType { points, score, streak }

final leaderboardTypeProvider = StateProvider<LeaderboardType>(
  (_) => LeaderboardType.points,
);

final leaderboardProvider = FutureProvider<List<UserModel>>((ref) {
  final type = ref.watch(leaderboardTypeProvider);
  final orderBy = switch (type) {
    LeaderboardType.points => 'totalPoints',
    LeaderboardType.score => 'currentScore',
    LeaderboardType.streak => 'currentStreak',
  };
  return ref.watch(firestoreServiceProvider).getLeaderboard(orderBy: orderBy);
});
