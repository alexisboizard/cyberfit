# CyberFit - Application Mobile de Cyber-Hygiène Gamifiée

## 🎯 Vision du Projet

Application mobile Flutter qui transforme la cybersécurité en habitude quotidienne via la gamification. L'objectif est de rendre la cyber-hygiène accessible et engageante pour le grand public, avec un système de défis quotidiens, de progression visible et de récompenses.

**Objectif MVP** : 1 mois de développement pour version fonctionnelle

## 🎮 Concept Core

**Proposition de valeur** : Ton coach cyber-hygiène quotidien qui te fait progresser pas à pas, comme Duolingo mais pour la cybersécurité.

**Public cible** : Grand public français (18-45 ans), particulièrement personnes conscientes des risques cyber mais ne sachant pas par où commencer.

## 📱 Fonctionnalités MVP

### 1. Système de Défis Quotidiens
- **1 défi par jour** (5-10 minutes max)
- Catégories variées : mots de passe, 2FA, réseaux sociaux, emails, navigation
- Exemples de défis :
  - "Active la double authentification sur un compte important"
  - "Vérifie tes paramètres de confidentialité Facebook"
  - "Identifie 3 signes de phishing dans cet email"
  - "Change un mot de passe réutilisé"
  - "Nettoie tes anciennes sessions actives Google"
  - "Active les mises à jour automatiques sur ton téléphone"

**Format défi** :
```
- Titre accrocheur
- Description courte (2-3 lignes)
- Temps estimé
- Difficulté (Facile/Moyen/Avancé)
- Points attribués
- Tutoriel step-by-step avec screenshots/illustrations
- Checkbox de validation
```

### 2. Système de Gamification

**Streaks (Séries)**
- Compteur de jours consécutifs
- Bonus de points si streak > 7 jours
- Rappel notif si risque de casser le streak

**Points & Niveaux**
- Points par défi complété (10-50 pts selon difficulté)
- Système de niveaux : Débutant → Initié → Confirmé → Expert → Maître Cyber
- Paliers tous les 500 points

**Badges**
- Badges à débloquer : "Premier pas", "Une semaine de suite", "2FA Master", "Détecteur de phishing", etc.
- Collection visible dans profil
- 15-20 badges pour MVP

### 3. Scan de Santé Cyber

**Score global /100**
Calculé sur 5 domaines :
1. **Mots de passe** (20 pts) : force, réutilisation, gestionnaire
2. **Authentification** (20 pts) : 2FA activée sur combis de comptes
3. **Confidentialité** (20 pts) : paramètres réseaux sociaux, permissions apps
4. **Emails** (20 pts) : filtres spam, reconnaissance phishing
5. **Appareils** (20 pts) : mises à jour, antivirus, chiffrement

**Questionnaire initial** (onboarding)
- 15-20 questions rapides
- Génère le score de départ
- Identifie les quick wins prioritaires
- Stocké en local + Firestore

**Évolution du score**
- Recalculé après chaque défi complété
- Graphique d'évolution temporelle
- Breakdown par domaine (radar chart)

### 4. Tutoriels & Guides Express

**Format mobile-first**
- Cartes verticales swipables
- Screenshots annotés
- Durée 2-5 minutes max
- Call-to-action clair

**Bibliothèque de guides**
- 30-40 guides pour MVP
- Searchable par mot-clé
- Filtrables par plateforme (iOS/Android/Web/Windows/Mac)
- Exemples :
  - "Activer 2FA sur Gmail"
  - "Créer un mot de passe fort"
  - "Repérer un email de phishing"
  - "Configurer un gestionnaire de mots de passe"

### 5. Dashboard de Progression

**Vue d'ensemble**
- Score actuel avec jauge visuelle
- Streak counter proéminent
- Défi du jour (card principale)
- Derniers badges débloqués
- Graphique progression 7/30 jours

**Historique**
- Liste des défis complétés (avec dates)
- Points gagnés au fil du temps
- Statistiques : total défis, catégorie préférée, temps moyen

## 🛠️ Stack Technique

### Frontend Mobile
- **Flutter 3.x** (dernière stable)
- **Dart 3.x**

### Backend & Services
- **Firebase Suite** :
  - **Authentication** : Email/password + Google Sign-In
  - **Cloud Firestore** : Base de données temps réel
  - **Cloud Messaging** : Notifications push
  - **Analytics** : Tracking usage gratuit
  - **Cloud Functions** (optionnel pour MVP) : Logique backend si besoin

### State Management
- **Riverpod** ou **Provider** (choix à valider)
- Architecture recommandée : Feature-first avec séparation models/providers/screens

