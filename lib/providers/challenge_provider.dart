import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import 'auth_provider.dart';

final challengesProvider = FutureProvider<List<ChallengeModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getChallenges();
});

final dailyChallengeProvider = FutureProvider<ChallengeModel?>((ref) async {
  final challenges = await ref.watch(challengesProvider.future);
  if (challenges.isEmpty) return null;

  // Pick challenge based on day of year for rotation
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return challenges[dayOfYear % challenges.length];
});

final challengesByCategoryProvider =
    FutureProvider.family<List<ChallengeModel>, String>((ref, category) async {
  final challenges = await ref.watch(challengesProvider.future);
  return challenges.where((c) => c.category == category).toList();
});
