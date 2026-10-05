import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../services/share_service.dart';
import '../../widgets/badge_item.dart';
import '../../widgets/share_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final allBadgesAsync = ref.watch(allBadgesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Chargement...'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        // Header with settings
                        Row(
                          children: [
                            Text('Profil', style: theme.textTheme.displaySmall),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/settings'),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.settings_rounded,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Avatar + name
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.2),
                                theme.colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.displayName.isNotEmpty
                              ? user.displayName
                              : 'Utilisateur',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(user.email, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 10),

                        // Level + premium badges
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      size: 14, color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppConstants.levelLabels[user.level] ??
                                        'Débutant',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (ref.watch(isPremiumProvider))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.accent, AppColors.gold],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium_rounded,
                                        size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            if (!ref.watch(isPremiumProvider))
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.workspace_premium_rounded,
                                  label: 'Premium',
                                  gradient: const [AppColors.accent, AppColors.gold],
                                  onTap: () => context.push('/premium'),
                                ),
                              ),
                            if (!ref.watch(isPremiumProvider))
                              const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.share_rounded,
                                label: 'Partager',
                                color: theme.colorScheme.primary,
                                onTap: () => _shareProfile(context, user),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Stats grid
                        Row(
                          children: [
                            _StatTile(
                              value: '${user.currentScore}',
                              label: 'Score',
                              icon: Icons.shield_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            _StatTile(
                              value: '${user.totalPoints}',
                              label: 'Points',
                              icon: Icons.bolt_rounded,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 10),
                            _StatTile(
                              value: '${user.currentStreak}',
                              label: 'Streak',
                              icon: Icons.local_fire_department_rounded,
                              color: AppColors.streak,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Badge collection
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Collection de badges',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 14),
                        allBadgesAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Erreur: $e'),
                          data: (allBadges) {
                            if (allBadges.isEmpty) {
                              return const Text('Aucun badge disponible');
                            }
                            return Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: allBadges.map((badge) {
                                final unlocked =
                                    user.badges.contains(badge.id);
                                return BadgeItem(
                                    badge: badge, unlocked: unlocked);
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // Account info
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Informations',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: const Text('Email'),
                                subtitle: Text(user.email),
                              ),
                              Divider(
                                height: 1,
                                indent: 56,
                                color: theme.dividerColor.withOpacity(0.3),
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_today_outlined),
                                title: const Text('Membre depuis'),
                                subtitle: Text(
                                  '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareProfile(BuildContext context, dynamic user) {
    final repaintKey = GlobalKey();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: repaintKey,
              child: ShareCard(user: user),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ShareService.shareImage(
                      repaintKey,
                      'Mon profil CyberFit : Score ${user.currentScore}/100, '
                      '${user.totalPoints} points, ${user.currentStreak} jours de streak ! '
                      'Rejoins-moi sur CyberFit !',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final List<Color>? gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(colors: gradient!)
              : null,
          color: gradient == null ? effectiveColor.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(16),
          border: gradient == null
              ? Border.all(color: effectiveColor.withOpacity(0.15))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: gradient != null ? Colors.white : effectiveColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: gradient != null ? Colors.white : effectiveColor,
              ),
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
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(color: color),
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
