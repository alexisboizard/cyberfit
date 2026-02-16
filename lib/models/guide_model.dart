import 'package:cloud_firestore/cloud_firestore.dart';

class GuideStep {
  final int stepNumber;
  final String text;
  final String? imageUrl;

  const GuideStep({
    required this.stepNumber,
    required this.text,
    this.imageUrl,
  });

  factory GuideStep.fromMap(Map<String, dynamic> map) => GuideStep(
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

class GuideModel {
  final String id;
  final String title;
  final String category;
  final List<String> platforms;
  final int duration;
  final List<GuideStep> steps;
  final List<String> tags;
  final int views;

  const GuideModel({
    required this.id,
    required this.title,
    required this.category,
    this.platforms = const [],
    this.duration = 3,
    this.steps = const [],
    this.tags = const [],
    this.views = 0,
  });

  factory GuideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GuideModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      platforms: List<String>.from(data['platforms'] ?? []),
      duration: data['duration'] ?? 3,
      steps: (data['steps'] as List<dynamic>?)
              ?.map((s) => GuideStep.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      tags: List<String>.from(data['tags'] ?? []),
      views: data['views'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'category': category,
        'platforms': platforms,
        'duration': duration,
        'steps': steps.map((s) => s.toMap()).toList(),
        'tags': tags,
        'views': views,
      };
}
