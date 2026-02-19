import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/tutorial_step.dart';

class GuideDetailScreen extends ConsumerWidget {
  final String guideId;

  const GuideDetailScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.read(firestoreServiceProvider);

    return FutureBuilder(
      future: firestore.getGuide(guideId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final guide = snapshot.data;
        if (guide == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Guide non trouvé')),
          );
        }

        // Increment view count
        firestore.incrementGuideViews(guideId);

        return Scaffold(
          appBar: AppBar(
            title: Text(guide.title),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Meta info
              Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${guide.duration} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.visibility_outlined,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${guide.views} vues',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: guide.platforms.map((p) {
                  return Chip(
                    label: Text(p),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Steps
              ...guide.steps.asMap().entries.map((entry) {
                return TutorialStepWidget(
                  stepNumber: entry.key + 1,
                  text: entry.value.text,
                  imageUrl: entry.value.imageUrl,
                  isLast: entry.key == guide.steps.length - 1,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
