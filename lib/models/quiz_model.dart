import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
    question: map['question'] ?? '',
    options: List<String>.from(map['options'] ?? []),
    correctIndex: map['correctIndex'] ?? 0,
    explanation: map['explanation'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };
}

class QuizModel {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int points;
  final List<QuizQuestion> questions;
  final bool isActive;

  const QuizModel({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.points,
    required this.questions,
    this.isActive = true,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'easy',
      points: data['points'] ?? 15,
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'category': category,
    'difficulty': difficulty,
    'points': points,
    'questions': questions.map((q) => q.toMap()).toList(),
    'isActive': isActive,
  };
}
