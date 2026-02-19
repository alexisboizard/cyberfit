import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ScoreGauge extends StatelessWidget {
  final int score;
  final double size;

  const ScoreGauge({super.key, required this.score, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: _scoreColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '/100',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Score cyber', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  Color get _scoreColor {
    if (score >= 75) return AppColors.secondary;
    if (score >= 50) return AppColors.accent;
    if (score >= 25) return AppColors.accentDark;
    return AppColors.error;
  }
}
