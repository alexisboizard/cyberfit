import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/quiz_provider.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Column(
        children: [
          // Category filters
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _selectedCategory == null,
                  onSelected: () => setState(() => _selectedCategory = null),
                ),
                ...AppConstants.categories.map(
                  (cat) => _FilterChip(
                    label: AppConstants.categoryLabels[cat] ?? cat,
                    selected: _selectedCategory == cat,
                    onSelected: () => setState(() => _selectedCategory = cat),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quiz list
          Expanded(
            child: quizzesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (quizzes) {
                final filtered = _selectedCategory != null
                    ? quizzes.where((q) => q.category == _selectedCategory).toList()
                    : quizzes;

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz_outlined, size: 64, color: AppColors.textTertiary),
                        SizedBox(height: 16),
                        Text('Aucun quiz disponible'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final quiz = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _categoryColor(quiz.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppConstants.categoryIcons[quiz.category] ?? '📝',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          quiz.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.help_outline, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                '${quiz.questions.length} questions',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.stars, size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '${quiz.points} pts',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.accent,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/quiz/${quiz.id}'),
                      ),
                    );
                  },
                );
              },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
