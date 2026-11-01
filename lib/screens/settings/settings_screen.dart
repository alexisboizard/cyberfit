import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../main.dart';
import '../../app.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storage = ref.watch(storageServiceProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Appearance section
          _SectionHeader(title: 'Apparence'),
          _SettingsCard(
            children: [
              _ThemeTile(
                currentMode: themeMode,
                onChanged: (mode) async {
                  final modeStr = switch (mode) {
                    ThemeMode.light => 'light',
                    ThemeMode.dark => 'dark',
                    ThemeMode.system => 'system',
                  };
                  await storage.setThemeMode(modeStr);
                  ref.read(themeModeProvider.notifier).state = mode;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notifications section
          _SectionHeader(title: 'Notifications'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Rappel quotidien',
                subtitle: 'Recevez un rappel pour votre défi',
                value: storage.notificationsEnabled,
                onChanged: (v) async {
                  await storage.setNotificationsEnabled(v);
                  if (v) {
                    await NotificationService.scheduleDailyReminder(
                      hour: storage.reminderHour,
                      minute: storage.reminderMinute,
                    );
                  } else {
                    await NotificationService.cancelAll();
                  }
                },
              ),
              if (storage.notificationsEnabled) ...[
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.access_time_outlined),
                  title: const Text('Heure du rappel'),
                  trailing: Text(
                    '${storage.reminderHour.toString().padLeft(2, '0')}:${storage.reminderMinute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: storage.reminderHour,
                        minute: storage.reminderMinute,
                      ),
                    );
                    if (time != null) {
                      await storage.setReminderHour(time.hour);
                      await storage.setReminderMinute(time.minute);
                      await NotificationService.scheduleDailyReminder(
                        hour: time.hour,
                        minute: time.minute,
                      );
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Subscription section
          _SectionHeader(title: 'Abonnement'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.workspace_premium_rounded),
                title: const Text('CyberFit Premium'),
                subtitle: const Text('Défis illimités, tous les badges'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/premium'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About section
          _SectionHeader(title: 'À propos'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Politique de confidentialité'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(Uri.parse('https://cyberfit.app/privacy')),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Conditions d\'utilisation'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(Uri.parse('https://cyberfit.app/terms')),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                trailing: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (ctx, snap) => Text(
                    snap.hasData
                        ? '${snap.data!.version} (${snap.data!.buildNumber})'
                        : '...',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danger zone
          _SectionHeader(title: 'Compte'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Se déconnecter'),
                onTap: () => _confirmSignOut(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                title: Text(
                  'Supprimer mon compte',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous pourrez vous reconnecter à tout moment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Déconnexion'),
          ),
        ],
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined),
              const SizedBox(width: 16),
              Text('Thème', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ThemeOption(
                icon: Icons.phone_android_rounded,
                label: 'Système',
                selected: currentMode == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
              ),
              const SizedBox(width: 10),
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                label: 'Clair',
                selected: currentMode == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const SizedBox(width: 10),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                label: 'Sombre',
                selected: currentMode == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.4),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
    );
  }
}
