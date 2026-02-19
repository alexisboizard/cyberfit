# Architecture technique — CyberFit

## Stack

### Frontend mobile
- **Flutter 3.x** (dernière stable)
- **Dart 3.x**

### Backend et services
- **Firebase Authentication** : email/password + Google Sign-In
- **Cloud Firestore** : base de données temps réel
- **Cloud Messaging** : notifications push
- **Firebase Analytics** : tracking usage
- **Cloud Functions** (optionnel MVP) : logique backend si besoin

### State management
- **Riverpod**
- Architecture feature-first avec séparation models / providers / screens

### Stockage local
- **shared_preferences** : données simples (streak, settings)
- **Hive** (optionnel) : cache offline des défis/guides

---

## Packages Flutter

### UI/UX
```yaml
flutter_svg: ^2.0.0          # Icônes et illustrations
fl_chart: ^0.66.0            # Graphiques de progression
animations: ^2.0.0           # Transitions fluides
confetti: ^0.7.0             # Célébrations badges
flutter_slidable: ^3.0.0     # Swipe actions
shimmer: ^3.0.0              # Loading states
```

### Core
```yaml
firebase_core: ^2.24.0
firebase_auth: ^4.16.0
cloud_firestore: ^4.14.0
firebase_messaging: ^14.7.0
firebase_analytics: ^10.8.0
flutter_local_notifications: ^16.3.0
shared_preferences: ^2.2.0
http: ^1.2.0
url_launcher: ^6.2.0
```

### Utilitaires
```yaml
intl: ^0.19.0                # Dates/nombres FR
timeago: ^3.6.0              # "Il y a 2 heures"
package_info_plus: ^5.0.0    # Version app
```

---

## APIs externes

### HaveIBeenPwned (post-MVP)
- Endpoint : `https://haveibeenpwned.com/api/v3`
- Usage : vérifier si un email apparaît dans des breaches
- API key gratuite requise

---

## Schéma Firestore

### Collection `users`
```
users/{userId}
  - email: string
  - displayName: string
  - createdAt: timestamp
  - currentScore: number (0-100)
  - currentStreak: number
  - longestStreak: number
  - totalPoints: number
  - level: string ("beginner", "initiated", "confirmed", "expert", "master")
  - badges: array<string>
  - onboardingCompleted: boolean
  - lastActiveDate: timestamp
  - scoreBreakdown: map
      - passwords: number
      - authentication: number
      - privacy: number
      - emails: number
      - devices: number
```

### Sous-collection `completedChallenges`
```
users/{userId}/completedChallenges/{challengeId}
  - challengeId: string
  - completedAt: timestamp
  - pointsEarned: number
  - category: string
```

### Collection `challenges`
```
challenges/{challengeId}
  - title: string
  - description: string
  - category: string ("passwords", "2fa", "social", "email", "device")
  - difficulty: string ("easy", "medium", "hard")
  - points: number
  - estimatedMinutes: number
  - tutorialSteps: array<map>
      - stepNumber: number
      - text: string
      - imageUrl: string (optionnel)
  - isActive: boolean
  - order: number
```

### Collection `badges`
```
badges/{badgeId}
  - name: string
  - description: string
  - iconUrl: string
  - condition: string ("complete_first_challenge", "streak_7", etc.)
  - rarity: string ("common", "rare", "epic", "legendary")
```

### Collection `guides`
```
guides/{guideId}
  - title: string
  - category: string
  - platform: array<string> (["ios", "android", "web"])
  - duration: number (minutes)
  - steps: array<map>
  - tags: array<string>
  - views: number
```

---

## Design system

### Palette de couleurs
```dart
Primary:        #2563EB  // Bleu confiance
Secondary:      #10B981  // Vert succès/validation
Accent:         #F59E0B  // Orange énergie/gamification
Error:          #EF4444  // Rouge alerte
Background:     #F9FAFB  // Gris très clair
Surface:        #FFFFFF
Text Primary:   #111827
Text Secondary: #6B7280
```

### Typographie
- **Headings** : Poppins (Bold / SemiBold)
- **Body** : Inter (Regular / Medium)
- Échelle : 12, 14, 16, 20, 24, 32, 40

### Composants réutilisables
- `ChallengeCard` — défi du jour
- `ScoreGauge` — jauge circulaire score
- `StreakCounter` — flamme + nombre
- `BadgeItem` — badge locked/unlocked
- `TutorialStep` — étape de guide
- `ProgressChart` — graphique évolution
- `CategoryIcon` — icônes par domaine

---

## Sécurité et confidentialité

### Données sensibles
- **Aucun stockage de mots de passe** (jamais)
- Données chiffrées at rest (Firebase)
- HTTPS/TLS pour toute communication
- Auth tokens gérés par Firebase

### RGPD
- Consentement explicite à la collecte de données
- Export des données utilisateur
- Suppression de compte (anonymisation Firestore)
- Politique de confidentialité
- CGU/CGV

### Firebase Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /completedChallenges/{challengeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    match /challenges/{challengeId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    match /badges/{badgeId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    match /guides/{guideId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## Ressources design

### Icônes
- [Heroicons](https://heroicons.com/) — MIT
- [Lucide](https://lucide.dev/) — ISC
- [Phosphor Icons](https://phosphoricons.com/) — MIT

### Illustrations
- [unDraw](https://undraw.co/) — Open source
- [Storyset](https://storyset.com/) — Freemium

### Fonts
- Google Fonts : Poppins + Inter
