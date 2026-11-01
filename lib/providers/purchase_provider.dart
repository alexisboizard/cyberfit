import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/constants/app_constants.dart';
import '../services/purchase_service.dart';
import 'user_provider.dart';

final isPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(userStreamProvider).value;
  return user?.isPremium ?? false;
});

final weeklyLimitReachedProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return false;
  final weeklyCount = ref.watch(weeklyChallengeCountProvider).value ?? 0;
  return weeklyCount >= AppConstants.freeChallengesPerWeek;
});

final remainingFreeChallengesProvider = Provider<int>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return -1; // unlimited
  final weeklyCount = ref.watch(weeklyChallengeCountProvider).value ?? 0;
  return (AppConstants.freeChallengesPerWeek - weeklyCount).clamp(0, AppConstants.freeChallengesPerWeek);
});

final offeringsProvider = FutureProvider<Offerings?>((ref) {
  return PurchaseService.getOfferings();
});
