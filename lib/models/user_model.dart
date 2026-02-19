import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final int currentScore;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final String level;
  final List<String> badges;
  final bool onboardingCompleted;
  final DateTime? lastActiveDate;
  final Map<String, int> scoreBreakdown;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    required this.createdAt,
    this.currentScore = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPoints = 0,
    this.level = 'beginner',
    this.badges = const [],
    this.onboardingCompleted = false,
    this.lastActiveDate,
    this.scoreBreakdown = const {
      'passwords': 0,
      'authentication': 0,
      'privacy': 0,
      'emails': 0,
      'devices': 0,
    },
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentScore: data['currentScore'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalPoints: data['totalPoints'] ?? 0,
      level: data['level'] ?? 'beginner',
      badges: List<String>.from(data['badges'] ?? []),
      onboardingCompleted: data['onboardingCompleted'] ?? false,
      lastActiveDate:
          (data['lastActiveDate'] as Timestamp?)?.toDate(),
      scoreBreakdown:
          Map<String, int>.from(data['scoreBreakdown'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'createdAt': Timestamp.fromDate(createdAt),
        'currentScore': currentScore,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalPoints': totalPoints,
        'level': level,
        'badges': badges,
        'onboardingCompleted': onboardingCompleted,
        'lastActiveDate':
            lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
        'scoreBreakdown': scoreBreakdown,
      };

  UserModel copyWith({
    String? displayName,
    int? currentScore,
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
    String? level,
    List<String>? badges,
    bool? onboardingCompleted,
    DateTime? lastActiveDate,
    Map<String, int>? scoreBreakdown,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt,
        currentScore: currentScore ?? this.currentScore,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        totalPoints: totalPoints ?? this.totalPoints,
        level: level ?? this.level,
        badges: badges ?? this.badges,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      );
}
