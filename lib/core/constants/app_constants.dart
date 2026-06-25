abstract final class AppConstants {
  // App
  static const appName = 'CyberFit';

  // Scoring
  static const maxScore = 100;
  static const domainsCount = 5;
  static const pointsPerDomain = 20;

  // Points per difficulty
  static const pointsEasy = 10;
  static const pointsMedium = 25;
  static const pointsHard = 50;

  // Levels
  static const levelThreshold = 500;
  static const levels = [
    'beginner',
    'initiated',
    'confirmed',
    'expert',
    'master',
  ];
  static const levelLabels = {
    'beginner': 'Débutant',
    'initiated': 'Initié',
    'confirmed': 'Confirmé',
    'expert': 'Expert',
    'master': 'Maître Cyber',
  };

  // Streaks
  static const streakBonusThreshold = 7;
  static const streakBonusMultiplier = 1.5;

  // Challenge categories
  static const categories = [
    'passwords',
    'authentication',
    'social',
    'email',
    'device',
    'navigation',
  ];

  static const categoryLabels = {
    'passwords': 'Mots de passe',
    'authentication': '2FA',
    'social': 'Réseaux sociaux',
    'email': 'Emails',
    'device': 'Appareils',
    'navigation': 'Navigation',
  };

  static const categoryIcons = {
    'passwords': '🔑',
    'authentication': '🛡️',
    'social': '📱',
    'email': '📧',
    'device': '💻',
    'navigation': '🌐',
  };

  // Difficulties
  static const difficulties = ['easy', 'medium', 'hard'];
  static const difficultyLabels = {
    'easy': 'Facile',
    'medium': 'Moyen',
    'hard': 'Avancé',
  };

  // Badge rarities
  static const rarityLabels = {
    'common': 'Commun',
    'rare': 'Rare',
    'epic': 'Épique',
    'legendary': 'Légendaire',
  };

  // Freemium limits
  static const freeChallengesPerWeek = 3;
  static const freeBadgesLimit = 5;
  static const freeGuidesLimit = 10;

  // RevenueCat (replace with real keys before publishing)
  static const revenueCatAppleApiKey = 'your_apple_api_key';
  static const revenueCatGoogleApiKey = 'your_google_api_key';
  static const premiumEntitlementId = 'premium';

  // Firestore collections
  static const usersCollection = 'users';
  static const challengesCollection = 'challenges';
  static const badgesCollection = 'badges';
  static const guidesCollection = 'guides';
  static const quizzesCollection = 'quizzes';
  static const completedQuizzesSubcollection = 'completedQuizzes';
  static const completedChallengesSubcollection = 'completedChallenges';

  // Score domains
  static const scoreDomains = [
    'passwords',
    'authentication',
    'privacy',
    'emails',
    'devices',
  ];
  static const scoreDomainLabels = {
    'passwords': 'Mots de passe',
    'authentication': 'Authentification',
    'privacy': 'Confidentialité',
    'emails': 'Emails',
    'devices': 'Appareils',
  };
}
