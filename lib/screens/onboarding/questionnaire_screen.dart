import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class _Question {
  final String text;
  final String domain;
  final List<_Answer> answers;
  final bool multipleChoice;
  final int maxSelections;

  const _Question({
    required this.text,
    required this.domain,
    required this.answers,
    this.multipleChoice = false,
    this.maxSelections = 0,
  });
}

class _Answer {
  final String text;
  final int points;

  const _Answer({required this.text, required this.points});
}

const _questions = [
  // --- Mots de passe ---
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
    text:
        'Quels éléments incluez-vous dans vos mots de passe ? (plusieurs réponses possibles)',
    domain: 'passwords',
    multipleChoice: true,
    answers: [
      _Answer(text: 'Majuscules et minuscules', points: 1),
      _Answer(text: 'Chiffres', points: 1),
      _Answer(text: 'Caractères spéciaux (!@#\$...)', points: 1),
      _Answer(text: 'Aucun de ces éléments', points: 0),
    ],
  ),

  // --- Authentification ---
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
    text:
        'Sur quels services avez-vous activé la 2FA ? (plusieurs réponses possibles)',
    domain: 'authentication',
    multipleChoice: true,
    answers: [
      _Answer(text: 'Email principal (Gmail, Outlook...)', points: 1),
      _Answer(text: 'Réseaux sociaux', points: 1),
      _Answer(text: 'Banque en ligne', points: 1),
      _Answer(text: 'Aucun de ces services', points: 0),
    ],
  ),

  // --- Confidentialité ---
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
    text:
        'Quelles mesures de confidentialité utilisez-vous au quotidien ? (plusieurs réponses possibles)',
    domain: 'privacy',
    multipleChoice: true,
    answers: [
      _Answer(text: 'Navigation privée / VPN', points: 1),
      _Answer(text: 'Bloqueur de publicités / trackers', points: 1),
      _Answer(text: 'Refus des cookies non essentiels', points: 1),
      _Answer(text: 'Aucune de ces mesures', points: 0),
    ],
  ),

  // --- Emails ---
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
    text:
        'Quels réflexes avez-vous face à un email suspect ? (plusieurs réponses possibles)',
    domain: 'emails',
    multipleChoice: true,
    answers: [
      _Answer(text: 'Je vérifie l\'adresse de l\'expéditeur', points: 1),
      _Answer(text: 'Je ne clique jamais sur les liens suspects', points: 1),
      _Answer(text: 'Je signale les emails de phishing', points: 1),
      _Answer(text: 'Je n\'ai pas de réflexe particulier', points: 0),
    ],
  ),

  // --- Appareils ---
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
    text:
        'Quelles protections avez-vous sur vos appareils ? (plusieurs réponses possibles)',
    domain: 'devices',
    multipleChoice: true,
    answers: [
      _Answer(text: 'Antivirus à jour', points: 1),
      _Answer(text: 'Sauvegardes automatiques', points: 1),
      _Answer(text: 'Chiffrement du disque / téléphone', points: 1),
      _Answer(text: 'Aucune de ces protections', points: 0),
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
  // Single-choice answers: questionIndex -> answerIndex
  final Map<int, int> _singleAnswers = {};
  // Multiple-choice answers: questionIndex -> set of selected answer indices
  final Map<int, Set<int>> _multiAnswers = {};

  double get _progress => (_currentIndex + 1) / _questions.length;

  bool get _hasAnswered {
    final question = _questions[_currentIndex];
    if (question.multipleChoice) {
      final selected = _multiAnswers[_currentIndex];
      return selected != null && selected.isNotEmpty;
    }
    return _singleAnswers.containsKey(_currentIndex);
  }

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
            Row(
              children: [
                Chip(
                  label: Text(
                    _domainLabel(question.domain),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                ),
                if (question.multipleChoice) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text(
                      'Choix multiple',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: AppColors.accent,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Answers
            ...question.answers.asMap().entries.map((entry) {
              final idx = entry.key;
              final answer = entry.value;

              if (question.multipleChoice) {
                return _buildMultiChoiceAnswer(idx, answer);
              }
              return _buildSingleChoiceAnswer(idx, answer);
            }),

            const Spacer(),

            // Next button
            if (_hasAnswered)
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

  Widget _buildSingleChoiceAnswer(int idx, _Answer answer) {
    final isSelected = _singleAnswers[_currentIndex] == idx;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectSingleAnswer(idx),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    answer.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiChoiceAnswer(int idx, _Answer answer) {
    final selected = _multiAnswers[_currentIndex] ?? {};
    final isSelected = selected.contains(idx);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleMultiAnswer(idx),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: isSelected ? AppColors.accent : AppColors.textTertiary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    answer.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectSingleAnswer(int answerIndex) {
    setState(() {
      _singleAnswers[_currentIndex] = answerIndex;
    });
  }

  void _toggleMultiAnswer(int answerIndex) {
    setState(() {
      final current = _multiAnswers[_currentIndex] ?? {};
      final updated = Set<int>.from(current);

      // If "Aucun" option is selected (last answer with 0 points), deselect others
      final question = _questions[_currentIndex];
      final isNoneOption = question.answers[answerIndex].points == 0;

      if (isNoneOption) {
        // Selecting "none" clears all others
        updated.clear();
        updated.add(answerIndex);
      } else {
        // Remove any "none" option when selecting a real answer
        for (int i = 0; i < question.answers.length; i++) {
          if (question.answers[i].points == 0) {
            updated.remove(i);
          }
        }

        if (updated.contains(answerIndex)) {
          updated.remove(answerIndex);
        } else {
          updated.add(answerIndex);
        }
      }

      _multiAnswers[_currentIndex] = updated;
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

      if (question.multipleChoice) {
        // Sum points for all selected answers
        final selected = _multiAnswers[i] ?? {};
        int questionScore = 0;
        for (final idx in selected) {
          questionScore += question.answers[idx].points;
        }
        scores[question.domain] =
            (scores[question.domain] ?? 0) + questionScore;
        // Max for multi-choice = sum of all positive-point answers
        int maxForQuestion = 0;
        for (final answer in question.answers) {
          if (answer.points > 0) maxForQuestion += answer.points;
        }
        maxScores[question.domain] =
            (maxScores[question.domain] ?? 0) + maxForQuestion;
      } else {
        // Single choice
        final answerIdx = _singleAnswers[i] ?? 0;
        scores[question.domain] =
            (scores[question.domain] ?? 0) +
            question.answers[answerIdx].points;
        maxScores[question.domain] =
            (maxScores[question.domain] ?? 0) + 4; // Max is always 4
      }
    }

    // Normalize to /20
    final normalized = <String, int>{};
    for (final domain in scores.keys) {
      final max = maxScores[domain] ?? 1;
      normalized[domain] = max > 0
          ? ((scores[domain]! / max) * 20).round()
          : 0;
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
