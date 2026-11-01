import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds Firestore collections if they are empty.
  /// Call this once at app startup.
  Future<void> seedIfEmpty() async {
    final challengesSnap =
        await _db.collection(AppConstants.challengesCollection).limit(1).get();
    if (challengesSnap.docs.isEmpty) {
      await _seedChallenges();
    }

    final badgesSnap =
        await _db.collection(AppConstants.badgesCollection).limit(1).get();
    if (badgesSnap.docs.isEmpty) {
      await _seedBadges();
    }

    final guidesSnap =
        await _db.collection(AppConstants.guidesCollection).limit(1).get();
    if (guidesSnap.docs.isEmpty) {
      await _seedGuides();
    }

    final quizzesSnap =
        await _db.collection(AppConstants.quizzesCollection).limit(1).get();
    if (quizzesSnap.docs.isEmpty) {
      await _seedQuizzes();
    }
  }

  Future<void> _seedChallenges() async {
    final batch = _db.batch();
    final col = _db.collection(AppConstants.challengesCollection);

    for (final c in _challenges) {
      batch.set(col.doc(c['id'] as String), c);
    }
    await batch.commit();
  }

  Future<void> _seedBadges() async {
    final batch = _db.batch();
    final col = _db.collection(AppConstants.badgesCollection);

    for (final b in _badges) {
      batch.set(col.doc(b['id'] as String), b);
    }
    await batch.commit();
  }

  Future<void> _seedQuizzes() async {
    final batch = _db.batch();
    final col = _db.collection(AppConstants.quizzesCollection);

    for (final q in _quizzes) {
      batch.set(col.doc(q['id'] as String), q);
    }
    await batch.commit();
  }

  Future<void> _seedGuides() async {
    final batch = _db.batch();
    final col = _db.collection(AppConstants.guidesCollection);

    for (final g in _guides) {
      batch.set(col.doc(g['id'] as String), g);
    }
    await batch.commit();
  }
}

// ─── Challenges ─────────────────────────────────────────────────────────────

