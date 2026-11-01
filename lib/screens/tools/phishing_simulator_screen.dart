import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class _PhishingScenario {
  final String sender;
  final String senderEmail;
  final String subject;
  final String body;
  final bool isPhishing;
  final String explanation;
  final List<String> redFlags;

  const _PhishingScenario({
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.body,
    required this.isPhishing,
    required this.explanation,
    this.redFlags = const [],
  });
}

const _scenarios = [
  _PhishingScenario(
    sender: 'Service Client Amazon',
    senderEmail: 'service@amazon-secure-verify.com',
    subject: 'Action requise : Vérifiez votre compte immédiatement',
    body: 'Cher client,\n\nNous avons détecté une activité suspecte sur votre compte. Veuillez cliquer sur le lien ci-dessous pour vérifier votre identité dans les 24 heures, sinon votre compte sera suspendu.\n\n[Vérifier mon compte]',
    isPhishing: true,
    explanation: 'Le domaine de l\'expéditeur (amazon-secure-verify.com) n\'est pas le domaine officiel d\'Amazon. Le message crée un sentiment d\'urgence artificiel.',
    redFlags: ['Domaine suspect', 'Urgence artificielle', 'Menace de suspension'],
  ),
  _PhishingScenario(
    sender: 'Netflix',
    senderEmail: 'info@account.netflix.com',
    subject: 'Votre reçu de paiement',
    body: 'Bonjour,\n\nMerci pour votre paiement de 13,49 € pour votre abonnement Netflix Standard. Votre prochaine date de facturation est le 15 décembre 2024.\n\nCordialement,\nL\'équipe Netflix',
    isPhishing: false,
    explanation: 'Cet email provient bien du domaine officiel de Netflix (account.netflix.com). Il contient des informations cohérentes et ne demande aucune action urgente.',
  ),
  _PhishingScenario(
    sender: 'La Banque Postale',
    senderEmail: 'securite@la-banque-postale.net',
    subject: 'URGENT : Mise à jour de sécurité obligatoire',
    body: 'Madame, Monsieur,\n\nSuite aux nouvelles réglementations européennes, nous vous demandons de mettre à jour vos informations bancaires en cliquant sur le lien sécurisé ci-dessous.\n\nSans action de votre part sous 48h, votre accès sera bloqué.\n\n[Mettre à jour mes informations]',
    isPhishing: true,
    explanation: 'Le domaine .net n\'est pas le domaine officiel de La Banque Postale (.fr). Une banque ne demande jamais de mettre à jour ses informations par email.',
    redFlags: ['Domaine incorrect (.net)', 'Demande d\'informations bancaires', 'Délai imposé'],
  ),
  _PhishingScenario(
    sender: 'Ameli',
    senderEmail: 'ne-pas-repondre@assurance-maladie.fr',
    subject: 'Vous avez un nouveau message',
    body: 'Bonjour,\n\nUn nouveau message est disponible dans votre espace personnel Ameli.\n\nPour le consulter, connectez-vous à votre compte sur ameli.fr.\n\nCordialement,\nL\'Assurance Maladie',
    isPhishing: false,
    explanation: 'L\'email provient du domaine officiel de l\'Assurance Maladie. Il ne contient pas de lien direct mais invite à se connecter sur le site officiel.',
  ),
  _PhishingScenario(
    sender: 'Service des Impôts',
    senderEmail: 'remboursement@dgfip-gouv.fr',
    subject: 'Remboursement de 287,43 € en attente',
    body: 'Madame, Monsieur,\n\nAprès un recalcul de votre situation fiscale, un trop-perçu de 287,43 € a été identifié. Pour recevoir votre remboursement, veuillez renseigner vos coordonnées bancaires via le formulaire sécurisé.\n\n[Réclamer mon remboursement]',
    isPhishing: true,
    explanation: 'Le domaine dgfip-gouv.fr imite dgfip.finances.gouv.fr (le vrai domaine). Les impôts ne demandent jamais vos coordonnées bancaires par email.',
    redFlags: ['Domaine imitant un site officiel', 'Demande de coordonnées bancaires', 'Appât financier'],
  ),
  _PhishingScenario(
    sender: 'Google',
    senderEmail: 'no-reply@accounts.google.com',
    subject: 'Alerte de sécurité',
    body: 'Bonjour,\n\nUne connexion à votre compte Google a été effectuée depuis un nouvel appareil (Windows, Paris, France) le 28 octobre à 14:32.\n\nSi c\'est bien vous, aucune action n\'est nécessaire.\nSi ce n\'est pas vous, sécurisez votre compte.\n\n[Vérifier l\'activité]',
    isPhishing: false,
    explanation: 'Google envoie effectivement ce type de notification depuis accounts.google.com. Le message ne crée pas de panique et propose une action optionnelle.',
  ),
  _PhishingScenario(
    sender: 'Chronopost',
    senderEmail: 'suivi@chronopost-livraison.info',
    subject: 'Votre colis est en attente — frais de livraison à régler',
    body: 'Bonjour,\n\nVotre colis n°CP389201847FR est en attente de livraison. Des frais de 1,99 € sont nécessaires pour finaliser la livraison.\n\nRéglez rapidement pour recevoir votre colis.\n\n[Payer 1,99 €]',
    isPhishing: true,
    explanation: 'Le domaine chronopost-livraison.info n\'est pas le site officiel de Chronopost. L\'arnaque au colis avec micro-paiement est très répandue en France.',
    redFlags: ['Domaine non officiel', 'Micro-paiement suspect', 'Numéro de colis générique'],
  ),
  _PhishingScenario(
    sender: 'Spotify',
    senderEmail: 'noreply@spotify.com',
    subject: 'Votre Wrapped 2024 est prêt !',
    body: 'Bonjour,\n\nVotre récap musical de l\'année est disponible ! Découvrez vos artistes, titres et podcasts les plus écoutés en 2024.\n\nOuvrez l\'app Spotify pour voir votre Wrapped.\n\nÀ bientôt,\nL\'équipe Spotify',
    isPhishing: false,
    explanation: 'L\'email provient du domaine officiel Spotify et invite à ouvrir l\'app directement plutôt que de cliquer sur un lien suspect.',
  ),
  _PhishingScenario(
    sender: 'WhatsApp',
    senderEmail: 'support@whatsapp-verify.com',
    subject: 'Votre compte sera désactivé',
    body: 'ATTENTION !\n\nVotre compte WhatsApp sera désactivé si vous ne confirmez pas vos informations dans les 12 prochaines heures.\n\nCliquez ici pour confirmer votre numéro de téléphone et éviter la suppression.\n\n[Confirmer mon compte]',
    isPhishing: true,
    explanation: 'WhatsApp ne contacte jamais ses utilisateurs par email pour vérifier leur compte. Le domaine whatsapp-verify.com est frauduleux.',
    redFlags: ['Domaine frauduleux', 'Urgence extrême', 'WhatsApp ne contacte pas par email'],
  ),
  _PhishingScenario(
    sender: 'EDF',
    senderEmail: 'ne-pas-repondre@edf.fr',
    subject: 'Votre facture du mois d\'octobre est disponible',
    body: 'Bonjour,\n\nVotre facture d\'électricité du mois d\'octobre 2024 est disponible dans votre espace client EDF.\n\nMontant : 89,74 €\nDate limite de paiement : 15 novembre 2024\n\nRetrouvez le détail sur edf.fr.\n\nCordialement,\nEDF',
    isPhishing: false,
    explanation: 'L\'email vient du domaine officiel EDF. Il contient des informations spécifiques et invite à consulter l\'espace client officiel.',
  ),
];

