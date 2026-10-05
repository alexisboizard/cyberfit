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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showBadgeDialog(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: unlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _rarityColor.withOpacity(0.2),
                        _rarityColor.withOpacity(0.05),
                      ],
                    )
                  : null,
              color: unlocked ? null : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? _rarityColor.withOpacity(0.4) : theme.dividerColor,
                width: unlocked ? 2.5 : 1.5,
              ),
            ),
            child: Icon(
              unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              color: unlocked
                  ? _rarityColor
                  : theme.colorScheme.onSurface.withOpacity(0.25),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 76,
            child: Text(
              unlocked ? badge.name : '???',
              style: theme.textTheme.bodySmall?.copyWith(
                color: unlocked
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.35),
                fontWeight: unlocked ? FontWeight.w500 : FontWeight.w400,
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
        return const Color(0xFFA855F7);
      case 'rare':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  void _showBadgeDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          unlocked ? badge.name : 'Badge verrouillé',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: unlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _rarityColor.withOpacity(0.2),
                          _rarityColor.withOpacity(0.05),
                        ],
                      )
                    : null,
                color: unlocked ? null : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                color: unlocked
                    ? _rarityColor
                    : theme.colorScheme.onSurface.withOpacity(0.25),
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _rarityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppConstants.rarityLabels[badge.rarity] ?? badge.rarity,
                style: TextStyle(
                  color: _rarityColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
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
