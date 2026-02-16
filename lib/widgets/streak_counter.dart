import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: streak > 0 ? AppColors.streak : AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              '$streak',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: streak > 0 ? AppColors.streak : AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              streak <= 1 ? 'jour' : 'jours',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Streak',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