### Stockage Local
- **shared_preferences** : Données simples (streak, settings)
- **Hive** ou **sqflite** (optionnel) : Cache offline des défis/guides

### Packages Flutter Essentiels

**UI/UX**
```yaml
dependencies:
  flutter_svg: ^2.0.0  # Icônes/illustrations
  fl_chart: ^0.66.0  # Graphiques progression
  animations: ^2.0.0  # Transitions fluides
  confetti: ^0.7.0  # Célébrations badges
  flutter_slidable: ^3.0.0  # Swipe actions
  shimmer: ^3.0.0  # Loading states
```

**Fonctionnalités Core**
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.8.0
  
  flutter_local_notifications: ^16.3.0  # Notifs locales
  shared_preferences: ^2.2.0
  http: ^1.2.0  # API calls
  url_launcher: ^6.2.0  # Liens externes
```

**Utilities**
```yaml
dependencies:
  intl: ^0.19.0  # Dates/nombres FR
  timeago: ^3.6.0  # "Il y a 2 heures"
  package_info_plus: ^5.0.0  # Version app
```

### APIs Externes

**HaveIBeenPwned API** (Optionnel pour MVP+)
- Endpoint : `https://haveibeenpwned.com/api/v3`
- Usage : Vérifier si email dans breaches
- Rate limit : Gratuit avec limite raisonnable
- Nécessite API key (gratuite)

## 📊 Architecture Firestore

### Collections principales

**users**
```
users/{userId}
  - email: string
  - displayName: string
  - createdAt: timestamp
  - currentScore: number (0-100)
  - currentStreak: number
  - longestStreak: number
  - totalPoints: number
  - level: string ("beginner", "initiated", etc.)
  - badges: array<string> (IDs badges débloqués)
  - onboardingCompleted: boolean
  - lastActiveDate: timestamp
  - scoreBreakdown: map
      - passwords: number
      - authentication: number
      - privacy: number
      - emails: number
      - devices: number
```

**completedChallenges** (sous-collection de users)
```
users/{userId}/completedChallenges/{challengeId}
  - challengeId: string
  - completedAt: timestamp
  - pointsEarned: number
  - category: string
```

**challenges** (collection globale)
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
  - order: number (pour rotation des défis)
```

**badges**
```
badges/{badgeId}
  - name: string
  - description: string
  - iconUrl: string
  - condition: string ("complete_first_challenge", "streak_7", etc.)
  - rarity: string ("common", "rare", "epic", "legendary")
