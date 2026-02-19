import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';

class ResultsScreen extends ConsumerWidget {
  final Map<String, int> scores;

  const ResultsScreen({super.key, required this.scores});

  int get totalScore => scores.values.fold(0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'Votre score cyber',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 32),

              // Score circle
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: totalScore / 100,
                        strokeWidth: 12,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _scoreColor(totalScore),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalScore',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: _scoreColor(totalScore),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '/100',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _scoreMessage(totalScore),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Domain breakdown
              Expanded(
                child: ListView(
                  children: scores.entries.map((entry) {
                    return _DomainScore(
                      domain: entry.key,
                      score: entry.value,
                      maxScore: 20,
                    );
                  }).toList(),
                ),
              ),

              // CTA
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(userActionsProvider)
                      .updateOnboarding(scoreBreakdown: scores);
                  if (context.mounted) context.go('/home');
                },
                child: const Text('Commencer mon premier défi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 75) return AppColors.secondary;
    if (score >= 50) return AppColors.accent;
    if (score >= 25) return AppColors.accentDark;
    return AppColors.error;
  }

  String _scoreMessage(int score) {
    if (score >= 75) return 'Excellent ! Vous avez de bons réflexes cyber.';
    if (score >= 50) return 'Pas mal ! Quelques points à améliorer.';
    if (score >= 25) return 'Il y a du travail, mais on va y arriver !';
    return 'On part de zéro, mais chaque pas compte !';
  }
}

class _DomainScore extends StatelessWidget {
  final String domain;
  final int score;
  final int maxScore;

  const _DomainScore({
    required this.domain,
    required this.score,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = score / maxScore;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _domainLabel(domain),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '$score/$maxScore',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                _domainColor(domain),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _domainLabel(String domain) {
    const labels = {
      'passwords': 'Mots de passe',
      'authentication': 'Authentification',
      'privacy': 'Confidentialité',
      'emails': 'Emails',
      'devices': 'Appareils',
    };
    return labels[domain] ?? domain;
  }

  Color _domainColor(String domain) {
    const colors = {
      'passwords': AppColors.passwords,
      'authentication': AppColors.authentication,
      'privacy': AppColors.privacy,
      'emails': AppColors.emails,
      'devices': AppColors.devices,
    };
    return colors[domain] ?? AppColors.primary;
  }
}
