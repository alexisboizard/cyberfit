import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/smart_notification_provider.dart';
import '../../widgets/challenge_card.dart';
import '../../widgets/score_gauge.dart';
import '../../widgets/streak_counter.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final dailyChallenge = ref.watch(dailyChallengeProvider);
    ref.watch(smartNotificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userStreamProvider);
              ref.invalidate(dailyChallengeProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Greeting
                Text(
                  'Salut ${user.displayName.isNotEmpty ? user.displayName : "Champion"} !',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Prêt pour votre défi du jour ?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Score and streak row
                Row(
                  children: [
                    Expanded(
                      child: ScoreGauge(score: user.currentScore, size: 100),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: StreakCounter(streak: user.currentStreak)),
                  ],
                ),
                const SizedBox(height: 24),

                // Level indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.levelLabels[user.level] ??
                                  'Débutant',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              '${user.totalPoints} points',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${user.totalPoints % AppConstants.levelThreshold}/${AppConstants.levelThreshold}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Weekly challenge counter
                Builder(builder: (context) {
                  final remaining = ref.watch(remainingFreeChallengesProvider);
                  final isPremium = ref.watch(isPremiumProvider);
                  if (isPremium) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => context.push('/premium'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: remaining > 0
                              ? AppColors.gold.withOpacity(0.08)
                              : AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: remaining > 0
                                ? AppColors.gold.withOpacity(0.3)
                                : AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              remaining > 0
                                  ? Icons.bolt
                                  : Icons.workspace_premium,
                              color: remaining > 0
                                  ? AppColors.gold
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                remaining > 0
                                    ? '$remaining défis gratuits restants cette semaine'
                                    : 'Limite hebdomadaire atteinte',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            if (remaining <= 0)
                              const Text(
                                'Premium',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Daily challenge
                Text(
                  'Défi du jour',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                dailyChallenge.when(
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (e, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Impossible de charger le défi: $e'),
                    ),
                  ),
                  data: (challenge) {
                    if (challenge == null) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aucun défi disponible pour le moment'),
                        ),
                      );
                    }
                    return ChallengeCard(
                      challenge: challenge,
                      onTap: () => context.push('/challenge/${challenge.id}'),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick stats
                Text(
                  'Votre progression',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.emoji_events,
                      value: '${user.badges.length}',
                      label: 'Badges',
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.local_fire_department,
                      value: '${user.longestStreak}',
                      label: 'Meilleur streak',
                      color: AppColors.streak,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: color),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
