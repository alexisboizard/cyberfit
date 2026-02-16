# Roadmap — CyberFit

## Plan MVP (4 semaines)

### Semaine 1 — Fondations

**Objectif** : setup projet + architecture + Firebase

- [ ] Init projet Flutter
- [ ] Setup Firebase (Auth, Firestore, Messaging)
- [ ] Architecture dossiers (feature-first)
- [ ] Design system (couleurs, typo, composants de base)
- [ ] State management (Riverpod setup)
- [ ] Navigation (bottom nav + routes)
- [ ] Modèles de données (User, Challenge, Badge, etc.)
- [ ] Authentification (email/password + Google)

**Livrable** : app qui boot, navigation fonctionnelle, auth opérationnelle

---

### Semaine 2 — Core Features Part 1

**Objectif** : défis quotidiens + scan initial

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

**Livrable** : un utilisateur peut compléter un défi et voir son score

---

### Semaine 3 — Core Features Part 2 + Gamification

**Objectif** : streaks, badges, progression

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

**Livrable** : gamification complète, tracking de progression

---

### Semaine 4 — Polish + Guides + Testing

**Objectif** : bibliothèque guides + finitions MVP

- [ ] Écran Guides (liste + search)
- [ ] Détail guide avec steps
- [ ] Filtres par catégorie/plateforme
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

**Livrable** : MVP fonctionnel, testé, buildable

---

## Critères de succès MVP

### Fonctionnel
- [ ] Création de compte et connexion
- [ ] Onboarding complet avec score initial
- [ ] 1 défi par jour réalisable
- [ ] Streaks fonctionnels + notifications de rappel
- [ ] Score qui évolue selon les actions
- [ ] Badges débloqués automatiquement
- [ ] Guides accessibles et searchable
- [ ] Fonctionnement offline (cache local)

### Technique
- [ ] Build Android/iOS sans erreurs
- [ ] Pas de crash sur les flows principaux
- [ ] Temps de chargement < 2s
- [ ] Animations fluides 60fps
- [ ] Firebase security rules configurées

### UX
- [ ] Onboarding clair (< 5 min)
- [ ] Interface intuitive
- [ ] Feedback immédiat sur chaque action
- [ ] Célébrations engageantes
- [ ] Copywriting motivant en français

---

## Post-MVP

### V1.1 (M+1)
- Intégration HaveIBeenPwned API (monitoring breaches)
- Notifications push breaches
- Dark mode
- Traduction anglaise
- Analytics avancées

### V1.2 (M+2)
- Système de quiz (mini-jeux)
- Mode compétition (leaderboard amis)
- Partage progression réseaux sociaux
- Apple Sign-In
- Premium paywall (IAP)

### V1.3 (M+3)
- Parcours personnalisés (profils : famille, pro, gamer)
- Coach IA (suggestions basées sur le comportement)
- Communauté (forums, Q&A)
- Widget home screen
- Version tablette optimisée

---

## Gestion des bugs

| Priorité | Description |
|----------|-------------|
| **P0** (Bloquant) | Crash, auth cassée, perte de données |
| **P1** (Majeur) | Feature core non fonctionnelle |
| **P2** (Mineur) | Problème UI/UX, performance |
| **P3** (Nice-to-have) | Polish, améliorations |

### Outils
- GitHub Issues pour le tracking
- Projects board (Kanban)
- Milestones par semaine
