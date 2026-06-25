import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/challenge_model.dart';
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
              // Summary stats cards
              Row(
                children: [
                  _MiniStat(
                    label: 'Score',
                    value: '${user.currentScore}/100',
                    icon: Icons.shield,
                    color: AppColors.primary,
                  ),
                  _MiniStat(
                    label: 'Points',
                    value: '${user.totalPoints}',
                    icon: Icons.stars,
                    color: AppColors.accent,
                  ),
                  _MiniStat(
                    label: 'Streak',
                    value: '${user.currentStreak}',
                    icon: Icons.local_fire_department,
                    color: AppColors.streak,
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                        fillColor: AppColors.primary.withOpacity(0.2),
                        borderWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Domain breakdown list
              ...AppConstants.scoreDomains.map((domain) {
                final score = user.scoreBreakdown[domain] ?? 0;
                final color = _domainColor(domain);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppConstants.scoreDomainLabels[domain] ?? domain,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: score / 20,
                            minHeight: 8,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$score/20',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Weekly activity chart
              completedAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (completed) {
                  if (completed.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activité (7 derniers jours)',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: _WeeklyChart(completed: completed),
                      ),
                      const SizedBox(height: 24),

                      // Category breakdown
                      Text(
                        'Défis par catégorie',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _CategoryBreakdown(completed: completed),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

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

              // Detailed stats
              Text(
                'Statistiques',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Meilleur streak',
                      value: '${user.longestStreak} jours',
                      icon: Icons.local_fire_department,
                      color: AppColors.streak,
                    ),
                    const Divider(height: 1),
                    completedAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (completed) => _DetailRow(
                        label: 'Défis complétés',
                        value: '${completed.length}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.secondary,
                      ),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: 'Badges collectés',
                      value: '${user.badges.length}',
                      icon: Icons.emoji_events,
                      color: AppColors.gold,
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: 'Membre depuis',
                      value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                      icon: Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                  ],
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

              // Completed challenges history
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
                            backgroundColor: AppColors.secondary.withOpacity(0.1),
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

  Color _domainColor(String domain) {
    const colors = {
      'passwords': AppColors.passwords,
      'authentication': AppColors.authentication,
      'privacy': AppColors.privacy,
      'emails': AppColors.emails,
      'devices': AppColors.devices,
    };
    return colors[domain] ?? AppColors.primary;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<CompletedChallenge> completed;

  const _WeeklyChart({required this.completed});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateTime(day.year, day.month, day.day);
    });

    final counts = days.map((day) {
      return completed.where((c) {
        final d = DateTime(c.completedAt.year, c.completedAt.month, c.completedAt.day);
        return d == day;
      }).length.toDouble();
    }).toList();

    final maxY = counts.reduce((a, b) => a > b ? a : b);

    const dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY < 1 ? 1 : maxY) + 1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                final weekday = days[idx].weekday;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dayLabels[weekday - 1],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: counts.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: entry.value > 0 ? AppColors.primary : AppColors.surfaceVariant,
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<CompletedChallenge> completed;

  const _CategoryBreakdown({required this.completed});

  @override
  Widget build(BuildContext context) {
    final categoryCounts = <String, int>{};
    for (final c in completed) {
      categoryCounts[c.category] = (categoryCounts[c.category] ?? 0) + 1;
    }

    if (categoryCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = categoryCounts.values.reduce((a, b) => a > b ? a : b);

    final sorted = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sorted.map((entry) {
            final color = _categoryColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      AppConstants.categoryIcons[entry.key] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppConstants.categoryLabels[entry.key] ?? entry.key,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / maxCount,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    const colors = {
      'passwords': AppColors.passwords,
      'authentication': AppColors.authentication,
      'social': AppColors.privacy,
      'email': AppColors.emails,
      'device': AppColors.devices,
      'navigation': AppColors.primary,
    };
    return colors[category] ?? AppColors.primary;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
