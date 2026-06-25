import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/challenge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../services/share_service.dart';
import '../../widgets/tutorial_step.dart';

final _challengeProvider =
    FutureProvider.family<ChallengeModel?, String>((ref, id) {
  return ref.watch(firestoreServiceProvider).getChallenge(id);
});

final _isCompletedProvider =
    FutureProvider.family<bool, String>((ref, challengeId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Future.value(false);
  return ref
      .watch(firestoreServiceProvider)
      .isChallengeCompleted(user.uid, challengeId);
});

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  bool _completing = false;

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(_challengeProvider(widget.challengeId));
    final isCompletedAsync =
        ref.watch(_isCompletedProvider(widget.challengeId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: challengeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (challenge) {
          if (challenge == null) {
            return const Center(child: Text('Défi introuvable'));
          }

          final isCompleted = isCompletedAsync.valueOrNull ?? false;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _CategoryHeader(challenge: challenge),
                    const SizedBox(height: 16),
                    Text(
                      challenge.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(challenge: challenge),
                    const SizedBox(height: 24),
                    if (challenge.tutorialSteps.isNotEmpty) ...[
                      Text(
                        'Étapes à suivre',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ...challenge.tutorialSteps.asMap().entries.map((entry) {
                        final step = entry.value;
                        final isLast =
                            entry.key == challenge.tutorialSteps.length - 1;
                        return TutorialStepWidget(
                          stepNumber: step.stepNumber,
                          text: step.text,
                          imageUrl: step.imageUrl,
                          isLast: isLast,
                        );
                      }),
                    ],
                  ],
                ),
              ),
              _BottomBar(
                challenge: challenge,
                isCompleted: isCompleted,
                isLoading: _completing,
                onComplete: () => _completeChallenge(challenge),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _completeChallenge(ChallengeModel challenge) async {
    final limitReached = ref.read(weeklyLimitReachedProvider);
    if (limitReached) {
      context.push('/premium');
      return;
    }

    setState(() => _completing = true);
    try {
      final newBadges =
          await ref.read(userActionsProvider).completeChallenge(challenge);

      ref.invalidate(_isCompletedProvider(widget.challengeId));
      ref.invalidate(completedChallengesProvider);
      ref.invalidate(userStreamProvider);

      if (!mounted) return;

      _showCelebration(challenge, newBadges);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  void _showCelebration(ChallengeModel challenge, List<String> newBadges) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.secondary, size: 64),
              const SizedBox(height: 16),
              Text(
                'Défi complété !',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '+${challenge.points} points',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (newBadges.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Icon(Icons.emoji_events, color: AppColors.gold, size: 40),
                const SizedBox(height: 8),
                Text(
                  newBadges.length == 1
                      ? 'Badge débloqué !'
                      : '${newBadges.length} badges débloqués !',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final badgeText = newBadges.isNotEmpty
                            ? ' + badge ${newBadges.first} !'
                            : '';
                        ShareService.shareText(
                          'Je viens de compléter le défi "${challenge.title}" '
                          'sur CyberFit et j\'ai gagné ${challenge.points} points$badgeText '
                          'Rejoins-moi sur CyberFit !',
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.pop();
                      },
                      child: const Text('Continuer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final ChallengeModel challenge;

  const _CategoryHeader({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(challenge.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            AppConstants.categoryIcons[challenge.category] ?? '',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.categoryLabels[challenge.category] ??
                      challenge.category,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: color),
                ),
                Text(
                  AppConstants.difficultyLabels[challenge.difficulty] ??
                      challenge.difficulty,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, size: 16, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  '+${challenge.points} pts',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _InfoRow extends StatelessWidget {
  final ChallengeModel challenge;

  const _InfoRow({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '${challenge.estimatedMinutes} min',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 24),
        const Icon(Icons.signal_cellular_alt, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          AppConstants.difficultyLabels[challenge.difficulty] ??
              challenge.difficulty,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ChallengeModel challenge;
  final bool isCompleted;
  final bool isLoading;
  final VoidCallback onComplete;

  const _BottomBar({
    required this.challenge,
    required this.isCompleted,
    required this.isLoading,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: isCompleted
              ? FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check),
                  label: const Text('Déjà complété'),
                )
              : FilledButton(
                  onPressed: isLoading ? null : onComplete,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Marquer comme complété'),
                ),
        ),
      ),
    );
  }
}
