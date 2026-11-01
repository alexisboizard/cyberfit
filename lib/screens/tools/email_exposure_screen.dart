import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class EmailExposureScreen extends ConsumerStatefulWidget {
  const EmailExposureScreen({super.key});

  @override
  ConsumerState<EmailExposureScreen> createState() =>
      _EmailExposureScreenState();
}

class _EmailExposureScreenState extends ConsumerState<EmailExposureScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  List<Map<String, dynamic>>? _results;

  static final _simulatedBreaches = <Map<String, dynamic>>[
    {
      'service': 'LinkedIn',
      'date': '2021',
      'records': '700M',
      'data': ['Email', 'Nom', 'Téléphone'],
    },
    {
      'service': 'Adobe',
      'date': '2013',
      'records': '153M',
      'data': ['Email', 'Mot de passe', 'Indice'],
    },
    {
      'service': 'Canva',
      'date': '2019',
      'records': '137M',
      'data': ['Email', 'Nom', 'Ville'],
    },
    {
      'service': 'Dropbox',
      'date': '2012',
      'records': '68M',
      'data': ['Email', 'Mot de passe'],
    },
    {
      'service': 'Deezer',
      'date': '2022',
      'records': '229M',
      'data': ['Email', 'Nom', 'Date de naissance', 'IP'],
    },
    {
      'service': 'Dailymotion',
      'date': '2016',
      'records': '85M',
      'data': ['Email', "Nom d'utilisateur", 'Mot de passe'],
    },
    {
      'service': 'MyFitnessPal',
      'date': '2018',
      'records': '144M',
      'data': ['Email', 'Nom', 'Mot de passe'],
    },
    {
      'service': 'Wattpad',
      'date': '2020',
      'records': '270M',
      'data': ['Email', 'Nom', 'Date de naissance'],
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _results = null;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final email = _emailController.text.trim().toLowerCase();
    final domain = email.split('@').last;
    final rng = Random(email.hashCode);
    final shuffled = List<Map<String, dynamic>>.from(_simulatedBreaches)
      ..shuffle(rng);

    final int count;
    if (domain == 'gmail.com' || domain == 'outlook.com' || domain == 'hotmail.com') {
      count = 2 + rng.nextInt(3); // 2-4
    } else {
      count = rng.nextInt(3); // 0-2
    }

    setState(() {
      _loading = false;
      _results = shuffled.take(count).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text('Email Exposure',
                      style: theme.textTheme.displaySmall),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Demo banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mode démo — Connectez un compte premium pour des résultats réels',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email form
                    Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                hintText: 'votre@email.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email requis';
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'Email invalide';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _checkEmail(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _checkEmail,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Vérifier'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // States
                    if (_loading) _buildLoadingState(theme),
                    if (!_loading && _results == null) _buildEmptyState(theme),
                    if (!_loading && _results != null) _buildResults(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.shield_outlined,
                  size: 40, color: AppColors.primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              'Vérifiez votre exposition',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Entrez votre adresse email pour savoir\nsi elle apparaît dans des fuites de données.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Analyse en cours...', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Recherche dans les bases de données connues',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final breaches = _results!;
    final hasBreaches = breaches.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk indicator
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: hasBreaches
                ? AppColors.error.withOpacity(0.06)
                : AppColors.secondary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasBreaches
                  ? AppColors.error.withOpacity(0.15)
                  : AppColors.secondary.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (hasBreaches ? AppColors.error : AppColors.secondary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasBreaches
                      ? Icons.warning_amber_rounded
                      : Icons.verified_user_rounded,
                  color:
                      hasBreaches ? AppColors.error : AppColors.secondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasBreaches
                          ? '${breaches.length} fuite${breaches.length > 1 ? 's' : ''} détectée${breaches.length > 1 ? 's' : ''}'
                          : 'Aucune fuite détectée',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: hasBreaches
                            ? AppColors.error
                            : AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasBreaches
                          ? 'Votre email a été trouvé dans des fuites connues.'
                          : 'Votre email n\'apparaît dans aucune fuite connue.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Breach list
        if (hasBreaches) ...[
          Text('Détails des fuites', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ...breaches.map((breach) => _BreachTile(breach: breach)),
          const SizedBox(height: 24),
        ],

        // Recommendations
        Text('Recommandations', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _RecommendationTile(
          icon: Icons.lock_reset_rounded,
          color: AppColors.passwords,
          text: 'Changez vos mots de passe sur les services concernés',
        ),
        _RecommendationTile(
          icon: Icons.security_rounded,
          color: AppColors.authentication,
          text: 'Activez la double authentification (2FA)',
        ),
        _RecommendationTile(
          icon: Icons.key_rounded,
          color: AppColors.primary,
          text: 'Utilisez un gestionnaire de mots de passe',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _BreachTile extends StatelessWidget {
  final Map<String, dynamic> breach;

  const _BreachTile({required this.breach});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataList = breach['data'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (breach['service'] as String)[0],
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breach['service'] as String,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${breach['date']} • ${breach['records']} comptes',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: dataList
                .map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isPasswordData(d as String)
                            ? AppColors.error.withOpacity(0.08)
                            : AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isPasswordData(d)
                              ? AppColors.error
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  bool _isPasswordData(String label) =>
      label.toLowerCase().contains('mot de passe');
}

class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _RecommendationTile({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
