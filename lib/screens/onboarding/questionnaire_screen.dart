import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class _Question {
  final String text;
  final String domain;
  final List<_Answer> answers;

  const _Question({
    required this.text,
    required this.domain,
    required this.answers,
  });
}

class _Answer {
  final String text;
  final int points;

  const _Answer({required this.text, required this.points});
}

const _questions = [
  _Question(
    text: 'Utilisez-vous un gestionnaire de mots de passe ?',
    domain: 'passwords',
    answers: [
      _Answer(text: 'Oui, pour tous mes comptes', points: 4),
      _Answer(text: 'Oui, pour certains comptes', points: 2),
      _Answer(text: 'Non, je retiens mes mots de passe', points: 1),
      _Answer(text: 'Non, j\'utilise le même partout', points: 0),
    ],
  ),
  _Question(
    text: 'Vos mots de passe font-ils plus de 12 caractères ?',
    domain: 'passwords',
    answers: [
      _Answer(text: 'Oui, toujours', points: 4),
      _Answer(text: 'La plupart du temps', points: 3),
      _Answer(text: 'Rarement', points: 1),
      _Answer(text: 'Je ne sais pas', points: 0),
    ],
  ),
  _Question(
    text: 'Changez-vous régulièrement vos mots de passe ?',
    domain: 'passwords',
    answers: [
      _Answer(text: 'Oui, tous les 3-6 mois', points: 4),
      _Answer(text: 'Quand je reçois une alerte', points: 3),
      _Answer(text: 'Rarement', points: 1),
      _Answer(text: 'Jamais', points: 0),
    ],
  ),
  _Question(
    text: 'Avez-vous activé la double authentification (2FA) ?',
    domain: 'authentication',
    answers: [
      _Answer(text: 'Oui, sur tous mes comptes importants', points: 4),
      _Answer(text: 'Oui, sur quelques comptes', points: 2),
      _Answer(text: 'Non, je ne sais pas comment faire', points: 1),
      _Answer(text: 'Non, c\'est trop compliqué', points: 0),
    ],
  ),
  _Question(
    text: 'Quel type de 2FA utilisez-vous principalement ?',
    domain: 'authentication',
    answers: [
      _Answer(text: 'App authenticator (Google Auth, etc.)', points: 4),
      _Answer(text: 'SMS', points: 2),
      _Answer(text: 'Email', points: 1),
      _Answer(text: 'Aucun', points: 0),
    ],
  ),
  _Question(
    text: 'Avez-vous sauvegardé vos codes de récupération 2FA ?',
    domain: 'authentication',
    answers: [
      _Answer(text: 'Oui, dans un endroit sécurisé', points: 4),
      _Answer(text: 'Oui, quelque part', points: 2),
      _Answer(text: 'Non', points: 0),
      _Answer(text: 'Je n\'utilise pas la 2FA', points: 0),
    ],
  ),
  _Question(
    text:
        'Avez-vous vérifié vos paramètres de confidentialité sur les réseaux sociaux ?',
    domain: 'privacy',
    answers: [
      _Answer(text: 'Oui, régulièrement', points: 4),
      _Answer(text: 'Une fois, à l\'inscription', points: 2),
      _Answer(text: 'Non, jamais', points: 0),
      _Answer(text: 'Je n\'utilise pas les réseaux sociaux', points: 4),
    ],
  ),
  _Question(
    text: 'Vérifiez-vous les permissions des apps sur votre téléphone ?',
    domain: 'privacy',
    answers: [
      _Answer(text: 'Oui, je les audite régulièrement', points: 4),
      _Answer(text: 'Parfois, quand j\'y pense', points: 2),
      _Answer(text: 'Non, j\'accepte tout', points: 0),
      _Answer(text: 'Je ne savais pas que c\'était possible', points: 0),
    ],
  ),
  _Question(
    text: 'Avez-vous désactivé le tracking publicitaire ?',
    domain: 'privacy',
    answers: [
      _Answer(text: 'Oui, partout', points: 4),
      _Answer(text: 'Sur certaines apps', points: 2),
      _Answer(text: 'Non', points: 0),
      _Answer(text: 'C\'est quoi ?', points: 0),
    ],
  ),
  _Question(
    text: 'Savez-vous reconnaître un email de phishing ?',
    domain: 'emails',
    answers: [
      _Answer(text: 'Oui, je vérifie systématiquement', points: 4),
      _Answer(text: 'Je pense que oui', points: 2),
      _Answer(text: 'Pas toujours', points: 1),
      _Answer(text: 'Non, pas vraiment', points: 0),
    ],
  ),
  _Question(
    text: 'Ouvrez-vous les pièces jointes d\'expéditeurs inconnus ?',
    domain: 'emails',
    answers: [
      _Answer(text: 'Jamais', points: 4),
      _Answer(text: 'Rarement, si ça semble important', points: 2),
      _Answer(text: 'Parfois', points: 1),
      _Answer(text: 'Oui, souvent', points: 0),
    ],
  ),
  _Question(
    text: 'Vos appareils sont-ils à jour ?',
    domain: 'devices',
    answers: [
      _Answer(text: 'Oui, mises à jour automatiques', points: 4),
      _Answer(text: 'Je mets à jour régulièrement', points: 3),
      _Answer(text: 'Quand j\'y pense', points: 1),
      _Answer(text: 'Rarement ou jamais', points: 0),
    ],
  ),
  _Question(
    text: 'Votre téléphone a-t-il un code de verrouillage ?',
    domain: 'devices',
    answers: [
      _Answer(text: 'Oui, biométrie + code', points: 4),
      _Answer(text: 'Oui, un code PIN', points: 3),
      _Answer(text: 'Juste le pattern/swipe', points: 1),
      _Answer(text: 'Non', points: 0),
    ],
  ),
  _Question(
    text: 'Faites-vous des sauvegardes de vos données ?',
    domain: 'devices',
    answers: [
      _Answer(text: 'Oui, automatiques et régulières', points: 4),
      _Answer(text: 'De temps en temps', points: 2),
      _Answer(text: 'Rarement', points: 1),
      _Answer(text: 'Jamais', points: 0),
    ],
  ),
  _Question(
    text: 'Utilisez-vous un antivirus ?',
    domain: 'devices',
    answers: [
      _Answer(text: 'Oui, mis à jour', points: 4),
      _Answer(text: 'Celui intégré au système', points: 3),
      _Answer(text: 'Oui mais pas à jour', points: 1),
      _Answer(text: 'Non', points: 0),
    ],
  ),
];

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  double get _progress => (_currentIndex + 1) / _questions.length;

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentIndex > 0
              ? () => setState(() => _currentIndex--)
              : () => context.go('/onboarding'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Question
            Text(
              question.text,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _domainLabel(question.domain),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: AppColors.primaryLight.withOpacity(0.1),
            ),
            const SizedBox(height: 24),

            // Answers
            ...question.answers.asMap().entries.map((entry) {
              final idx = entry.key;
              final answer = entry.value;
              final isSelected = _answers[_currentIndex] == idx;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectAnswer(idx),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              answer.text,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            // Next button
            if (_answers.containsKey(_currentIndex))
              ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Suivant'
                      : 'Voir mes résultats',
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentIndex] = answerIndex;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _finishQuestionnaire();
    }
  }

  void _finishQuestionnaire() {
    // Calculate scores by domain
    final Map<String, int> scores = {
      'passwords': 0,
      'authentication': 0,
      'privacy': 0,
      'emails': 0,
      'devices': 0,
    };
    final Map<String, int> maxScores = {
      'passwords': 0,
      'authentication': 0,
      'privacy': 0,
      'emails': 0,
      'devices': 0,
    };

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answerIdx = _answers[i] ?? 0;
      scores[question.domain] =
          (scores[question.domain] ?? 0) + question.answers[answerIdx].points;
      maxScores[question.domain] =
          (maxScores[question.domain] ?? 0) + 4; // Max is always 4
    }

    // Normalize to /20
    final normalized = <String, int>{};
    for (final domain in scores.keys) {
      final max = maxScores[domain] ?? 1;
      normalized[domain] = ((scores[domain]! / max) * 20).round();
    }

    context.go('/onboarding/results', extra: normalized);
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
}