const _challenges = [
  // --- Mots de passe ---
  {
    'id': 'pwd_manager_setup',
    'title': 'Installer un gestionnaire de mots de passe',
    'description':
        'Téléchargez et configurez un gestionnaire comme Bitwarden ou 1Password pour sécuriser tous vos comptes.',
    'category': 'passwords',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 1,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Choisissez un gestionnaire de mots de passe. Nous recommandons Bitwarden (gratuit) ou 1Password.',
      },
      {
        'stepNumber': 2,
        'text':
            'Téléchargez l\'application sur votre téléphone et l\'extension navigateur.',
      },
      {
        'stepNumber': 3,
        'text':
            'Créez un mot de passe maître fort (au moins 16 caractères, avec une phrase secrète).',
      },
      {
        'stepNumber': 4,
        'text':
            'Ajoutez vos 3 comptes les plus importants (email, banque, réseaux sociaux).',
      },
    ],
  },
  {
    'id': 'pwd_audit',
    'title': 'Auditer vos mots de passe existants',
    'description':
        'Vérifiez si vos mots de passe ont fuité et remplacez les plus faibles.',
    'category': 'passwords',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 15,
    'isActive': true,
    'order': 2,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Allez sur haveibeenpwned.com et entrez votre adresse email pour vérifier les fuites.',
      },
      {
        'stepNumber': 2,
        'text':
            'Si des fuites sont détectées, changez immédiatement les mots de passe concernés.',
      },
      {
        'stepNumber': 3,
        'text':
            'Utilisez la fonction "audit" de votre gestionnaire pour détecter les mots de passe faibles ou dupliqués.',
      },
      {
        'stepNumber': 4,
        'text':
            'Remplacez chaque mot de passe faible par un mot de passe généré (20+ caractères).',
      },
    ],
  },
  {
    'id': 'pwd_passphrase',
    'title': 'Créer une phrase secrète incassable',
    'description':
        'Apprenez la technique des phrases secrètes pour un mot de passe maître impossible à deviner.',
    'category': 'passwords',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 3,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Choisissez 4 à 6 mots aléatoires sans rapport entre eux. Ex : "girafe-piano-neige-cosmos".',
      },
      {
        'stepNumber': 2,
        'text':
            'Ajoutez un chiffre et un caractère spécial entre deux mots pour plus de robustesse.',
      },
      {
        'stepNumber': 3,
        'text':
            'Testez la force de votre phrase sur bitwarden.com/password-strength.',
      },
    ],
  },

  // --- Authentification ---
  {
    'id': 'auth_2fa_email',
    'title': 'Activer la 2FA sur votre email',
    'description':
        'Protégez votre email principal avec la double authentification — c\'est le compte le plus critique.',
    'category': 'authentication',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 4,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Connectez-vous à votre email (Gmail, Outlook, etc.) et allez dans Paramètres > Sécurité.',
      },
      {
        'stepNumber': 2,
        'text':
            'Trouvez "Vérification en deux étapes" ou "2FA" et activez-la.',
      },
      {
        'stepNumber': 3,
        'text':
            'Choisissez une app authenticator (Google Authenticator, Authy) plutôt que le SMS.',
      },
      {
        'stepNumber': 4,
        'text':
            'Scannez le QR code avec l\'app et sauvegardez vos codes de récupération dans un endroit sûr.',
      },
    ],
  },
  {
    'id': 'auth_2fa_social',
    'title': 'Sécuriser vos réseaux sociaux avec la 2FA',
    'description':
        'Activez la double authentification sur Instagram, Facebook, Twitter et LinkedIn.',
    'category': 'authentication',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 15,
    'isActive': true,
    'order': 5,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Sur chaque réseau social, allez dans Paramètres > Sécurité > Authentification à deux facteurs.',
      },
      {
        'stepNumber': 2,
        'text':
            'Préférez l\'option "Application d\'authentification" plutôt que SMS.',
      },
      {
        'stepNumber': 3,
        'text':
            'Sauvegardez les codes de secours fournis par chaque plateforme.',
      },
    ],
  },
  {
    'id': 'auth_recovery_codes',
    'title': 'Sauvegarder vos codes de récupération',
    'description':
        'Regroupez et sécurisez tous vos codes de récupération 2FA au même endroit.',
    'category': 'authentication',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 6,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Rassemblez les codes de récupération de tous vos comptes (email, réseaux sociaux, banque).',
      },
      {
        'stepNumber': 2,
        'text':
            'Enregistrez-les dans votre gestionnaire de mots de passe dans une note sécurisée.',
      },
      {
        'stepNumber': 3,
        'text':
            'Optionnel : imprimez une copie papier et rangez-la dans un endroit sûr chez vous.',
      },
    ],
  },

  // --- Réseaux sociaux / Confidentialité ---
  {
    'id': 'social_privacy_audit',
    'title': 'Audit de confidentialité Instagram',
    'description':
        'Passez votre compte Instagram en revue et verrouillez vos paramètres de confidentialité.',
    'category': 'social',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 7,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Ouvrez Instagram > Paramètres > Confidentialité > Compte privé. Activez le mode privé si souhaité.',
      },
      {
        'stepNumber': 2,
        'text':
            'Vérifiez la liste des applications tierces connectées dans Paramètres > Sécurité > Applications.',
      },
      {
        'stepNumber': 3,
        'text':
            'Supprimez les accès aux applications que vous n\'utilisez plus.',
      },
    ],
  },
  {
    'id': 'social_facebook_privacy',
    'title': 'Verrouiller la confidentialité Facebook',
    'description':
        'Limitez qui peut voir vos publications, photos et informations personnelles sur Facebook.',
    'category': 'social',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 8,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Allez dans Paramètres > Confidentialité et passez "Qui peut voir vos publications" sur "Amis".',
      },
      {
        'stepNumber': 2,
        'text':
            'Dans Paramètres > Applications et sites web, supprimez les apps tierces inutiles.',
      },
      {
        'stepNumber': 3,
        'text':
            'Désactivez la reconnaissance faciale dans Paramètres > Reconnaissance des visages.',
      },
      {
        'stepNumber': 4,
        'text':
            'Limitez les anciennes publications : Confidentialité > Limiter les anciens posts.',
      },
    ],
  },
  {
    'id': 'social_digital_footprint',
    'title': 'Réduire votre empreinte numérique',
    'description':
        'Recherchez et supprimez les comptes et données que vous avez laissés sur le web.',
    'category': 'social',
    'difficulty': 'hard',
    'points': 50,
    'estimatedMinutes': 20,
    'isActive': true,
    'order': 9,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Cherchez votre nom et email sur Google pour voir ce qui est public à votre sujet.',
      },
      {
        'stepNumber': 2,
        'text':
            'Utilisez justdeleteme.xyz pour trouver les liens de suppression de vos anciens comptes.',
      },
      {
        'stepNumber': 3,
        'text':
            'Supprimez les comptes que vous n\'utilisez plus (forums, boutiques, jeux...).',
      },
      {
        'stepNumber': 4,
        'text':
            'Demandez la suppression de vos données aux sites qui ne proposent pas de suppression automatique.',
      },
    ],
  },

  // --- Emails ---
  {
    'id': 'email_phishing_test',
    'title': 'Reconnaître un email de phishing',
    'description':
        'Apprenez les 5 signaux d\'alerte pour ne plus jamais tomber dans le piège du phishing.',
    'category': 'email',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 10,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Signal 1 : L\'adresse de l\'expéditeur est suspecte (domaine bizarre, fautes).',
      },
      {
        'stepNumber': 2,
        'text':
            'Signal 2 : Le message crée un sentiment d\'urgence ("Votre compte sera fermé dans 24h !").',
      },
      {
        'stepNumber': 3,
        'text':
            'Signal 3 : Le lien pointe vers un site différent du site officiel (survolez sans cliquer).',
      },
      {
        'stepNumber': 4,
        'text':
            'Signal 4 : On vous demande des informations personnelles ou bancaires.',
      },
      {
        'stepNumber': 5,
        'text':
            'Signal 5 : Pièce jointe inattendue (ne jamais ouvrir un .exe, .zip ou .docm suspect).',
      },
    ],
  },
  {
    'id': 'email_alias',
    'title': 'Créer des alias email',
    'description':
        'Utilisez des alias pour protéger votre vraie adresse email des spams et fuites.',
    'category': 'email',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 11,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Inscrivez-vous sur SimpleLogin ou Firefox Relay pour générer des alias email gratuits.',
      },
      {
        'stepNumber': 2,
        'text':
            'Utilisez un alias différent pour chaque inscription sur un nouveau site.',
      },
      {
        'stepNumber': 3,
        'text':
            'Si un alias reçoit du spam, désactivez-le sans affecter votre vraie adresse.',
      },
    ],
  },
  {
    'id': 'email_inbox_cleanup',
    'title': 'Nettoyer votre boîte mail',
    'description':
        'Désabonnez-vous des newsletters inutiles et réduisez votre surface d\'attaque.',
    'category': 'email',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 12,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Cherchez "unsubscribe" ou "se désabonner" dans votre boîte mail.',
      },
      {
        'stepNumber': 2,
        'text':
            'Désabonnez-vous de toutes les newsletters que vous ne lisez jamais.',
      },
      {
        'stepNumber': 3,
        'text':
            'Supprimez les emails contenant des données sensibles (mots de passe envoyés en clair, pièces d\'identité).',
      },
    ],
  },

  // --- Appareils ---
  {
    'id': 'device_update_all',
    'title': 'Mettre à jour tous vos appareils',
    'description':
        'Les mises à jour corrigent des failles de sécurité critiques. Ne les ignorez plus jamais.',
    'category': 'device',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 13,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Sur votre téléphone : Paramètres > Mise à jour logicielle > Installer les mises à jour disponibles.',
      },
      {
        'stepNumber': 2,
        'text':
            'Sur votre ordinateur : vérifiez les mises à jour système (Windows Update, macOS Mise à jour logicielle).',
      },
      {
        'stepNumber': 3,
        'text':
            'Activez les mises à jour automatiques pour ne plus avoir à y penser.',
      },
    ],
  },
  {
    'id': 'device_app_permissions',
    'title': 'Auditer les permissions de vos apps',
    'description':
        'Vérifiez quelles apps ont accès à votre caméra, micro, localisation et contacts.',
    'category': 'device',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 14,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Sur iPhone : Réglages > Confidentialité. Sur Android : Paramètres > Applications > Permissions.',
      },
      {
        'stepNumber': 2,
        'text':
            'Vérifiez chaque permission (Localisation, Caméra, Micro, Contacts).',
      },
      {
        'stepNumber': 3,
        'text':
            'Retirez les permissions aux apps qui n\'en ont pas besoin (une app lampe torche n\'a pas besoin de vos contacts !).',
      },
      {
        'stepNumber': 4,
        'text':
            'Activez le mode "Uniquement en cours d\'utilisation" pour la localisation quand c\'est possible.',
      },
    ],
  },
  {
    'id': 'device_backup',
    'title': 'Configurer des sauvegardes automatiques',
    'description':
        'Protégez vos données en mettant en place des sauvegardes automatiques sur tous vos appareils.',
    'category': 'device',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 15,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'iPhone : Réglages > [Votre nom] > iCloud > Sauvegarde iCloud > Activez. Android : Paramètres > Système > Sauvegarde.',
      },
      {
        'stepNumber': 2,
        'text':
            'Ordinateur : activez Time Machine (macOS) ou Historique des fichiers (Windows).',
      },
      {
        'stepNumber': 3,
        'text':
            'Idéal : appliquez la règle 3-2-1 (3 copies, 2 supports différents, 1 copie hors site).',
      },
    ],
  },

  // --- Navigation ---
  {
    'id': 'nav_https_check',
    'title': 'Vérifier HTTPS avant de saisir des données',
    'description':
        'Apprenez à vérifier qu\'un site est sécurisé avant d\'y entrer vos informations.',
    'category': 'navigation',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 16,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Vérifiez toujours que l\'URL commence par "https://" (avec le "s") et qu\'un cadenas apparaît.',
      },
      {
        'stepNumber': 2,
        'text':
            'Cliquez sur le cadenas pour vérifier le certificat du site. Le nom doit correspondre au site visité.',
      },
      {
        'stepNumber': 3,
        'text':
            'Ne saisissez JAMAIS d\'information bancaire ou de mot de passe sur un site sans HTTPS.',
      },
    ],
  },
  {
    'id': 'nav_browser_hardening',
    'title': 'Durcir les paramètres de votre navigateur',
    'description':
        'Configurez Chrome, Firefox ou Safari pour bloquer les trackers et protéger votre vie privée.',
    'category': 'navigation',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 17,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Installez uBlock Origin pour bloquer les publicités et trackers.',
      },
      {
        'stepNumber': 2,
        'text':
            'Dans les paramètres du navigateur, activez "Ne pas me suivre" (Do Not Track).',
      },
      {
        'stepNumber': 3,
        'text':
            'Bloquez les cookies tiers : Paramètres > Confidentialité > Cookies > Bloquer les cookies tiers.',
      },
      {
        'stepNumber': 4,
        'text':
            'Configurez la suppression automatique des cookies à la fermeture du navigateur.',
      },
    ],
  },
  {
    'id': 'nav_vpn_setup',
    'title': 'Installer et utiliser un VPN',
    'description':
        'Protégez votre connexion sur les réseaux Wi-Fi publics avec un VPN fiable.',
    'category': 'navigation',
    'difficulty': 'hard',
    'points': 50,
    'estimatedMinutes': 15,
    'isActive': true,
    'order': 18,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Choisissez un VPN de confiance (Mullvad, ProtonVPN, NordVPN). Évitez les VPN gratuits douteux.',
      },
      {
        'stepNumber': 2,
        'text':
            'Installez l\'application sur votre téléphone et votre ordinateur.',
      },
      {
        'stepNumber': 3,
        'text':
            'Activez le VPN systématiquement quand vous êtes sur un Wi-Fi public (café, hôtel, aéroport).',
      },
      {
        'stepNumber': 4,
        'text':
            'Activez le "Kill Switch" pour couper internet si le VPN se déconnecte.',
      },
    ],
  },

  // --- Mots de passe (supplémentaires) ---
  {
    'id': 'pwd_haveibeenpwned',
    'title': 'Vérifier si vos comptes ont été piratés',
    'description':
        'Utilisez Have I Been Pwned pour savoir si vos identifiants ont fuité.',
    'category': 'passwords',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 19,
    'tutorialSteps': [
      {'stepNumber': 1, 'text': 'Rendez-vous sur haveibeenpwned.com.'},
      {'stepNumber': 2, 'text': 'Entrez votre adresse email principale.'},
      {
        'stepNumber': 3,
        'text':
            'Si des fuites sont détectées, changez immédiatement les mots de passe des comptes concernés.',
      },
      {
        'stepNumber': 4,
        'text':
            'Répétez pour toutes vos adresses email (pro, perso, anciennes).',
      },
    ],
  },
  {
    'id': 'pwd_passphrase',
    'title': 'Créer une phrase de passe mémorable',
    'description':
        'Apprenez la technique Diceware pour créer des mots de passe impossibles à craquer mais faciles à retenir.',
    'category': 'passwords',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 20,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'La méthode Diceware : lancez un dé 5 fois pour obtenir un nombre à 5 chiffres, puis cherchez le mot correspondant dans la liste Diceware.',
      },
      {
        'stepNumber': 2,
        'text':
            'Répétez pour obtenir 5-6 mots. Ex : "correct cheval batterie agrafe".',
      },
      {
        'stepNumber': 3,
        'text':
            'Cette phrase est plus sûre qu\'un mot de passe complexe de 8 caractères tout en étant mémorisable.',
      },
      {
        'stepNumber': 4,
        'text':
            'Utilisez cette technique pour votre mot de passe maître (gestionnaire de mots de passe, email principal).',
      },
    ],
  },

  // --- Authentification (supplémentaires) ---
  {
    'id': 'auth_security_keys',
    'title': 'Découvrir les clés de sécurité physiques',
    'description':
        'Apprenez ce qu\'est une clé YubiKey et pourquoi c\'est le niveau ultime de protection.',
    'category': 'authentication',
    'difficulty': 'hard',
    'points': 50,
    'estimatedMinutes': 15,
    'isActive': true,
    'order': 21,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Une clé de sécurité (YubiKey, Google Titan) est un dispositif physique USB/NFC qui remplace les codes SMS ou TOTP.',
      },
      {
        'stepNumber': 2,
        'text':
            'Avantage : impossible à phisher, contrairement aux codes par SMS ou email.',
      },
      {
        'stepNumber': 3,
        'text':
            'Configurez-la sur vos comptes critiques : Google, Microsoft, GitHub, réseaux sociaux.',
      },
      {
        'stepNumber': 4,
        'text':
            'Astuce : achetez toujours 2 clés (une principale + une de secours rangée en lieu sûr).',
      },
    ],
  },

  // --- Réseaux sociaux (supplémentaires) ---
  {
    'id': 'social_tiktok_privacy',
    'title': 'Paramètres de confidentialité TikTok',
    'description':
        'Configurez TikTok pour limiter qui peut voir votre contenu et vous contacter.',
    'category': 'social',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 22,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Ouvrez TikTok > Profil > Menu (≡) > Paramètres et confidentialité.',
      },
      {
        'stepNumber': 2,
        'text': 'Activez le compte privé si vous ne souhaitez pas être public.',
      },
      {
        'stepNumber': 3,
        'text':
            'Limitez qui peut commenter, envoyer des messages et faire des duos avec vos vidéos.',
      },
      {
        'stepNumber': 4,
        'text':
            'Désactivez la personnalisation des publicités dans Confidentialité > Publicités.',
      },
    ],
  },
  {
    'id': 'social_data_download',
    'title': 'Télécharger vos données personnelles',
    'description':
        'Demandez une copie de toutes les données que les réseaux sociaux détiennent sur vous.',
    'category': 'social',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 23,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Sur chaque réseau social, cherchez "Télécharger mes données" ou "Vos informations" dans les paramètres.',
      },
      {
        'stepNumber': 2,
        'text':
            'Google : myaccount.google.com > Données et confidentialité > Télécharger vos données.',
      },
      {
        'stepNumber': 3,
        'text':
            'Facebook : Paramètres > Vos informations > Télécharger vos informations.',
      },
      {
        'stepNumber': 4,
        'text':
            'Analysez ce qui est stocké. Vous serez surpris par la quantité de données collectées.',
      },
    ],
  },

  // --- Emails (supplémentaires) ---
  {
    'id': 'email_encrypted',
    'title': 'Envoyer un email chiffré',
    'description':
        'Découvrez comment envoyer des emails que seul le destinataire peut lire.',
    'category': 'email',
    'difficulty': 'hard',
    'points': 50,
    'estimatedMinutes': 15,
    'isActive': true,
    'order': 24,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Créez un compte ProtonMail (gratuit) pour envoyer des emails chiffrés de bout en bout.',
      },
      {
        'stepNumber': 2,
        'text':
            'Envoyez un email à un autre utilisateur ProtonMail : le chiffrement est automatique.',
      },
      {
        'stepNumber': 3,
        'text':
            'Pour envoyer à un email non-ProtonMail : utilisez l\'option "Protéger par mot de passe".',
      },
      {
        'stepNumber': 4,
        'text':
            'Communiquez le mot de passe au destinataire par un autre canal (SMS, téléphone).',
      },
    ],
  },

  // --- Appareils (supplémentaires) ---
  {
    'id': 'device_usb_safety',
    'title': 'Se protéger des clés USB malveillantes',
    'description':
        'Apprenez pourquoi vous ne devez jamais brancher une clé USB inconnue.',
    'category': 'device',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 25,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Règle d\'or : ne branchez JAMAIS une clé USB trouvée par terre, reçue en cadeau d\'un inconnu ou prêtée.',
      },
      {
        'stepNumber': 2,
        'text':
            'Les clés USB malveillantes (Rubber Ducky, USB Killer) peuvent installer des malwares en quelques secondes.',
      },
      {
        'stepNumber': 3,
        'text':
            'Si vous devez utiliser une clé USB externe, analysez-la d\'abord avec votre antivirus.',
      },
      {
        'stepNumber': 4,
        'text':
            'Privilégiez le partage de fichiers par cloud (Google Drive, iCloud, WeTransfer) plutôt que par clé USB.',
      },
    ],
  },
  {
    'id': 'device_encrypt_phone',
    'title': 'Chiffrer votre téléphone',
    'description':
        'Assurez-vous que les données de votre téléphone sont illisibles en cas de vol.',
    'category': 'device',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 26,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'iPhone : le chiffrement est activé par défaut si vous avez un code de déverrouillage. Vérifiez dans Réglages > Face ID et code.',
      },
      {
        'stepNumber': 2,
        'text':
            'Android : Paramètres > Sécurité > Chiffrement. Activez le chiffrement si ce n\'est pas fait.',
      },
      {
        'stepNumber': 3,
        'text':
            'Un code à 6 chiffres minimum est indispensable pour que le chiffrement soit efficace.',
      },
    ],
  },

  // --- Navigation (supplémentaires) ---
  {
    'id': 'nav_dns_secure',
    'title': 'Configurer un DNS sécurisé',
    'description':
        'Remplacez le DNS de votre opérateur par un DNS chiffré pour plus de confidentialité.',
    'category': 'navigation',
    'difficulty': 'medium',
    'points': 25,
    'estimatedMinutes': 10,
    'isActive': true,
    'order': 27,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Le DNS traduit les noms de sites en adresses IP. Votre opérateur peut voir tous les sites que vous visitez.',
      },
      {
        'stepNumber': 2,
        'text':
            'Sur iPhone : Réglages > Wi-Fi > votre réseau > Configurer le DNS > Manuel. Ajoutez 1.1.1.1 et 1.0.0.1 (Cloudflare).',
      },
      {
        'stepNumber': 3,
        'text':
            'Sur Android : Paramètres > Réseau > DNS privé > Entrez "one.one.one.one".',
      },
      {
        'stepNumber': 4,
        'text':
            'Alternatives : 9.9.9.9 (Quad9, bloque les domaines malveillants) ou 8.8.8.8 (Google).',
      },
    ],
  },
  {
    'id': 'nav_password_leak_alert',
    'title': 'Activer les alertes de fuites de mots de passe',
    'description':
        'Configurez votre navigateur pour vous alerter si un mot de passe enregistré a fuité.',
    'category': 'navigation',
    'difficulty': 'easy',
    'points': 10,
    'estimatedMinutes': 5,
    'isActive': true,
    'order': 28,
    'tutorialSteps': [
      {
        'stepNumber': 1,
        'text':
            'Chrome : Paramètres > Confidentialité et sécurité > Vérification de sécurité > Vérifier maintenant.',
      },
      {
        'stepNumber': 2,
        'text':
            'Safari : Préférences > Mots de passe. Les mots de passe compromis sont signalés en jaune.',
      },
      {
        'stepNumber': 3,
        'text':
            'Firefox : about:logins > vérifiez les alertes de fuite sur chaque mot de passe enregistré.',
      },
      {
        'stepNumber': 4,
        'text':
            'Changez immédiatement tout mot de passe signalé comme compromis.',
      },
    ],
  },
];

