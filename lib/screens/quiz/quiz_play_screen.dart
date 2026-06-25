import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/quiz_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/share_service.dart';

final _quizProvider = FutureProvider.family<QuizModel?, String>((ref, id) {
  return ref.watch(firestoreServiceProvider).getQuiz(id);
});

class QuizPlayScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizPlayScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(_quizProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (quiz) {
          if (quiz == null) {
            return const Center(child: Text('Quiz introuvable'));
          }

          if (_finished) {
            return _ResultsView(
              quiz: quiz,
              score: _score,
              total: quiz.questions.length,
              onRetry: () => setState(() {
                _currentIndex = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
                _finished = false;
              }),
            );
          }

          final question = quiz.questions[_currentIndex];
          final isLast = _currentIndex == quiz.questions.length - 1;

          return Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1}/${quiz.questions.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '$_score correct${_score > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / quiz.questions.length,
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Question
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isCorrect = index == question.correctIndex;
                      final isSelected = _selectedAnswer == index;

                      Color? bgColor;
                      Color? borderColor;
                      IconData? trailingIcon;

                      if (_answered) {
                        if (isCorrect) {
                          bgColor = AppColors.secondary.withOpacity(0.1);
                          borderColor = AppColors.secondary;
                          trailingIcon = Icons.check_circle;
                        } else if (isSelected) {
                          bgColor = AppColors.error.withOpacity(0.1);
                          borderColor = AppColors.error;
                          trailingIcon = Icons.cancel;
                        }
                      } else if (isSelected) {
                        bgColor = AppColors.primary.withOpacity(0.1);
                        borderColor = AppColors.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: _answered ? null : () => setState(() => _selectedAnswer = index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor ?? AppColors.border,
                                width: isSelected || (_answered && isCorrect) ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected && !_answered
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected && !_answered
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(option)),
                                if (trailingIcon != null)
                                  Icon(
                                    trailingIcon,
                                    color: isCorrect ? AppColors.secondary : AppColors.error,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Explanation
                    if (_answered) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.explanation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom action
              Container(
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _answered
                        ? FilledButton(
                            onPressed: () {
                              if (isLast) {
                                _finishQuiz(quiz);
                              } else {
                                setState(() {
                                  _currentIndex++;
                                  _selectedAnswer = null;
                                  _answered = false;
                                });
                              }
                            },
                            child: Text(isLast ? 'Voir les résultats' : 'Suivant'),
                          )
                        : FilledButton(
                            onPressed: _selectedAnswer != null
                                ? () {
                                    final correct = _selectedAnswer == question.correctIndex;
                                    setState(() {
                                      _answered = true;
                                      if (correct) _score++;
                                    });
                                  }
                                : null,
                            child: const Text('Valider'),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _finishQuiz(QuizModel quiz) async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid != null) {
      final earnedPoints = (_score * quiz.points) ~/ quiz.questions.length;
      await ref.read(firestoreServiceProvider).addCompletedQuiz(
            uid, quiz.id, _score, quiz.questions.length);
      if (earnedPoints > 0) {
        final firestore = ref.read(firestoreServiceProvider);
        final user = await firestore.getUser(uid);
        if (user != null) {
          await firestore.updateUser(uid, {
            'totalPoints': user.totalPoints + earnedPoints,
          });
        }
      }
      ref.invalidate(userStreamProvider);
    }
    setState(() => _finished = true);
  }
}

class _ResultsView extends StatelessWidget {
  final QuizModel quiz;
  final int score;
  final int total;
  final VoidCallback onRetry;

  const _ResultsView({
    required this.quiz,
    required this.score,
    required this.total,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();
    final isPerfect = score == total;
    final earnedPoints = (score * quiz.points) ~/ total;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPerfect ? Icons.emoji_events : score >= total / 2 ? Icons.thumb_up : Icons.school,
              size: 72,
              color: isPerfect ? AppColors.gold : score >= total / 2 ? AppColors.secondary : AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              isPerfect ? 'Parfait !' : score >= total / 2 ? 'Bien joué !' : 'Continuez d\'apprendre !',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '$score/$total réponses correctes ($percentage%)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$earnedPoints points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ShareService.shareText(
                      'J\'ai obtenu $score/$total au quiz "${quiz.title}" sur CyberFit ! '
                      'Teste tes connaissances en cybersécurité toi aussi !',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Terminer'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Recommencer'),
            ),
          ],
        ),
      ),
    );
  }
}
