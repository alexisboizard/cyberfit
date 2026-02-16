# Spécifications fonctionnelles — CyberFit

## 1. Système de défis quotidiens

### Principe
- 1 défi par jour, 5-10 minutes max
- Catégories : mots de passe, 2FA, réseaux sociaux, emails, navigation, appareils
- Difficulté : Facile / Moyen / Avancé
- Points : 10-50 selon difficulté

### Format d'un défi
```
- Titre accrocheur
- Description courte (2-3 lignes)
- Temps estimé
- Difficulté (Facile/Moyen/Avancé)
- Points attribués
- Tutoriel step-by-step avec screenshots/illustrations
- Checkbox de validation
```

### Exemples de défis
- "Active la double authentification sur un compte important"
- "Vérifie tes paramètres de confidentialité Facebook"
- "Identifie 3 signes de phishing dans cet email"
- "Change un mot de passe réutilisé"
- "Nettoie tes anciennes sessions actives Google"
- "Active les mises à jour automatiques sur ton téléphone"

---

## 2. Système de gamification

### Streaks (séries)
- Compteur de jours consécutifs
- Bonus de points si streak > 7 jours
- Rappel notification si risque de casser le streak

### Points et niveaux
- Points par défi complété (10-50 pts selon difficulté)
- Niveaux : Débutant → Initié → Confirmé → Expert → Maître Cyber
- Paliers tous les 500 points

### Badges
- 15-20 badges pour le MVP
- Exemples : "Premier pas", "Une semaine de suite", "2FA Master", "Détecteur de phishing"
- Collection visible dans le profil
- Raretés : Common, Rare, Epic, Legendary

---

## 3. Scan de santé cyber

### Score global /100
Calculé sur 5 domaines (20 pts chacun) :

1. **Mots de passe** : force, réutilisation, gestionnaire
2. **Authentification** : 2FA activée, nombre de comptes protégés
3. **Confidentialité** : paramètres réseaux sociaux, permissions apps
4. **Emails** : filtres spam, reconnaissance phishing
5. **Appareils** : mises à jour, antivirus, chiffrement

### Questionnaire initial (onboarding)
- 15-20 questions rapides
- Génère le score de départ
- Identifie les quick wins prioritaires
- Stocké en local + Firestore

### Évolution du score
- Recalculé après chaque défi complété
- Graphique d'évolution temporelle
- Breakdown par domaine (radar chart)

---

## 4. Tutoriels et guides express

### Format mobile-first
- Cartes verticales swipables
- Screenshots annotés
- Durée 2-5 minutes max
- Call-to-action clair

### Bibliothèque de guides
- 30-40 guides pour le MVP
- Recherche par mot-clé
- Filtres par plateforme (iOS / Android / Web / Windows / Mac)
- Exemples : "Activer 2FA sur Gmail", "Créer un mot de passe fort", "Configurer un gestionnaire de mots de passe"

---

## 5. Dashboard de progression

### Vue d'ensemble
- Score actuel avec jauge visuelle
- Streak counter proéminent
- Défi du jour (card principale)
- Derniers badges débloqués
- Graphique progression 7/30 jours

### Historique
- Liste des défis complétés avec dates
- Points gagnés au fil du temps
- Statistiques : total défis, catégorie préférée, temps moyen

---

## 6. Navigation et écrans

### Bottom Navigation (4 tabs)

1. **Accueil** — Défi du jour, streak counter, score actuel, derniers badges
2. **Progression** — Dashboard détaillé, graphiques, historique, statistiques
3. **Guides** — Bibliothèque tutoriels, search, filtres par catégorie
4. **Profil** — Infos utilisateur, collection badges, paramètres, à propos

### Flow d'onboarding (première utilisation)
1. Welcome screen (proposition de valeur)
2. Questionnaire scan initial (15 questions)
3. Résultats score + breakdown
4. Sélection premier défi suggéré
5. Explication système streaks/points
6. Création compte / Sign in
7. Permission notifications

### Flow de complétion de défi
1. Voir défi du jour
2. Lire description + tutorial
3. Suivre les steps
4. Marquer comme complété
5. Animation célébration + points
6. Mise à jour score
7. Badge débloqué ? → Animation spéciale
8. Suggestion next action
