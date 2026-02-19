import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../widgets/badge_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final allBadgesAsync = ref.watch(allBadgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
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
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName.isNotEmpty
                          ? user.displayName
                          : 'Utilisateur',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      avatar: const Icon(Icons.star, size: 16),
                      label: Text(
                        AppConstants.levelLabels[user.level] ?? 'Débutant',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats grid
              Row(
                children: [
                  _StatTile(
                    value: '${user.currentScore}',
                    label: 'Score',
                    icon: Icons.shield,
                    color: AppColors.primary,
                  ),
                  _StatTile(
                    value: '${user.totalPoints}',
                    label: 'Points',
                    icon: Icons.stars,
                    color: AppColors.accent,
                  ),
                  _StatTile(
                    value: '${user.currentStreak}',
                    label: 'Streak',
                    icon: Icons.local_fire_department,
                    color: AppColors.streak,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Badge collection
              Text(
                'Collection de badges',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              allBadgesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur: $e'),
                data: (allBadges) {
                  if (allBadges.isEmpty) {
                    return const Text('Aucun badge disponible');
                  }
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: allBadges.map((badge) {
                      final unlocked = user.badges.contains(badge.id);
                      return BadgeItem(badge: badge, unlocked: unlocked);
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Account info
              Text('Compte', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Membre depuis'),
                      subtitle: Text(
                        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign out
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Politique de confidentialité'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Supprimer mon compte',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
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