// ─── Badges ─────────────────────────────────────────────────────────────────

const _badges = [
  {
    'id': 'first_challenge',
    'name': 'Premier Pas',
    'description': 'Complétez votre premier défi',
    'iconUrl': '',
    'condition': 'complete_1_challenge',
    'rarity': 'common',
  },
  {
    'id': 'five_challenges',
    'name': 'En Route',
    'description': 'Complétez 5 défis',
    'iconUrl': '',
    'condition': 'complete_5_challenges',
    'rarity': 'common',
  },
  {
    'id': 'ten_challenges',
    'name': 'Cyber Addict',
    'description': 'Complétez 10 défis',
    'iconUrl': '',
    'condition': 'complete_10_challenges',
    'rarity': 'rare',
  },
  {
    'id': 'all_passwords',
    'name': 'Maître des Clés',
    'description': 'Complétez tous les défis "Mots de passe"',
    'iconUrl': '',
    'condition': 'complete_all_passwords',
    'rarity': 'rare',
  },
  {
    'id': 'all_auth',
    'name': 'Forteresse',
    'description': 'Complétez tous les défis "Authentification"',
    'iconUrl': '',
    'condition': 'complete_all_authentication',
    'rarity': 'rare',
  },
  {
    'id': 'all_social',
    'name': 'Fantôme Digital',
    'description': 'Complétez tous les défis "Réseaux sociaux"',
    'iconUrl': '',
    'condition': 'complete_all_social',
    'rarity': 'rare',
  },
  {
    'id': 'all_email',
    'name': 'Anti-Phishing',
    'description': 'Complétez tous les défis "Emails"',
    'iconUrl': '',
    'condition': 'complete_all_email',
    'rarity': 'rare',
  },
  {
    'id': 'all_device',
    'name': 'Blindé',
    'description': 'Complétez tous les défis "Appareils"',
    'iconUrl': '',
    'condition': 'complete_all_device',
    'rarity': 'rare',
  },
  {
    'id': 'all_navigation',
    'name': 'Navigateur Pro',
    'description': 'Complétez tous les défis "Navigation"',
    'iconUrl': '',
    'condition': 'complete_all_navigation',
    'rarity': 'rare',
  },
  {
    'id': 'streak_7',
    'name': 'Semaine Parfaite',
    'description': 'Maintenez un streak de 7 jours',
    'iconUrl': '',
    'condition': 'streak_7',
    'rarity': 'epic',
  },
  {
    'id': 'streak_30',
    'name': 'Mois de Fer',
    'description': 'Maintenez un streak de 30 jours',
    'iconUrl': '',
    'condition': 'streak_30',
    'rarity': 'legendary',
  },
  {
    'id': 'score_50',
    'name': 'Demi-Bouclier',
    'description': 'Atteignez un score cyber de 50/100',
    'iconUrl': '',
    'condition': 'score_50',
    'rarity': 'common',
  },
  {
    'id': 'score_80',
    'name': 'Bouclier Renforcé',
    'description': 'Atteignez un score cyber de 80/100',
    'iconUrl': '',
    'condition': 'score_80',
    'rarity': 'epic',
  },
  {
    'id': 'score_100',
    'name': 'Invincible',
    'description': 'Atteignez un score cyber parfait de 100/100',
    'iconUrl': '',
    'condition': 'score_100',
    'rarity': 'legendary',
  },
  {
    'id': 'level_expert',
    'name': 'Expert Cyber',
    'description': 'Atteignez le niveau Expert',
    'iconUrl': '',
    'condition': 'reach_level_expert',
    'rarity': 'epic',
  },
  {
    'id': 'level_master',
    'name': 'Maître Cyber',
    'description': 'Atteignez le niveau Maître Cyber',
    'iconUrl': '',
    'condition': 'reach_level_master',
    'rarity': 'legendary',
  },
];

