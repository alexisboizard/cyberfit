import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TutorialStepWidget extends StatefulWidget {
  final int stepNumber;
  final String text;
  final String? imageUrl;
  final bool isLast;

  const TutorialStepWidget({
    super.key,
    required this.stepNumber,
    required this.text,
    this.imageUrl,
    this.isLast = false,
  });

  @override
  State<TutorialStepWidget> createState() => _TutorialStepWidgetState();
}

class _TutorialStepWidgetState extends State<TutorialStepWidget> {
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _completed = !_completed),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _completed
                        ? AppColors.secondary
                        : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: _completed
                        ? null
                        : Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Center(
                    child: _completed
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : Text(
                            '${widget.stepNumber}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                  ),
                ),
              ),
              if (!widget.isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: _completed ? AppColors.secondary : AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: _completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: _completed
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                ),
                if (widget.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
