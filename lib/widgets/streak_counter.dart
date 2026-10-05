import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = streak > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                    )
                  : null,
              color: isActive ? null : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              size: 28,
              color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$streak',
            style: theme.textTheme.displaySmall?.copyWith(
              color: isActive ? AppColors.streak : theme.colorScheme.onSurface.withOpacity(0.3),
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            streak <= 1 ? 'jour' : 'jours',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Streak',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
