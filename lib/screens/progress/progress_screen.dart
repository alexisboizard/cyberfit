import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../widgets/badge_item.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final unlockedBadgesAsync = ref.watch(unlockedBadgesProvider);
    final completedAsync = ref.watch(completedChallengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progression')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Chargement...'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Radar chart — score breakdown
              Text(
                'Score par domaine',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    radarBorderData: const BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                    gridBorderData: const BorderSide(
                      color: AppColors.divider,
                      width: 1,
                    ),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    tickCount: 4,
                    ticksTextStyle: const TextStyle(fontSize: 0),
                    titleTextStyle: Theme.of(context).textTheme.bodySmall!,
                    getTitle: (index, angle) {
                      final domains = AppConstants.scoreDomains;
                      if (index >= domains.length)
                        return RadarChartTitle(text: '');
                      return RadarChartTitle(
                        text:
                            AppConstants.scoreDomainLabels[domains[index]] ??
                            domains[index],
                      );
                    },
                    dataSets: [
                      RadarDataSet(
                        dataEntries: AppConstants.scoreDomains
                            .map(
                              (d) => RadarEntry(
                                value: (user.scoreBreakdown[d] ?? 0).toDouble(),
                              ),
                            )
                            .toList(),
                        borderColor: AppColors.primary,
                        fillColor: AppColors.primary.withValues(alpha: 0.2),
                        borderWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Level progress
              Text('Niveau', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.levelLabels[user.level] ?? 'Débutant',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${user.totalPoints} pts',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              (user.totalPoints % AppConstants.levelThreshold) /
                              AppConstants.levelThreshold,
                          minHeight: 10,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConstants.levelThreshold - (user.totalPoints % AppConstants.levelThreshold)} pts avant le prochain niveau',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Badges débloqués',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${user.badges.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              unlockedBadgesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur: $e'),
                data: (badges) {
                  if (badges.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Complétez des défis pour débloquer des badges !',
                          ),
                        ),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: badges
                        .map((b) => BadgeItem(badge: b, unlocked: true))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Completed challenges stats
              Text('Historique', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              completedAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur: $e'),
                data: (completed) {
                  if (completed.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('Aucun défi complété pour le moment'),
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completed.length.clamp(0, 10),
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = completed[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.secondary,
                            ),
                          ),
                          title: Text(c.challengeId),
                          subtitle: Text(
                            '${c.completedAt.day}/${c.completedAt.month}/${c.completedAt.year}',
                          ),
                          trailing: Text(
                            '+${c.pointsEarned} pts',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
