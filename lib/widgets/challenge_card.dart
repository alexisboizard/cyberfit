import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _categoryColor(challenge.category).withValues(alpha: 0.1),
              child: Row(
                children: [
                  Text(
                    AppConstants.categoryIcons[challenge.category] ?? '',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.categoryLabels[challenge.category] ??
                        challenge.category,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _categoryColor(challenge.category),
                        ),
                  ),
                  const Spacer(),
                  _DifficultyBadge(difficulty: challenge.difficulty),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.estimatedMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.stars_outlined,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '+${challenge.points} pts',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: onTap,
                        child: const Text('Commencer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppConstants.difficultyLabels[difficulty] ?? difficulty,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }

  Color get _color {
    switch (difficulty) {
      case 'easy':
        return AppColors.secondary;
      case 'medium':
        return AppColors.accent;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
