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
- **Premium** (4,99 €/mois ou 39 €/an) : défis illimités, scan HIBP, tous les badges, bibliothèque complète, alertes breaches

## Licence

Projet privé — tous droits réservés.

---

Développé par Alexis Boizard