// ─── Guides ─────────────────────────────────────────────────────────────────

const _guides = [
  // --- Mots de passe ---
  {
    'id': 'guide_bitwarden_setup',
    'title': 'Configurer Bitwarden pas à pas',
    'category': 'passwords',
    'platforms': ['iOS', 'Android', 'Web'],
    'duration': 8,
    'tags': ['gestionnaire', 'bitwarden', 'mots de passe', 'gratuit'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Rendez-vous sur bitwarden.com et créez un compte. Choisissez un mot de passe maître très fort (phrase secrète de 4+ mots).',
      },
      {
        'stepNumber': 2,
        'text':
            'Téléchargez l\'application Bitwarden sur votre téléphone (App Store / Google Play).',
      },
      {
        'stepNumber': 3,
        'text':
            'Installez l\'extension Bitwarden sur votre navigateur (Chrome, Firefox, Safari).',
      },
      {
        'stepNumber': 4,
        'text':
            'Importez vos mots de passe existants depuis votre navigateur : Paramètres Bitwarden > Importer des données.',
      },
      {
        'stepNumber': 5,
        'text':
            'Activez le déverrouillage biométrique (Face ID / empreinte) pour un accès rapide.',
      },
    ],
  },
  {
    'id': 'guide_strong_passwords',
    'title': 'Créer des mots de passe vraiment forts',
    'category': 'passwords',
    'platforms': ['Tous'],
    'duration': 5,
    'tags': ['mots de passe', 'sécurité', 'technique'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Un bon mot de passe fait au minimum 12 caractères. Idéalement, utilisez des phrases secrètes de 16+ caractères.',
      },
      {
        'stepNumber': 2,
        'text':
            'N\'utilisez JAMAIS : votre date de naissance, le nom de votre animal, "123456", "password" ou "azerty".',
      },
      {
        'stepNumber': 3,
        'text':
            'Technique 1 : Phrase secrète — assemblez 4-5 mots sans lien. Ex : "soleil-brouette-jazz-cosmos7!".',
      },
      {
        'stepNumber': 4,
        'text':
            'Technique 2 : Générateur aléatoire — laissez votre gestionnaire créer des mots de passe de 20+ caractères.',
      },
      {
        'stepNumber': 5,
        'text':
            'Règle d\'or : un mot de passe unique par compte. Jamais de réutilisation !',
      },
    ],
  },

  // --- Authentification ---
  {
    'id': 'guide_2fa_google',
    'title': 'Activer la 2FA sur Gmail',
    'category': 'authentication',
    'platforms': ['Android', 'iOS', 'Web'],
    'duration': 5,
    'tags': ['2fa', 'gmail', 'google', 'email'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Allez sur myaccount.google.com > Sécurité > Validation en deux étapes.',
      },
      {
        'stepNumber': 2,
        'text': 'Cliquez sur "Commencer" et confirmez votre mot de passe.',
      },
      {
        'stepNumber': 3,
        'text':
            'Choisissez "Application Google Authenticator" comme méthode principale.',
      },
      {
        'stepNumber': 4,
        'text':
            'Scannez le QR code avec Google Authenticator ou Authy sur votre téléphone.',
      },
      {
        'stepNumber': 5,
        'text':
            'Sauvegardez les codes de récupération fournis (imprimez-les ou stockez-les dans votre gestionnaire de mots de passe).',
      },
    ],
  },
  {
    'id': 'guide_2fa_apple',
    'title': 'Activer la 2FA sur Apple ID',
    'category': 'authentication',
    'platforms': ['iOS', 'macOS'],
    'duration': 4,
    'tags': ['2fa', 'apple', 'iphone', 'mac'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Sur iPhone : Réglages > [Votre nom] > Mot de passe et sécurité > Activer l\'identification à deux facteurs.',
      },
      {
        'stepNumber': 2,
        'text':
            'Ajoutez un numéro de téléphone de confiance pour recevoir les codes de vérification.',
      },
      {
        'stepNumber': 3,
        'text':
            'Sur Mac : Préférences Système > Apple ID > Mot de passe et sécurité > Activer.',
      },
      {
        'stepNumber': 4,
        'text':
            'Conseil : ajoutez un deuxième numéro de confiance (ex : le numéro d\'un proche) en cas de perte de votre téléphone.',
      },
    ],
  },

  // --- Réseaux sociaux ---
  {
    'id': 'guide_instagram_privacy',
    'title': 'Paramètres de confidentialité Instagram',
    'category': 'social',
    'platforms': ['iOS', 'Android'],
    'duration': 5,
    'tags': ['instagram', 'réseaux sociaux', 'confidentialité', 'vie privée'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Ouvrez Instagram > votre profil > Menu (≡) > Paramètres et confidentialité.',
      },
      {
        'stepNumber': 2,
        'text':
            'Confidentialité du compte : activez "Compte privé" pour que seuls vos abonnés voient vos contenus.',
      },
      {
        'stepNumber': 3,
        'text':
            'Allez dans "Interactions" > Commentaires/Messages pour limiter qui peut vous contacter.',
      },
      {
        'stepNumber': 4,
        'text':
            'Vérifiez "Applications et sites web" et supprimez les accès aux services tiers que vous n\'utilisez plus.',
      },
      {
        'stepNumber': 5,
        'text':
            'Désactivez le "Statut d\'activité" pour ne pas montrer quand vous êtes en ligne.',
      },
    ],
  },
  {
    'id': 'guide_linkedin_privacy',
    'title': 'Protéger votre profil LinkedIn',
    'category': 'social',
    'platforms': ['Web', 'iOS', 'Android'],
    'duration': 5,
    'tags': ['linkedin', 'professionnel', 'réseaux sociaux', 'vie privée'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'LinkedIn > Paramètres > Visibilité : choisissez qui peut voir votre profil complet.',
      },
      {
        'stepNumber': 2,
        'text':
            'Désactivez "Partager les modifications de profil" pour ne pas alerter votre réseau à chaque changement.',
      },
      {
        'stepNumber': 3,
        'text':
            'Allez dans Confidentialité des données > vérifiez et limitez les données partagées avec des tiers.',
      },
      {
        'stepNumber': 4,
        'text':
            'Activez la 2FA : Paramètres > Identification et sécurité > Vérification en deux étapes.',
      },
    ],
  },

  // --- Emails ---
  {
    'id': 'guide_phishing_detection',
    'title': 'Identifier un email de phishing en 30 secondes',
    'category': 'email',
    'platforms': ['Tous'],
    'duration': 4,
    'tags': ['phishing', 'arnaque', 'email', 'sécurité'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Vérifiez l\'adresse de l\'expéditeur (pas juste le nom affiché). Ex : "service@amaz0n-security.xyz" est suspect.',
      },
      {
        'stepNumber': 2,
        'text':
            'Méfiez-vous de l\'urgence artificielle : "Votre compte sera supprimé dans 24h" est un signal d\'alerte.',
      },
      {
        'stepNumber': 3,
        'text':
            'Survolez les liens SANS cliquer : l\'URL de destination doit correspondre au site officiel.',
      },
      {
        'stepNumber': 4,
        'text':
            'Les fautes d\'orthographe et la mise en page approximative sont des indices courants.',
      },
      {
        'stepNumber': 5,
        'text':
            'En cas de doute : n\'ouvrez pas les pièces jointes. Allez directement sur le site officiel en tapant l\'URL vous-même.',
      },
    ],
  },
  {
    'id': 'guide_email_alias',
    'title': 'Utiliser des alias email avec SimpleLogin',
    'category': 'email',
    'platforms': ['Web', 'iOS', 'Android'],
    'duration': 6,
    'tags': ['alias', 'email', 'confidentialité', 'simplelogin'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Créez un compte sur simplelogin.io (gratuit jusqu\'à 10 alias).',
      },
      {
        'stepNumber': 2,
        'text':
            'Générez un premier alias (ex : shopping_xyz@simplelogin.co) pour vos achats en ligne.',
      },
      {
        'stepNumber': 3,
        'text':
            'Les emails envoyés à l\'alias sont redirigés vers votre vraie boîte mail.',
      },
      {
        'stepNumber': 4,
        'text':
            'Si un alias reçoit du spam, vous pouvez le désactiver en un clic sans affecter votre vraie adresse.',
      },
      {
        'stepNumber': 5,
        'text':
            'Installez l\'extension navigateur pour générer des alias en un clic lors de vos inscriptions.',
      },
    ],
  },

  // --- Appareils ---
  {
    'id': 'guide_iphone_security',
    'title': 'Sécuriser votre iPhone en 10 minutes',
    'category': 'device',
    'platforms': ['iOS'],
    'duration': 10,
    'tags': ['iphone', 'ios', 'sécurité', 'apple'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Activez Face ID ou Touch ID : Réglages > Face ID et code > Configurer.',
      },
      {
        'stepNumber': 2,
        'text':
            'Utilisez un code à 6 chiffres minimum (ou alphanumérique pour plus de sécurité).',
      },
      {
        'stepNumber': 3,
        'text':
            'Activez "Localiser mon iPhone" : Réglages > [Votre nom] > Localiser.',
      },
      {
        'stepNumber': 4,
        'text':
            'Mises à jour automatiques : Réglages > Général > Mise à jour logicielle > Mises à jour automatiques.',
      },
      {
        'stepNumber': 5,
        'text':
            'Sauvegarde iCloud : Réglages > [Votre nom] > iCloud > Sauvegarde iCloud > Activer.',
      },
      {
        'stepNumber': 6,
        'text':
            'Vérifiez les permissions : Réglages > Confidentialité et sécurité > passez en revue chaque permission.',
      },
    ],
  },
  {
    'id': 'guide_android_security',
    'title': 'Sécuriser votre Android en 10 minutes',
    'category': 'device',
    'platforms': ['Android'],
    'duration': 10,
    'tags': ['android', 'sécurité', 'google'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Activez le verrouillage biométrique : Paramètres > Sécurité > Verrouillage de l\'écran > Empreinte / visage.',
      },
      {
        'stepNumber': 2,
        'text':
            'Activez Google Play Protect : Play Store > profil > Play Protect > Activer l\'analyse.',
      },
      {
        'stepNumber': 3,
        'text':
            'Mises à jour : Paramètres > Système > Mise à jour système. Activez les mises à jour automatiques.',
      },
      {
        'stepNumber': 4,
        'text':
            'Localisation : Paramètres > Sécurité > Trouver mon appareil > Activer.',
      },
      {
        'stepNumber': 5,
        'text':
            'Sauvegarde : Paramètres > Système > Sauvegarde > Activer la sauvegarde sur Google Drive.',
      },
      {
        'stepNumber': 6,
        'text':
            'Permissions : Paramètres > Applications > Permissions. Retirez les accès inutiles.',
      },
    ],
  },

  // --- Navigation ---
  {
    'id': 'guide_browser_privacy',
    'title': 'Configurer Firefox pour la vie privée',
    'category': 'navigation',
    'platforms': ['Windows', 'macOS', 'Linux'],
    'duration': 7,
    'tags': ['firefox', 'navigateur', 'vie privée', 'trackers'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Téléchargez Firefox depuis mozilla.org si ce n\'est pas déjà fait.',
      },
      {
        'stepNumber': 2,
        'text':
            'Allez dans Paramètres > Vie privée et sécurité > Protection renforcée contre le pistage > Stricte.',
      },
      {
        'stepNumber': 3,
        'text':
            'Installez l\'extension uBlock Origin pour bloquer pubs et trackers.',
      },
      {
        'stepNumber': 4,
        'text':
            'Activez DNS-over-HTTPS : Paramètres > Vie privée et sécurité > DNS via HTTPS > Activer.',
      },
      {
        'stepNumber': 5,
        'text':
            'Configurez la suppression automatique : cochez "Supprimer les cookies et données de sites à la fermeture de Firefox".',
      },
    ],
  },
  {
    'id': 'guide_public_wifi',
    'title': 'Se protéger sur le Wi-Fi public',
    'category': 'navigation',
    'platforms': ['Tous'],
    'duration': 4,
    'tags': ['wifi', 'vpn', 'sécurité', 'voyage'],
    'views': 0,
    'steps': [
      {
        'stepNumber': 1,
        'text':
            'Règle n°1 : ne jamais accéder à votre banque ou saisir des mots de passe sur un Wi-Fi public sans VPN.',
      },
      {
        'stepNumber': 2,
        'text':
            'Activez votre VPN AVANT de vous connecter au réseau Wi-Fi public.',
      },
      {
        'stepNumber': 3,
        'text':
            'Désactivez le partage de fichiers et AirDrop quand vous êtes en public.',
      },
      {
        'stepNumber': 4,
        'text':
            'Oubliez le réseau après utilisation : votre appareil ne doit pas se reconnecter automatiquement.',
      },
    ],
  },
];

