import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../services/notification_service.dart';
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
              // Premium badge
              if (ref.watch(isPremiumProvider))
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Chip(
                    avatar: Icon(Icons.workspace_premium, size: 16, color: AppColors.gold),
                    label: Text('Premium'),
                    backgroundColor: Color(0x1AFFD700),
                  ),
                ),
              if (!ref.watch(isPremiumProvider))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FilledButton.icon(
                    onPressed: () => context.push('/premium'),
                    icon: const Icon(Icons.workspace_premium),
                    label: const Text('Passer Premium'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                    ),
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _showNotificationSettings(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('CyberFit Premium'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/premium');
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Politique de confidentialité'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                launchUrl(Uri.parse('https://cyberfit.app/privacy'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(ctx);
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: '${info.version} (${info.buildNumber})',
                  applicationLegalese:
                      '© ${DateTime.now().year} CyberFit. Tous droits réservés.',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Supprimer mon compte',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteAccount(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    var enabled = storage.notificationsEnabled;
    var hour = storage.reminderHour;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Rappel quotidien'),
                value: enabled,
                onChanged: (v) => setState(() => enabled = v),
              ),
              if (enabled)
                ListTile(
                  title: const Text('Heure du rappel'),
                  trailing: Text('${hour.toString().padLeft(2, '0')}:00'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay(hour: hour, minute: 0),
                    );
                    if (time != null) {
                      setState(() => hour = time.hour);
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                await storage.setNotificationsEnabled(enabled);
                await storage.setReminderHour(hour);
                if (enabled) {
                  await NotificationService.scheduleDailyReminder(
                    hour: hour,
                    minute: 0,
                  );
                } else {
                  await NotificationService.cancelAll();
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(authServiceProvider).deleteAccount();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
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
