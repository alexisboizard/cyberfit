import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class PasswordCheckerScreen extends ConsumerStatefulWidget {
  const PasswordCheckerScreen({super.key});

  @override
  ConsumerState<PasswordCheckerScreen> createState() =>
      _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends ConsumerState<PasswordCheckerScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _password => _controller.text;

  bool get _hasLower => RegExp(r'[a-z]').hasMatch(_password);
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>\-_+=\[\]\\;/~`]').hasMatch(_password);
  bool get _hasLength => _password.length >= 12;
  bool get _noCommon => !_hasCommonPattern(_password);

  bool _hasCommonPattern(String pw) {
    final lower = pw.toLowerCase();
    const patterns = [
      '123456',
      'password',
      'qwerty',
      'azerty',
      'abcdef',
      'motdepasse',
      '111111',
      'letmein',
      'admin',
      'welcome',
      'monkey',
      'dragon',
      'master',
      'iloveyou',
      'aaaaaa',
    ];
    for (final p in patterns) {
      if (lower.contains(p)) return true;
    }
    if (RegExp(r'(.)\1{3,}').hasMatch(pw)) return true;
    return false;
  }

  int _calculateScore() {
    if (_password.isEmpty) return 0;
    int score = 0;
    if (_password.length >= 8) score += 10;
    if (_password.length >= 12) score += 15;
    if (_password.length >= 16) score += 10;
    if (_hasLower) score += 10;
    if (_hasUpper) score += 15;
    if (_hasDigit) score += 10;
    if (_hasSpecial) score += 15;
    if (_noCommon) score += 15;
    return score.clamp(0, 100);
  }

  String _strengthLabel(int score) {
    if (score == 0) return '';
    if (score < 25) return 'Très faible';
    if (score < 45) return 'Faible';
    if (score < 65) return 'Moyen';
    if (score < 85) return 'Fort';
    return 'Très fort';
  }

  Color _strengthColor(int score) {
    if (score < 25) return AppColors.error;
    if (score < 45) return AppColors.streak;
    if (score < 65) return AppColors.accent;
    if (score < 85) return AppColors.secondary;
    return AppColors.secondaryDark;
  }

  String _estimateCrackTime() {
    if (_password.isEmpty) return '';
    int charsetSize = 0;
    if (_hasLower) charsetSize += 26;
    if (_hasUpper) charsetSize += 26;
    if (_hasDigit) charsetSize += 10;
    if (_hasSpecial) charsetSize += 32;
    if (charsetSize == 0) charsetSize = 26;

    final combinations = pow(charsetSize, _password.length).toDouble();
    const guessesPerSecond = 1e10;
    final seconds = combinations / guessesPerSecond;

    if (seconds < 1) return 'Instantané';
    if (seconds < 60) return '${seconds.toInt()} secondes';
    if (seconds < 3600) return '${(seconds / 60).toInt()} minutes';
    if (seconds < 86400) return '${(seconds / 3600).toInt()} heures';
    if (seconds < 86400 * 365) return '${(seconds / 86400).toInt()} jours';
    if (seconds < 86400 * 365 * 1000) {
      return '${(seconds / (86400 * 365)).toInt()} ans';
    }
    if (seconds < 86400 * 365 * 1e6) {
      return '${(seconds / (86400 * 365 * 1000)).toInt()} milliers d\'années';
    }
    return 'Des millions d\'années';
  }

  List<String> _tips() {
    final tips = <String>[];
    if (_password.isEmpty) return tips;
    if (!_hasLength) tips.add('Utilisez au moins 12 caractères');
    if (!_hasUpper) tips.add('Ajoutez des majuscules');
    if (!_hasLower) tips.add('Ajoutez des minuscules');
    if (!_hasDigit) tips.add('Ajoutez des chiffres');
    if (!_hasSpecial) tips.add('Ajoutez des caractères spéciaux (!@#\$…)');
    if (!_noCommon) tips.add('Évitez les suites et mots courants');
    if (_password.length < 16 && tips.isEmpty) {
      tips.add('Un mot de passe de 16+ caractères est idéal');
    }
    return tips;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = _calculateScore();
    final color = _strengthColor(score);
    final tips = _tips();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text('Force du mot de passe',
                      style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  // Input
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _password.isNotEmpty
                            ? color.withOpacity(0.4)
                            : theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 4),
                    child: TextFormField(
                      controller: _controller,
                      obscureText: _obscure,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: _obscure ? 2 : 0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tapez un mot de passe…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Score bar
                  if (_password.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _strengthLabel(score),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$score/100',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  height: 8,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeOutCubic,
                                            width: constraints.maxWidth *
                                                (score / 100),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  color.withOpacity(0.7),
                                                  color,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Crack time
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: color),
                          const SizedBox(width: 10),
                          Text(
                            'Temps de crack estimé : ',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            _estimateCrackTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Criteria
                    Text('Critères', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _CriteriaRow(
                      met: _hasLength,
                      label: 'Au moins 12 caractères',
                    ),
                    _CriteriaRow(met: _hasUpper, label: 'Contient des majuscules'),
                    _CriteriaRow(met: _hasLower, label: 'Contient des minuscules'),
                    _CriteriaRow(met: _hasDigit, label: 'Contient des chiffres'),
                    _CriteriaRow(
                      met: _hasSpecial,
                      label: 'Contient des caractères spéciaux',
                    ),
                    _CriteriaRow(
                      met: _noCommon,
                      label: 'Pas de suite ou mot courant',
                    ),

                    // Tips
                    if (tips.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text('Conseils', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...tips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],

                  // Disclaimer
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Aucune donnée n\'est envoyée — tout est analysé localement.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  final bool met;
  final String label;

  const _CriteriaRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: met
                  ? AppColors.secondary.withOpacity(0.12)
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                met ? Icons.check_rounded : Icons.remove_rounded,
                key: ValueKey(met),
                size: 14,
                color: met
                    ? AppColors.secondary
                    : theme.colorScheme.onSurface.withOpacity(0.25),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: met
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.45),
              fontWeight: met ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
