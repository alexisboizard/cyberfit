import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import 'auth_provider.dart';

final quizzesProvider = FutureProvider<List<QuizModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getQuizzes();
});

final quizzesByCategoryProvider =
    FutureProvider.family<List<QuizModel>, String>((ref, category) {
  return ref.watch(firestoreServiceProvider).getQuizzes(category: category);
});
