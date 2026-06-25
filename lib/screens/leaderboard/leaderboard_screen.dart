import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../services/share_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(leaderboardTypeProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final users = leaderboardAsync.valueOrNull ?? [];
              final myIndex = users.indexWhere((u) => u.uid == currentUid);
              final rank = myIndex >= 0 ? myIndex + 1 : null;
              final typeLabel = switch (selectedType) {
                LeaderboardType.points => 'points',
                LeaderboardType.score => 'score',
                LeaderboardType.streak => 'streak',
              };
              final rankText = rank != null
                  ? 'Je suis #$rank au classement $typeLabel sur CyberFit !'
                  : 'Découvre le classement CyberFit !';
              ShareService.shareText('$rankText Rejoins-moi !');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<LeaderboardType>(
              segments: const [
                ButtonSegment(
                  value: LeaderboardType.points,
                  label: Text('Points'),
                  icon: Icon(Icons.stars, size: 18),
                ),
                ButtonSegment(
                  value: LeaderboardType.score,
                  label: Text('Score'),
                  icon: Icon(Icons.shield, size: 18),
                ),
                ButtonSegment(
                  value: LeaderboardType.streak,
                  label: Text('Streak'),
                  icon: Icon(Icons.local_fire_department, size: 18),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged: (selected) {
                ref.read(leaderboardTypeProvider.notifier).state = selected.first;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Leaderboard list
          Expanded(
            child: leaderboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.leaderboard_outlined, size: 64, color: AppColors.textTertiary),
                        SizedBox(height: 16),
                        Text('Aucun joueur pour le moment'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(leaderboardProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: users.length + (users.length >= 3 ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Podium header for top 3
                      if (users.length >= 3 && index == 0) {
                        return _Podium(
                          users: users.take(3).toList(),
                          type: selectedType,
                          currentUid: currentUid,
                        );
                      }

                      final userIndex = users.length >= 3 ? index - 1 : index;
                      final startFrom = users.length >= 3 ? 3 : 0;
                      if (userIndex < startFrom) return const SizedBox.shrink();

                      final user = users[userIndex];
                      final rank = userIndex + 1;
                      final isMe = user.uid == currentUid;

                      return _LeaderboardTile(
                        rank: rank,
                        user: user,
                        type: selectedType,
                        isMe: isMe,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<UserModel> users;
  final LeaderboardType type;
  final String? currentUid;

  const _Podium({
    required this.users,
    required this.type,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd place
            Expanded(
              child: _PodiumItem(
                rank: 2,
                user: users[1],
                type: type,
                height: 130,
                color: AppColors.silver,
                isMe: users[1].uid == currentUid,
              ),
            ),
            const SizedBox(width: 8),
            // 1st place
            Expanded(
              child: _PodiumItem(
                rank: 1,
                user: users[0],
                type: type,
                height: 170,
                color: AppColors.gold,
                isMe: users[0].uid == currentUid,
              ),
            ),
            const SizedBox(width: 8),
            // 3rd place
            Expanded(
              child: _PodiumItem(
                rank: 3,
                user: users[2],
                type: type,
                height: 100,
                color: AppColors.bronze,
                isMe: users[2].uid == currentUid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final UserModel user;
  final LeaderboardType type;
  final double height;
  final Color color;
  final bool isMe;

  const _PodiumItem({
    required this.rank,
    required this.user,
    required this.type,
    required this.height,
    required this.color,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: isMe ? AppColors.primary.withOpacity(0.2) : color.withOpacity(0.2),
          child: Text(
            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: rank == 1 ? 22 : 16,
              fontWeight: FontWeight.bold,
              color: isMe ? AppColors.primary : color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Name
        Text(
          isMe ? 'Vous' : _truncateName(user.displayName),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                color: isMe ? AppColors.primary : null,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Podium bar
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _rankEmoji(rank),
                  style: TextStyle(fontSize: rank == 1 ? 28 : 22),
                ),
                const SizedBox(height: 4),
                Text(
                  _valueForType(user, type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                Text(
                  _labelForType(type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _truncateName(String name) {
    if (name.isEmpty) return 'Anonyme';
    if (name.length <= 10) return name;
    return '${name.substring(0, 9)}…';
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final UserModel user;
  final LeaderboardType type;
  final bool isMe;

  const _LeaderboardTile({
    required this.rank,
    required this.user,
    required this.type,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isMe ? AppColors.primary.withOpacity(0.08) : null,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: isMe
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surfaceVariant,
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMe ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          isMe ? '${user.displayName} (vous)' : user.displayName.isNotEmpty ? user.displayName : 'Anonyme',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                color: isMe ? AppColors.primary : null,
              ),
        ),
        subtitle: Text(
          _levelLabel(user.level),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        trailing: Text(
          _valueForType(user, type),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isMe ? AppColors.primary : _colorForType(type),
              ),
        ),
      ),
    );
  }

  String _levelLabel(String level) {
    const labels = {
      'beginner': 'Débutant',
      'initiated': 'Initié',
      'confirmed': 'Confirmé',
      'expert': 'Expert',
      'master': 'Maître Cyber',
    };
    return labels[level] ?? 'Débutant';
  }
}

String _rankEmoji(int rank) => switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };

String _valueForType(UserModel user, LeaderboardType type) => switch (type) {
      LeaderboardType.points => '${user.totalPoints}',
      LeaderboardType.score => '${user.currentScore}/100',
      LeaderboardType.streak => '${user.currentStreak}🔥',
    };

String _labelForType(LeaderboardType type) => switch (type) {
      LeaderboardType.points => 'pts',
      LeaderboardType.score => 'score',
      LeaderboardType.streak => 'jours',
    };

Color _colorForType(LeaderboardType type) => switch (type) {
      LeaderboardType.points => AppColors.accent,
      LeaderboardType.score => AppColors.primary,
      LeaderboardType.streak => AppColors.streak,
    };
