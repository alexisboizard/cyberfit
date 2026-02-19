import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/badge_model.dart';

class BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final bool unlocked;

  const BadgeItem({super.key, required this.badge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDialog(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: unlocked
                  ? _rarityColor.withOpacity(0.15)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? _rarityColor : AppColors.border,
                width: 2,
              ),
            ),
            child: Icon(
              unlocked ? Icons.emoji_events : Icons.lock_outline,
              color: unlocked ? _rarityColor : AppColors.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              unlocked ? badge.name : '???',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color get _rarityColor {
    switch (badge.rarity) {
      case 'legendary':
        return AppColors.gold;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  void _showBadgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(unlocked ? badge.name : 'Badge verrouillé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: unlocked
                    ? _rarityColor.withOpacity(0.15)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                unlocked ? Icons.emoji_events : Icons.lock_outline,
                color: unlocked ? _rarityColor : AppColors.textTertiary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(badge.description),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                AppConstants.rarityLabels[badge.rarity] ?? badge.rarity,
              ),
              backgroundColor: _rarityColor.withOpacity(0.1),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
