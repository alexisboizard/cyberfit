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
    final theme = Theme.of(context);

    return Scaffold(
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Salut ${user.displayName.isNotEmpty ? user.displayName.split(' ').first : "Champion"} !',
                                      style: theme.textTheme.displaySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Prêt pour votre défi du jour ?',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/news'),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.newspaper_rounded,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Score and streak
                          Row(
                            children: [
                              Expanded(
                                child: ScoreGauge(score: user.currentScore, size: 100),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: StreakCounter(streak: user.currentStreak)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Level banner
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppConstants.levelLabels[user.level] ?? 'Débutant',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (user.totalPoints % AppConstants.levelThreshold) /
                                              AppConstants.levelThreshold,
                                          minHeight: 5,
                                          backgroundColor: Colors.white.withOpacity(0.15),
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  '${user.totalPoints} pts',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Weekly challenge counter (free users)
                          Builder(builder: (context) {
                            final remaining = ref.watch(remainingFreeChallengesProvider);
                            final isPremium = ref.watch(isPremiumProvider);
                            if (isPremium) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GestureDetector(
                                onTap: () => context.push('/premium'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: remaining > 0
                                        ? AppColors.accent.withOpacity(0.08)
                                        : AppColors.error.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: remaining > 0
                                          ? AppColors.accent.withOpacity(0.2)
                                          : AppColors.error.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        remaining > 0
                                            ? Icons.bolt_rounded
                                            : Icons.workspace_premium_rounded,
                                        color: remaining > 0
                                            ? AppColors.accent
                                            : AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          remaining > 0
                                              ? '$remaining défis gratuits restants'
                                              : 'Limite atteinte cette semaine',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (remaining <= 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppColors.accent, AppColors.gold],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'PRO',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                              letterSpacing: 0.5,
                                            ),
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
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          dailyChallenge.when(
                            loading: () => Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, _) => Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                              ),
                              child: Text('Impossible de charger le défi: $e'),
                            ),
                            data: (challenge) {
                              if (challenge == null) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                                  ),
                                  child: const Text('Aucun défi disponible'),
                                );
                              }
                              return ChallengeCard(
                                challenge: challenge,
                                onTap: () => context.push('/challenge/${challenge.id}'),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Quick actions row
                          Text(
                            'Actions rapides',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.quiz_rounded,
                                  label: 'Quiz',
                                  color: AppColors.authentication,
                                  onTap: () => context.push('/quizzes'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.menu_book_rounded,
                                  label: 'Guides',
                                  color: AppColors.passwords,
                                  onTap: () => context.go('/guides'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.leaderboard_rounded,
                                  label: 'Classement',
                                  color: AppColors.accent,
                                  onTap: () => context.go('/leaderboard'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Stats
                          Text(
                            'Votre progression',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatCard(
                                icon: Icons.emoji_events_rounded,
                                value: '${user.badges.length}',
                                label: 'Badges',
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                icon: Icons.local_fire_department_rounded,
                                value: '${user.longestStreak}',
                                label: 'Record',
                                color: AppColors.streak,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(color: color),
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