const List<Map<String, dynamic>> _quizzes = [
  {
    'id': 'quiz_passwords',
    'title': 'Les mots de passe',
    'category': 'passwords',
    'difficulty': 'easy',
    'points': 15,
    'isActive': true,
    'questions': [
      {
        'question': 'Quelle est la longueur minimale recommandée pour un mot de passe sécurisé ?',
        'options': ['6 caractères', '8 caractères', '12 caractères', '4 caractères'],
        'correctIndex': 2,
        'explanation': 'L\'ANSSI recommande au minimum 12 caractères pour un mot de passe robuste.',
      },
      {
        'question': 'Quel est le type de mot de passe le plus sécurisé ?',
        'options': ['Votre date de naissance', 'Une phrase de passe de 5 mots', 'Le nom de votre animal', '"Password123!"'],
        'correctIndex': 1,
        'explanation': 'Une phrase de passe longue (5+ mots aléatoires) est plus sécurisée et plus facile à retenir.',
      },
      {
        'question': 'À quelle fréquence devez-vous changer votre mot de passe ?',
        'options': ['Tous les mois', 'Tous les 3 mois', 'Uniquement en cas de compromission', 'Jamais'],
        'correctIndex': 2,
        'explanation': 'Les experts recommandent de ne changer son mot de passe qu\'en cas de fuite ou compromission détectée.',
      },
      {
        'question': 'Quel outil est recommandé pour gérer ses mots de passe ?',
        'options': ['Un fichier texte', 'Un gestionnaire de mots de passe', 'Un post-it sur l\'écran', 'Le même mot de passe partout'],
        'correctIndex': 1,
        'explanation': 'Un gestionnaire de mots de passe (Bitwarden, 1Password...) génère et stocke vos mots de passe de manière sécurisée.',
      },
      {
        'question': 'Que devez-vous faire si un site a subi une fuite de données ?',
        'options': ['Rien, ce n\'est pas grave', 'Changer votre mot de passe sur ce site', 'Supprimer votre compte email', 'Éteindre votre ordinateur'],
        'correctIndex': 1,
        'explanation': 'Changez immédiatement votre mot de passe sur le site concerné, et sur tout autre site où vous utilisiez le même.',
      },
    ],
  },
  {
    'id': 'quiz_phishing',
    'title': 'Reconnaître le phishing',
    'category': 'email',
    'difficulty': 'medium',
    'points': 20,
    'isActive': true,
    'questions': [
      {
        'question': 'Quel indice révèle souvent un email de phishing ?',
        'options': ['L\'email vient de votre banque', 'L\'adresse de l\'expéditeur contient des fautes', 'L\'email est en français', 'Il contient un logo'],
        'correctIndex': 1,
        'explanation': 'Les adresses d\'expéditeur avec des fautes ou des domaines suspects (ex: banque-fr.xyz) sont un signal de phishing.',
      },
      {
        'question': 'Que faire si vous recevez un email urgent vous demandant de cliquer sur un lien ?',
        'options': ['Cliquer immédiatement', 'Vérifier l\'URL en survolant le lien', 'Répondre à l\'email', 'Le transférer à vos collègues'],
        'correctIndex': 1,
        'explanation': 'Survolez le lien (sans cliquer) pour vérifier qu\'il pointe vers le vrai site. En cas de doute, allez directement sur le site officiel.',
      },
      {
        'question': 'Quel type d\'information un email de phishing essaie-t-il de voler ?',
        'options': ['Votre adresse postale', 'Vos identifiants et mots de passe', 'Votre couleur préférée', 'Votre numéro de téléphone fixe'],
        'correctIndex': 1,
        'explanation': 'Le phishing vise principalement à voler vos identifiants de connexion, données bancaires ou informations personnelles sensibles.',
      },
      {
        'question': 'Quel est le meilleur réflexe face à un SMS suspect de "votre banque" ?',
        'options': ['Appeler le numéro dans le SMS', 'Appeler votre banque au numéro officiel', 'Cliquer sur le lien pour vérifier', 'Ignorer et supprimer sans rien faire'],
        'correctIndex': 1,
        'explanation': 'Contactez toujours votre banque via le numéro officiel (sur votre carte ou le site web), jamais via un lien ou numéro reçu par SMS.',
      },
      {
        'question': 'Comment s\'appelle le phishing ciblé visant une personne précise ?',
        'options': ['Spearphishing', 'Whaling', 'Smishing', 'Vishing'],
        'correctIndex': 0,
        'explanation': 'Le spearphishing est une attaque ciblée qui utilise des informations personnelles pour rendre l\'email plus crédible.',
      },
    ],
  },
  {
    'id': 'quiz_2fa',
    'title': 'L\'authentification à deux facteurs',
    'category': 'authentication',
    'difficulty': 'easy',
    'points': 15,
    'isActive': true,
    'questions': [
      {
        'question': 'Que signifie 2FA ?',
        'options': ['Two Factor Authentication', 'Two File Access', 'Two Firewall Alert', 'Two Free Accounts'],
        'correctIndex': 0,
        'explanation': '2FA = Two Factor Authentication (authentification à deux facteurs), une couche de sécurité supplémentaire.',
      },
      {
        'question': 'Quelle méthode 2FA est la MOINS sécurisée ?',
        'options': ['Application TOTP (Google Authenticator)', 'SMS', 'Clé de sécurité physique', 'Passkey'],
        'correctIndex': 1,
        'explanation': 'Le SMS est vulnérable au SIM swapping et à l\'interception. Préférez une app TOTP ou une clé physique.',
      },
      {
        'question': 'Que faire si vous perdez votre téléphone avec l\'app 2FA ?',
        'options': ['Créer un nouveau compte', 'Utiliser vos codes de récupération sauvegardés', 'Abandonner le compte', 'Appeler Google'],
        'correctIndex': 1,
        'explanation': 'Les codes de récupération (backup codes) fournis à l\'activation du 2FA permettent de retrouver l\'accès. Gardez-les en lieu sûr !',
      },
      {
        'question': 'Combien de comptes devriez-vous protéger avec le 2FA ?',
        'options': ['Seulement la banque', 'Email + banque + réseaux sociaux', 'Tous ceux qui le proposent', 'Aucun, c\'est trop compliqué'],
        'correctIndex': 2,
        'explanation': 'Activez le 2FA sur tous les comptes qui le proposent, en priorité email, banque et réseaux sociaux.',
      },
      {
        'question': 'Qu\'est-ce qu\'une passkey ?',
        'options': ['Un mot de passe très long', 'Une clé cryptographique liée à votre appareil', 'Un code SMS', 'Un email de vérification'],
        'correctIndex': 1,
        'explanation': 'Les passkeys sont des clés cryptographiques stockées sur votre appareil, plus sécurisées et pratiques que les mots de passe.',
      },
    ],
  },
  {
    'id': 'quiz_social',
    'title': 'Vie privée sur les réseaux',
    'category': 'social',
    'difficulty': 'medium',
    'points': 20,
    'isActive': true,
    'questions': [
      {
        'question': 'Quel paramètre devriez-vous vérifier en premier sur un réseau social ?',
        'options': ['La couleur du thème', 'Les paramètres de confidentialité', 'Le nombre d\'amis', 'Les notifications'],
        'correctIndex': 1,
        'explanation': 'Les paramètres de confidentialité déterminent qui peut voir vos publications, votre profil et vos informations personnelles.',
      },
      {
        'question': 'Pourquoi ne pas publier vos photos de vacances en temps réel ?',
        'options': ['Ça consomme de la data', 'Cela signale que votre domicile est vide', 'Les photos sont de mauvaise qualité', 'Ce n\'est pas intéressant'],
        'correctIndex': 1,
        'explanation': 'Publier en temps réel indique que vous n\'êtes pas chez vous, exposant votre domicile à un risque de cambriolage.',
      },
      {
        'question': 'Que permettent les données que vous partagez sur les réseaux sociaux ?',
        'options': ['Rien, c\'est juste pour les amis', 'Le ciblage publicitaire et le profilage', 'Améliorer la qualité du réseau', 'Protéger votre compte'],
        'correctIndex': 1,
        'explanation': 'Vos données sont utilisées pour le ciblage publicitaire, le profilage, et peuvent être exploitées par des cybercriminels.',
      },
      {
        'question': 'Que faire avant d\'accepter une demande d\'ami d\'un inconnu ?',
        'options': ['L\'accepter pour être poli', 'Vérifier si vous avez des amis en commun', 'Vérifier son profil et refuser si suspect', 'Lui envoyer un message'],
        'correctIndex': 2,
        'explanation': 'Vérifiez le profil (date de création, contenu, amis). Les faux profils servent souvent à collecter vos informations.',
      },
      {
        'question': 'Comment télécharger toutes vos données depuis un réseau social ?',
        'options': ['C\'est impossible', 'Via les paramètres > Télécharger vos données', 'En faisant une capture d\'écran', 'En contactant le support'],
        'correctIndex': 1,
        'explanation': 'Le RGPD vous donne le droit de télécharger vos données. Allez dans Paramètres > Confidentialité > Télécharger vos données.',
      },
    ],
  },
  {
    'id': 'quiz_devices',
    'title': 'Sécurité des appareils',
    'category': 'device',
    'difficulty': 'easy',
    'points': 15,
    'isActive': true,
    'questions': [
      {
        'question': 'Pourquoi est-il important de mettre à jour son téléphone ?',
        'options': ['Pour avoir de nouvelles couleurs', 'Pour corriger des failles de sécurité', 'Pour avoir plus de stockage', 'Ce n\'est pas important'],
        'correctIndex': 1,
        'explanation': 'Les mises à jour corrigent des vulnérabilités de sécurité connues qui pourraient être exploitées par des attaquants.',
      },
      {
        'question': 'Quel type de verrouillage est le plus sécurisé pour un smartphone ?',
        'options': ['Glissement (swipe)', 'Code à 4 chiffres', 'Empreinte digitale + code à 6 chiffres', 'Aucun verrouillage'],
        'correctIndex': 2,
        'explanation': 'La biométrie (empreinte, Face ID) combinée à un code long offre le meilleur compromis sécurité/praticité.',
      },
      {
        'question': 'Que risquez-vous en branchant une clé USB inconnue ?',
        'options': ['Rien, c\'est juste du stockage', 'Une infection par malware', 'Une mise à jour automatique', 'Un formatage du disque'],
        'correctIndex': 1,
        'explanation': 'Une clé USB peut contenir des malwares qui s\'exécutent automatiquement. N\'utilisez jamais une clé USB d\'origine inconnue.',
      },
      {
        'question': 'Comment protéger vos données en cas de vol de votre téléphone ?',
        'options': ['Écrire son code PIN sur le téléphone', 'Activer le chiffrement et la localisation à distance', 'Mettre un autocollant avec son numéro', 'Rien, le code PIN suffit'],
        'correctIndex': 1,
        'explanation': 'Le chiffrement protège vos données et la localisation à distance permet d\'effacer le téléphone en cas de vol.',
      },
      {
        'question': 'Quelle est la meilleure pratique pour les applications ?',
        'options': ['Installer depuis n\'importe quel site', 'N\'installer que depuis les stores officiels', 'Installer un maximum d\'apps', 'Ne jamais mettre à jour les apps'],
        'correctIndex': 1,
        'explanation': 'Les stores officiels (App Store, Play Store) vérifient les applications. Évitez les sources tierces non vérifiées.',
      },
    ],
  },
  {
    'id': 'quiz_navigation',
    'title': 'Navigation sécurisée',
    'category': 'navigation',
    'difficulty': 'medium',
    'points': 20,
    'isActive': true,
    'questions': [
      {
        'question': 'Que signifie le cadenas dans la barre d\'adresse du navigateur ?',
        'options': ['Le site est 100% sûr', 'La connexion est chiffrée (HTTPS)', 'Le site est gouvernemental', 'Votre antivirus est actif'],
        'correctIndex': 1,
        'explanation': 'Le cadenas indique une connexion HTTPS chiffrée, mais ne garantit pas que le site est légitime — un site de phishing peut aussi avoir HTTPS.',
      },
      {
        'question': 'Quel est le risque d\'un Wi-Fi public non protégé ?',
        'options': ['Connexion lente', 'Interception de vos données (man-in-the-middle)', 'Batterie qui se décharge', 'Aucun risque'],
        'correctIndex': 1,
        'explanation': 'Sur un Wi-Fi public, un attaquant peut intercepter vos données non chiffrées. Utilisez un VPN pour vous protéger.',
      },
      {
        'question': 'Qu\'est-ce qu\'un VPN ?',
        'options': ['Un antivirus', 'Un tunnel chiffré pour votre connexion internet', 'Un type de Wi-Fi', 'Un navigateur web'],
        'correctIndex': 1,
        'explanation': 'Un VPN (Virtual Private Network) crée un tunnel chiffré qui protège vos données, surtout sur les réseaux publics.',
      },
      {
        'question': 'Quel DNS est recommandé pour plus de sécurité ?',
        'options': ['Le DNS de votre FAI', 'Un DNS chiffré (DoH/DoT) comme Quad9 ou Cloudflare', 'Google DNS non chiffré', 'Aucun DNS'],
        'correctIndex': 1,
        'explanation': 'Les DNS chiffrés (DNS over HTTPS/TLS) comme Quad9 (9.9.9.9) protègent vos requêtes DNS contre l\'espionnage et le filtrage.',
      },
      {
        'question': 'Que devez-vous vérifier avant d\'entrer vos identifiants sur un site ?',
        'options': ['Que le site a de belles couleurs', 'Que l\'URL est exacte et commence par https://', 'Que le site charge rapidement', 'Que le site a des publicités'],
        'correctIndex': 1,
        'explanation': 'Vérifiez toujours l\'URL exacte (attention aux typos comme goog1e.com) et la présence du HTTPS avant de saisir des informations sensibles.',
      },
    ],
  },
];
