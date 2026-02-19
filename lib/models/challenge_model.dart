import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialStep {
  final int stepNumber;
  final String text;
  final String? imageUrl;

  const TutorialStep({
    required this.stepNumber,
    required this.text,
    this.imageUrl,
  });

  factory TutorialStep.fromMap(Map<String, dynamic> map) => TutorialStep(
        stepNumber: map['stepNumber'] ?? 0,
        text: map['text'] ?? '',
        imageUrl: map['imageUrl'],
      );

  Map<String, dynamic> toMap() => {
        'stepNumber': stepNumber,
        'text': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int points;
  final int estimatedMinutes;
  final List<TutorialStep> tutorialSteps;
  final bool isActive;
  final int order;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.points,
    this.estimatedMinutes = 5,
    this.tutorialSteps = const [],
    this.isActive = true,
    this.order = 0,
  });

  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'easy',
      points: data['points'] ?? 10,
      estimatedMinutes: data['estimatedMinutes'] ?? 5,
      tutorialSteps: (data['tutorialSteps'] as List<dynamic>?)
              ?.map((s) => TutorialStep.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'points': points,
        'estimatedMinutes': estimatedMinutes,
        'tutorialSteps': tutorialSteps.map((s) => s.toMap()).toList(),
        'isActive': isActive,
        'order': order,
      };
}

class CompletedChallenge {
  final String challengeId;
  final DateTime completedAt;
  final int pointsEarned;
  final String category;

  const CompletedChallenge({
    required this.challengeId,
    required this.completedAt,
    required this.pointsEarned,
    required this.category,
  });

  factory CompletedChallenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompletedChallenge(
      challengeId: data['challengeId'] ?? doc.id,
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pointsEarned: data['pointsEarned'] ?? 0,
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'challengeId': challengeId,
        'completedAt': Timestamp.fromDate(completedAt),
        'pointsEarned': pointsEarned,
        'category': category,
      };
}
