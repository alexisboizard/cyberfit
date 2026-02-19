import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String condition;
  final String rarity;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl = '',
    required this.condition,
    this.rarity = 'common',
  });

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BadgeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      condition: data['condition'] ?? '',
      rarity: data['rarity'] ?? 'common',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'iconUrl': iconUrl,
    'condition': condition,
    'rarity': rarity,
  };
}
