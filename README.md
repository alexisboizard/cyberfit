# CyberFit

Application mobile Flutter de cyber-hygiène gamifiée. Un coach quotidien qui transforme la cybersécurité en habitude, comme Duolingo mais pour la sécurité numérique.

**Public cible** : Grand public français (18-45 ans), personnes conscientes des risques cyber mais ne sachant pas par où commencer.

## Fonctionnalités

- **Défis quotidiens** : 1 défi par jour (5-10 min) avec tutoriels step-by-step — mots de passe, 2FA, réseaux sociaux, emails, appareils
- **Gamification** : streaks, points, niveaux (Débutant → Maître Cyber), badges à débloquer
- **Scan de santé cyber** : score /100 sur 5 domaines, questionnaire initial, évolution graphique
- **Bibliothèque de guides** : 30+ tutoriels filtrables par plateforme et catégorie
- **Dashboard de progression** : graphiques, historique, statistiques détaillées

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Frontend | Flutter 3.x / Dart 3.x |
| Backend | Firebase (Auth, Firestore, Messaging, Analytics) |
| State management | Riverpod |
| Stockage local | shared_preferences, Hive (cache offline) |
| Graphiques | fl_chart |
| Notifications | flutter_local_notifications + FCM |

## Structure du projet

```
lib/
├── core/             # Thème, constantes, utilitaires
├── models/           # Modèles de données (User, Challenge, Badge, Guide)
├── providers/        # State management Riverpod
├── screens/          # Écrans par feature
│   ├── auth/         # Login, register
│   ├── onboarding/   # Welcome, questionnaire, résultats
│   ├── home/         # Défi du jour, score, streaks
│   ├── progress/     # Dashboard, graphiques, historique
│   ├── guides/       # Bibliothèque tutoriels
│   └── profile/      # Profil, badges, settings
├── widgets/          # Composants réutilisables
└── services/         # Firebase, notifications, stockage local
```

## Prérequis

- Flutter SDK 3.x ([installation](https://docs.flutter.dev/get-started/install))
- Dart SDK 3.x
- Firebase CLI (`npm install -g firebase-tools`)
- Un projet Firebase configuré (Auth + Firestore + Messaging)
- Android Studio ou Xcode pour les émulateurs

## Installation

```bash
# Cloner le repo
git clone https://github.com/alexisboizard/cyberfit.git
cd cyberfit

# Installer les dépendances
flutter pub get

# Configurer Firebase (suivre les instructions FlutterFire CLI)
dart run flutterfire_cli:flutterfire configure

# Lancer l'app
flutter run
```

## CI/CD

Trois workflows GitHub Actions sont configurés :

| Workflow | Déclencheur | Résultat |
|----------|-------------|----------|
| **CI** | Push/PR sur `main` | Lint, analyse, tests |
| **Build** | Push `main`, tags `v*`, manuel | APK + IPA en artifacts |
| **Distribute** | Manuel | Envoi aux testeurs via Firebase App Distribution |

### Tester sur un device

**Android** — Télécharger l'APK depuis l'onglet Actions → Build → artifact

**iOS** — Deux options :
1. **Firebase App Distribution** (recommandé) : les testeurs recoivent un lien par email
2. **TestFlight** : uploader l'IPA manuellement sur App Store Connect

### Secrets GitHub requis

| Secret | Usage |
|--------|-------|
| `KEYSTORE_BASE64` | Keystore Android (base64) |
| `KEY_PROPERTIES` | Config signing Android |
| `P12_BASE64` | Certificat Apple (base64) |
| `P12_PASSWORD` | Mot de passe du certificat |
| `PROVISIONING_PROFILE_BASE64` | Provisioning profile Ad Hoc (base64) |
| `FIREBASE_APP_ID_ANDROID` | App ID Firebase Android |
| `FIREBASE_APP_ID_IOS` | App ID Firebase iOS |
| `FIREBASE_TOKEN` | Token CI (`firebase login:ci`) |

## Documentation

| Document | Description |
|----------|-------------|
| [Spécifications](docs/SPEC.md) | Fonctionnalités détaillées, formats, systèmes de jeu |
| [Architecture](docs/ARCHITECTURE.md) | Schéma Firestore, design system, sécurité, packages |
| [Roadmap](docs/ROADMAP.md) | Plan de développement 4 semaines + post-MVP |
| [Contenu](docs/CONTENT.md) | Défis, guides et badges à créer |

## Modèle économique

- **Gratuit** : 3 défis/semaine, score de base, 5 badges, 10 guides
- **Premium** (2,99 €/mois ou 19,99 €/an) : défis illimités, tous les badges, bibliothèque complète, protection de streak

## Roadmap Features

Suivi des fonctionnalités à implémenter. Cocher au fur et à mesure.

### Implémenté

- [x] Authentification (email + Google Sign-In)
- [x] Onboarding (questionnaire initial + score de départ)
- [x] 28 défis quotidiens avec tutoriels step-by-step
- [x] Système de score /100 sur 5 domaines
- [x] Gamification : streaks, points, niveaux, badges
- [x] Bibliothèque de guides (filtres, recherche)
- [x] Profil complet (stats, badges, paramètres, suppression compte)
- [x] Notifications quotidiennes configurables
- [x] Modèle freemium (3 défis/semaine, limites guides/badges)
- [x] Paywall RevenueCat (abonnement mensuel/annuel)
- [x] Analytics Firebase
- [x] CI/CD (lint, build, Firebase App Distribution)

### À implémenter

- [ ] **Leaderboard** — classement hebdomadaire entre utilisateurs, top 50, filtrable par niveau
- [ ] **Partage social** — partager son score, badges ou streak sur les réseaux sociaux (image générée)
- [ ] **Notifications push ciblées** — "Votre streak va expirer !", "Nouveau défi dispo", relance après inactivité
- [ ] **Quiz rapides** — quiz de 5 questions par catégorie, en complément des défis pratiques
- [ ] **Statistiques détaillées** — graphiques de progression (fl_chart), radar chart par domaine, historique
- [ ] **Actualités cybersécurité** — fil d'actus via flux RSS, alertes sur les menaces récentes

### Idées futures (post-MVP)

- [ ] Simulateur de phishing interactif
- [ ] Défis thématiques hebdomadaires (semaine phishing, semaine mots de passe...)
- [ ] Mode hors-ligne complet (cache Hive)
- [ ] Dashboard entreprise B2B (app web séparée)
- [ ] Rapports de conformité (NIS2, ANSSI)
- [ ] Multi-langue (EN, ES, DE)

## Licence

Projet privé — tous droits réservés.

---

Développé par Alexis Boizard
