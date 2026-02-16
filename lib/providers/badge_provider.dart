import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

final allBadgesProvider = FutureProvider<List<BadgeModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getBadges();
});

final unlockedBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final allBadges = await ref.watch(allBadgesProvider.future);
  final user = ref.watch(userStreamProvider).value;
  if (user == null) return [];

  return allBadges.where((b) => user.badges.contains(b.id)).toList();
});

final lockedBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final allBadges = await ref.watch(allBadgesProvider.future);
  final user = ref.watch(userStreamProvider).value;
  if (user == null) return allBadges;

  return allBadges.where((b) => !user.badges.contains(b.id)).toList();
});
