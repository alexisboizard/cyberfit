import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Hero illustration placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Bienvenue sur CyberFit',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Votre coach cyber au quotidien.\n'
                'En quelques minutes par jour, adoptez les bons réflexes '
                'pour protéger votre vie numérique.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Features list
              _FeatureItem(
                icon: Icons.today,
                title: '1 défi par jour',
                subtitle: '5-10 min pour progresser',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.emoji_events,
                title: 'Gagnez des badges',
                subtitle: 'Points, niveaux et récompenses',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.health_and_safety,
                title: 'Score de santé cyber',
                subtitle: 'Suivez votre progression',
              ),

              const Spacer(),

              // CTA
              ElevatedButton(
                onPressed: () => context.go('/onboarding/questionnaire'),
                child: const Text('Commencer le diagnostic'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Passer pour le moment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