class PhishingSimulatorScreen extends ConsumerStatefulWidget {
  const PhishingSimulatorScreen({super.key});

  @override
  ConsumerState<PhishingSimulatorScreen> createState() =>
      _PhishingSimulatorScreenState();
}

enum _ScreenPhase { intro, playing, results }

class _PhishingSimulatorScreenState
    extends ConsumerState<PhishingSimulatorScreen> {
  _ScreenPhase _phase = _ScreenPhase.intro;
  int _currentIndex = 0;
  bool? _answered;
  final List<bool> _results = [];

  void _start() => setState(() => _phase = _ScreenPhase.playing);

  void _answer(bool saidPhishing) {
    if (_answered != null) return;
    final correct = saidPhishing == _scenarios[_currentIndex].isPhishing;
    _results.add(correct);
    setState(() => _answered = saidPhishing);
  }

  void _next() {
    if (_currentIndex + 1 >= _scenarios.length) {
      setState(() => _phase = _ScreenPhase.results);
    } else {
      setState(() {
        _currentIndex++;
        _answered = null;
      });
    }
  }

  void _restart() {
    setState(() {
      _phase = _ScreenPhase.intro;
      _currentIndex = 0;
      _answered = null;
      _results.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_phase) {
          _ScreenPhase.intro => _IntroView(onStart: _start),
          _ScreenPhase.playing => _PlayingView(
              scenario: _scenarios[_currentIndex],
              index: _currentIndex,
              total: _scenarios.length,
              answered: _answered,
              wasCorrect:
                  _answered != null ? _results.last : null,
              onAnswer: _answer,
              onNext: _next,
            ),
          _ScreenPhase.results => _ResultsView(
              results: _results,
              onRestart: _restart,
            ),
        },
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.error.withOpacity(0.8),
                  AppColors.accent,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.phishing_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            'Simulateur de Phishing',
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '10 scénarios',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Vous allez recevoir 10 emails. Pour chacun, déterminez '
              's\'il s\'agit d\'un email de phishing ou d\'un email légitime.\n\n'
              'Analysez l\'expéditeur, le contenu et le ton du message pour prendre votre décision.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              child: const Text('Commencer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  final _PhishingScenario scenario;
  final int index;
  final int total;
  final bool? answered;
  final bool? wasCorrect;
  final void Function(bool saidPhishing) onAnswer;
  final VoidCallback onNext;

  const _PlayingView({
    required this.scenario,
    required this.index,
    required this.total,
    required this.answered,
    required this.wasCorrect,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${index + 1}/$total',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Email card + buttons
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email card
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: answered != null
                          ? (scenario.isPhishing
                              ? AppColors.error.withOpacity(0.4)
                              : AppColors.secondary.withOpacity(0.4))
                          : theme.dividerColor.withOpacity(0.3),
                      width: answered != null ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      scenario.sender[0],
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scenario.sender,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        scenario.senderEmail,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              scenario.subject,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Email body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          scenario.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Answer buttons or result
                if (answered == null)
                  _AnswerButtons(onAnswer: onAnswer)
                else
                  _RevealSection(
                    scenario: scenario,
                    saidPhishing: answered!,
                    wasCorrect: wasCorrect!,
                    onNext: onNext,
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerButtons extends StatelessWidget {
  final void Function(bool saidPhishing) onAnswer;
  const _AnswerButtons({required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onAnswer(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text('🎣', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    'Phishing',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onAnswer(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text('✓', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    'Légitime',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RevealSection extends StatelessWidget {
  final _PhishingScenario scenario;
  final bool saidPhishing;
  final bool wasCorrect;
  final VoidCallback onNext;

  const _RevealSection({
    required this.scenario,
    required this.saidPhishing,
    required this.wasCorrect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultColor = wasCorrect ? AppColors.secondary : AppColors.error;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Correct / Incorrect banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: resultColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    wasCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: resultColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wasCorrect ? 'Bonne réponse !' : 'Mauvaise réponse',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: resultColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scenario.isPhishing
                            ? 'C\'était bien du phishing'
                            : 'C\'était un email légitime',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Explication',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  scenario.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                if (scenario.redFlags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: scenario.redFlags.map((flag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              flag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final List<bool> results;
  final VoidCallback onRestart;

  const _ResultsView({
    required this.results,
    required this.onRestart,
  });

  int get _score => results.where((r) => r).length;

  String get _message {
    final s = _score;
    if (s == 10) return 'Parfait ! Vous êtes un expert anti-phishing';
    if (s >= 8) return 'Excellent ! Vous avez de bons réflexes';
    if (s >= 6) return 'Pas mal ! Restez vigilant';
    return 'Attention ! Entraînez-vous davantage';
  }

  String get _emoji {
    final s = _score;
    if (s == 10) return '🏆';
    if (s >= 8) return '🎯';
    if (s >= 6) return '👍';
    return '📚';
  }

  Color get _scoreColor {
    final s = _score;
    if (s >= 8) return AppColors.secondary;
    if (s >= 6) return AppColors.accent;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Text(_emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$_score',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: _scoreColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' / ${results.length}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Breakdown
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: List.generate(_scenarios.length, (i) {
                final correct = results[i];
                final sc = _scenarios[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: i < _scenarios.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withOpacity(0.2),
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: correct
                              ? AppColors.secondary.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          correct
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          size: 16,
                          color:
                              correct ? AppColors.secondary : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sc.sender,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sc.subject,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sc.isPhishing
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sc.isPhishing ? 'Phishing' : 'Légitime',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: sc.isPhishing
                                ? AppColors.error
                                : AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onRestart,
              child: const Text('Recommencer'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour aux outils'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
