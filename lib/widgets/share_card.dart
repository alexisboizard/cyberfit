import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';

class ShareCard extends StatelessWidget {
  final UserModel user;
  final String? achievement;

  const ShareCard({super.key, required this.user, this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 8),
              Text(
                'CyberFit',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName.isNotEmpty ? user.displayName : 'Joueur CyberFit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),

          // Achievement text
          if (achievement != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                achievement!,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(
                value: '${user.currentScore}',
                label: 'Score',
                icon: Icons.shield,
                color: AppColors.primaryLight,
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _StatColumn(
                value: '${user.totalPoints}',
                label: 'Points',
                icon: Icons.stars,
                color: AppColors.accent,
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _StatColumn(
                value: '${user.currentStreak}',
                label: 'Streak',
                icon: Icons.local_fire_department,
                color: AppColors.streak,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.gold, size: 18),
                const SizedBox(width: 6),
                Text(
                  _levelLabel(user.level),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CTA
          Text(
            'Rejoins-moi sur CyberFit !',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
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

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