```

**guides** (bibliothèque tutoriels)
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

## 🎨 Design System

### Palette de Couleurs (Recommandation)
```dart
// Thème principal : Moderne, rassurant, énergisant
Primary: #2563EB (Bleu confiance)
Secondary: #10B981 (Vert succès/validation)
Accent: #F59E0B (Orange énergie/gamification)
Error: #EF4444 (Rouge alerte)
Background: #F9FAFB (Gris très clair)
Surface: #FFFFFF
Text Primary: #111827
Text Secondary: #6B7280
```

### Typographie
- **Headings** : Poppins (Bold/SemiBold)
- **Body** : Inter (Regular/Medium)
- Système de tailles cohérent (12, 14, 16, 20, 24, 32, 40)

### Composants Réutilisables
- ChallengeCard (défi du jour)
- ScoreGauge (jauge circulaire score)
- StreakCounter (flamme + nombre)
- BadgeItem (badge avec état locked/unlocked)
- TutorialStep (étape de guide)
- ProgressChart (graphique évolution)
- CategoryIcon (icônes par domaine)

## 📱 Navigation & Screens

### Bottom Navigation (4 tabs)
1. **Accueil** 🏠
   - Défi du jour
   - Streak counter
   - Score actuel
   - Derniers badges

2. **Progression** 📈
   - Dashboard détaillé
   - Graphiques
   - Historique défis
   - Statistiques

3. **Guides** 📚
   - Bibliothèque tutoriels
   - Search & filters
   - Par catégorie

4. **Profil** 👤
   - Infos utilisateur
   - Collection badges
   - Paramètres
   - À propos

### Flows Principaux

**Onboarding (première utilisation)**
```
1. Welcome screen (value proposition)
2. Questionnaire scan initial (15 questions)
3. Résultats score + breakdown
4. Sélection premier défi suggéré
5. Explication système streaks/points
6. Création compte / Sign in
7. Permission notifications
```

**Complétion défi**
```
1. Voir défi du jour
2. Lire description + tutorial
3. Suivre steps
4. Marquer comme complété
5. Animation célébration + points
6. Mise à jour score
7. Badge débloqué ? → Animation spéciale
8. Suggestion next action
```

## 🚀 Plan de Développement (4 semaines)

### Semaine 1 : Fondations
**Objectif** : Setup projet + architecture + Firebase

- [ ] Init projet Flutter
- [ ] Setup Firebase (Auth, Firestore, Messaging)
- [ ] Architecture dossiers (feature-first)
- [ ] Design system (couleurs, typo, composants de base)
- [ ] State management (Riverpod setup)
- [ ] Navigation (bottom nav + routes)
- [ ] Modèles de données (User, Challenge, Badge, etc.)
- [ ] Authentification (email/password + Google)

**Livrables** : App qui boot, navigation fonctionne, auth marche

### Semaine 2 : Core Features Part 1
**Objectif** : Défis quotidiens + Scan initial

- [ ] Onboarding flow complet
- [ ] Questionnaire scan cyber (15 questions)
- [ ] Calcul score initial
- [ ] Écran Accueil (home)
- [ ] Card défi du jour
- [ ] Détail défi avec tutoriel
- [ ] Validation défi (checkbox)
- [ ] Système de points (calcul + affichage)
- [ ] Firestore : CRUD challenges
- [ ] Seed data : 15 défis minimum

**Livrables** : User peut compléter un défi, voir son score

### Semaine 3 : Core Features Part 2 + Gamification
**Objectif** : Streaks, badges, progression

- [ ] Système de streaks (compteur + logique)
- [ ] Notifications locales (rappel quotidien)
- [ ] Système de badges (conditions + déblocage)
- [ ] Animations célébration (confetti, etc.)
- [ ] Écran Progression (dashboard)
- [ ] Graphiques (fl_chart : ligne, radar)
- [ ] Historique défis complétés
- [ ] Système de niveaux (calcul + affichage)
- [ ] Écran Profil (infos + badges)
- [ ] Seed data : 10 badges minimum

**Livrables** : Gamification complète, tracking progression

### Semaine 4 : Polish + Guides + Testing
**Objectif** : Bibliothèque guides + finitions MVP

- [ ] Écran Guides (liste + search)
- [ ] Détail guide avec steps
- [ ] Filters par catégorie/plateforme
- [ ] Seed data : 30 guides minimum
- [ ] Animations/transitions (polish UI)
- [ ] Dark mode (optionnel)
- [ ] Gestion erreurs réseau
- [ ] Loading states partout
- [ ] Tests unitaires critiques
- [ ] Tests d'intégration flows principaux
- [ ] Onboarding tutorial in-app
- [ ] Page settings (notifs, compte, etc.)
- [ ] Build Android APK + iOS IPA
- [ ] Tests devices réels

**Livrables** : MVP fonctionnel, testé, buildable

## 🎯 Critères de Succès MVP

### Fonctionnel
- [ ] User peut créer compte et se connecter
- [ ] User complète onboarding et obtient score initial
- [ ] User peut faire 1 défi par jour
- [ ] Streak fonctionne et notifs rappellent
- [ ] Score évolue selon actions
- [ ] Badges se débloquent automatiquement
- [ ] Guides accessibles et searchable
- [ ] App fonctionne offline (cache local)

### Technique
- [ ] Build Android/iOS sans erreurs
- [ ] Pas de crash sur flows principaux
- [ ] Temps de chargement < 2s
- [ ] Animations fluides 60fps
- [ ] Firebase bien configuré (security rules)

### UX
- [ ] Onboarding clair (< 5 min)
- [ ] Interface intuitive (pas besoin doc)
- [ ] Feedback immédiat sur chaque action
- [ ] Célébrations engageantes
- [ ] Copywriting motivant et français

## 💰 Modèle Business (Post-MVP)

### Version Gratuite
- 3 défis par semaine
- Score de base
- 5 badges
- Guides limités (10)

### Version Premium (4,99€/mois ou 39€/an)
- Défis quotidiens illimités
- Scan avancé avec HIBP API
- Tous les badges
- Bibliothèque guides complète
- Alertes breaches en temps réel
- Support prioritaire
- Statistiques avancées

### Autres Revenus
- Partenariats (gestionnaires MDP, VPN)
- B2B : Version entreprise (sensibilisation employés)

## 📝 Content à Créer

### Défis (60 minimum pour rotation)
**Mots de passe (15)**
- Créer un mot de passe fort
- Installer un gestionnaire de MDP
- Changer un MDP réutilisé
- Activer la génération auto
- etc.

**2FA (10)**
- Activer 2FA Gmail
- Activer 2FA banque
- Sauvegarder codes de backup
- Utiliser app authenticator
- etc.

**Réseaux sociaux (10)**
- Réviser confidentialité Facebook
- Limiter audience publications Instagram
- Désactiver localisation
- Audit apps connectées
- etc.

**Emails (10)**
- Reconnaître phishing
- Activer filtres anti-spam
- Nettoyer anciennes sessions
- Vérifier forwarding rules
- etc.

**Appareils (10)**
- Activer mises à jour auto
- Chiffrer disque dur
- Configurer antivirus
- Audit permissions apps
- etc.

**Navigation (5)**
- Installer bloqueur pubs
- Configurer HTTPS everywhere
- Nettoyer cookies
- etc.

### Guides (40 minimum)
Catégories : Débutant (20), Intermédiaire (15), Avancé (5)
Plateformes : iOS, Android, Windows, Mac, Web

### Badges (20)
- Premier pas
- Série de 3/7/30 jours
- 2FA Master
- Gardien des mots de passe
- Détecteur de phishing
- Social media ninja
- 50/100/500 points
- Niveau Initié/Confirmé/Expert
- Marathonien cyber (100 défis)
- etc.

## 🔐 Sécurité & Confidentialité

### Données Sensibles
- **Pas de stockage de mots de passe** (jamais)
- User data chiffrée at rest (Firebase)
- HTTPS/TLS pour toute communication
- Auth tokens sécurisés (Firebase handles)

### RGPD Compliance
- Consentement explicite collecte data
- Export données utilisateur (feature)
- Suppression compte (anonymisation Firestore)
- Politique de confidentialité claire
- CGU/CGV

### Firebase Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /completedChallenges/{challengeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Challenges are read-only for all authenticated users
    match /challenges/{challengeId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins via console
    }
    
    // Same for badges and guides
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

## 📦 Livrables Finaux MVP

1. **Code Source**
   - Repo GitHub propre
   - README complet
   - Documentation code
   - Architecture claire

2. **Builds**
   - APK Android (release)
   - IPA iOS (TestFlight)

3. **Assets**
   - Icône app (1024x1024)
   - Splash screen
   - Screenshots stores (x6 minimum)
   - Video preview (optionnel)

4. **Documentation**
   - Guide utilisateur
   - FAQ
   - Politique confidentialité
   - CGU

5. **Marketing**
   - Landing page simple
   - Pitch deck (investisseurs)
   - Plan comm' réseaux sociaux

## 🎨 Ressources Design

### Icônes
- [Heroicons](https://heroicons.com/) - MIT license
- [Lucide](https://lucide.dev/) - ISC license
- [Phosphor Icons](https://phosphoricons.com/) - MIT

### Illustrations
- [unDraw](https://undraw.co/) - Open source
- [Storyset](https://storyset.com/) - Freemium

### Fonts
- Google Fonts (Poppins + Inter)

## 🐛 Gestion Bugs & Features

### Priorités
**P0 (Bloquant)** : Crash, auth cassée, data loss  
**P1 (Majeur)** : Feature core non fonctionnelle  
**P2 (Mineur)** : UI/UX issue, performance  
**P3 (Nice-to-have)** : Polish, améliorations

### Tools
- GitHub Issues pour tracking
- Projects board (Kanban)
- Milestones par semaine

## 🚀 Post-MVP (Roadmap 3-6 mois)

### V1.1 (1 mois post-MVP)
- Intégration HIBP API (monitoring breaches)
- Notifications push breaches
- Dark mode
- Traduction EN
- Analytics avancées

### V1.2 (2 mois post-MVP)
- Système de quiz (mini-jeux)
- Mode compétition (leaderboard amis)
- Partage progression réseaux sociaux
- Apple Sign-In
- Premium paywall (IAP)

### V1.3 (3 mois post-MVP)
- Parcours personnalisés (profils: famille, pro, gamer)
- Coach IA (suggestions basées comportement)
- Communauté (forums, Q&A)
- Widget home screen
- Version tablette optimisée

## 📞 Support & Questions

- **Dev principal** : Alexis (sys admin SDIS01, background cybersec)
- **Tech stack expertise** : Linux, Windows, GLPI, LDAP, Python, Go
- **Objectif business** : MVP viable en 1 mois, monétisation freemium

---

**Note pour Claude Code** : Ce README est ton contexte complet. Pour démarrer, setup d'abord l'environnement Flutter + Firebase, puis attaque semaine 1. Pense architecture propre (feature-first), composants réutilisables, et user experience fluide. On vise du professionnel, pas du prototype. Good luck! 🚀
