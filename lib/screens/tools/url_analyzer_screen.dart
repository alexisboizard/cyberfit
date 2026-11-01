import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class UrlAnalyzerScreen extends ConsumerStatefulWidget {
  const UrlAnalyzerScreen({super.key});

  @override
  ConsumerState<UrlAnalyzerScreen> createState() => _UrlAnalyzerScreenState();
}

class _UrlAnalyzerScreenState extends ConsumerState<UrlAnalyzerScreen> {
  final _controller = TextEditingController();
  _AnalysisResult? _result;
  bool _tipsExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _result = _analyzeUrl(url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text('Analyse d\'URL', style: theme.textTheme.displaySmall),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text(
                    'Collez un lien suspect pour vérifier s\'il est fiable.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'URL à analyser',
                      hintText: 'https://exemple.com/page',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                    onFieldSubmitted: (_) => _analyze(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _analyze,
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: const Text('Analyser'),
                    ),
                  ),
                  if (_result != null) ...[
                    const SizedBox(height: 28),
                    _RiskBanner(result: _result!),
                    const SizedBox(height: 20),
                    _ChecksList(checks: _result!.checks),
                    if (_result!.recommendations.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _RecommendationsCard(recommendations: _result!.recommendations),
                    ],
                  ],
                  const SizedBox(height: 28),
                  _TipsSection(
                    expanded: _tipsExpanded,
                    onToggle: () => setState(() => _tipsExpanded = !_tipsExpanded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Analysis engine ----------

enum _RiskLevel { safe, caution, suspect, dangerous }

class _CheckResult {
  final String label;
  final bool passed;
  final String detail;
  final int penalty;

  const _CheckResult({
    required this.label,
    required this.passed,
    required this.detail,
    this.penalty = 0,
  });
}

class _AnalysisResult {
  final int score;
  final _RiskLevel level;
  final List<_CheckResult> checks;
  final List<String> recommendations;

  const _AnalysisResult({
    required this.score,
    required this.level,
    required this.checks,
    required this.recommendations,
  });
}

const _suspiciousTlds = [
  '.xyz', '.tk', '.ml', '.ga', '.cf', '.buzz',
  '.click', '.link', '.top', '.gq', '.work', '.rest',
];

const _typosquatPatterns = <String, String>{
  'g00gle': 'google',
  'go0gle': 'google',
  'googIe': 'google',
  'gooogle': 'google',
  'amaz0n': 'amazon',
  'amazom': 'amazon',
  'arnazon': 'amazon',
  'paypa1': 'paypal',
  'paypaI': 'paypal',
  'paypol': 'paypal',
  'faceb00k': 'facebook',
  'faceboook': 'facebook',
  'micros0ft': 'microsoft',
  'microsooft': 'microsoft',
  'netfIix': 'netflix',
  'netfl1x': 'netflix',
  'app1e': 'apple',
  'appIe': 'apple',
  'instagran': 'instagram',
  'lnstagram': 'instagram',
};

const _suspiciousPathKeywords = [
  '/login', '/signin', '/verify', '/secure', '/account',
  '/update', '/confirm', '/banking', '/password', '/reset',
];

final _ipPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');

_AnalysisResult _analyzeUrl(String raw) {
  final checks = <_CheckResult>[];
  final recommendations = <String>[];
  var totalPenalty = 0;

  Uri? uri;
  try {
    if (!raw.contains('://')) raw = 'http://$raw';
    uri = Uri.parse(raw);
  } catch (_) {}

  if (uri == null || uri.host.isEmpty) {
    return _AnalysisResult(
      score: 100,
      level: _RiskLevel.dangerous,
      checks: [
        const _CheckResult(
          label: 'Format de l\'URL',
          passed: false,
          detail: 'L\'URL n\'a pas pu être analysée — format invalide.',
          penalty: 100,
        ),
      ],
      recommendations: ['Vérifiez que l\'URL est correctement formée.'],
    );
  }

  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();

  // 1. Protocol
  final isHttps = uri.scheme == 'https';
  checks.add(_CheckResult(
    label: 'Protocole HTTPS',
    passed: isHttps,
    detail: isHttps
        ? 'La connexion est chiffrée (HTTPS).'
        : 'Ce site n\'utilise pas HTTPS — vos données ne sont pas chiffrées.',
    penalty: isHttps ? 0 : 20,
  ));
  if (!isHttps) {
    totalPenalty += 20;
    recommendations.add('Privilégiez toujours les sites en HTTPS.');
  }

  // 2. Suspicious TLD
  final hasSuspiciousTld = _suspiciousTlds.any((tld) => host.endsWith(tld));
  checks.add(_CheckResult(
    label: 'Extension du domaine',
    passed: !hasSuspiciousTld,
    detail: hasSuspiciousTld
        ? 'L\'extension du domaine (${host.substring(host.lastIndexOf('.'))}) est fréquemment utilisée dans les arnaques.'
        : 'L\'extension du domaine semble classique.',
    penalty: hasSuspiciousTld ? 25 : 0,
  ));
  if (hasSuspiciousTld) {
    totalPenalty += 25;
    recommendations.add('Méfiez-vous des extensions inhabituelles.');
  }

  // 3. IP address as domain
  final isIp = _ipPattern.hasMatch(host);
  checks.add(_CheckResult(
    label: 'Adresse IP',
    passed: !isIp,
    detail: isIp
        ? 'Le site utilise une adresse IP au lieu d\'un nom de domaine — c\'est suspect.'
        : 'Un nom de domaine classique est utilisé.',
    penalty: isIp ? 30 : 0,
  ));
  if (isIp) {
    totalPenalty += 30;
    recommendations.add('Ne faites jamais confiance à un lien vers une adresse IP.');
  }

  // 4. @ symbol
  final hasAt = raw.contains('@');
  checks.add(_CheckResult(
    label: 'Symbole @',
    passed: !hasAt,
    detail: hasAt
        ? 'Le symbole @ dans l\'URL peut rediriger vers un autre site que celui affiché.'
        : 'Aucun symbole @ détecté.',
    penalty: hasAt ? 25 : 0,
  ));
  if (hasAt) {
    totalPenalty += 25;
    recommendations.add('Le @ dans une URL est une technique de tromperie — évitez ce lien.');
  }

  // 5. Typosquatting
  String? typoMatch;
  for (final entry in _typosquatPatterns.entries) {
    if (host.contains(entry.key.toLowerCase())) {
      typoMatch = entry.value;
      break;
    }
  }
  checks.add(_CheckResult(
    label: 'Typosquatting',
    passed: typoMatch == null,
    detail: typoMatch != null
        ? 'Le domaine ressemble à « $typoMatch » avec des caractères modifiés — usurpation probable.'
        : 'Aucune imitation de marque détectée.',
    penalty: typoMatch != null ? 30 : 0,
  ));
  if (typoMatch != null) {
    totalPenalty += 30;
    recommendations.add('Vérifiez l\'orthographe exacte du domaine avant de continuer.');
  }

  // 6. Excessive length
  final isTooLong = raw.length > 100;
  checks.add(_CheckResult(
    label: 'Longueur de l\'URL',
    passed: !isTooLong,
    detail: isTooLong
        ? 'L\'URL est anormalement longue (${raw.length} caractères) — technique fréquente pour masquer la destination.'
        : 'La longueur de l\'URL est raisonnable.',
    penalty: isTooLong ? 10 : 0,
  ));
  if (isTooLong) totalPenalty += 10;

  // 7. Excessive subdomains
  final subdomainCount = host.split('.').length - 2;
  final tooManySubdomains = subdomainCount > 3;
  checks.add(_CheckResult(
    label: 'Sous-domaines',
    passed: !tooManySubdomains,
    detail: tooManySubdomains
        ? 'Le domaine contient $subdomainCount sous-domaines — c\'est inhabituel.'
        : 'Nombre de sous-domaines normal.',
    penalty: tooManySubdomains ? 15 : 0,
  ));
  if (tooManySubdomains) {
    totalPenalty += 15;
    recommendations.add('Un excès de sous-domaines est souvent utilisé pour tromper.');
  }

  // 8. Suspicious path + non-trusted domain
  final trustedDomains = [
    'google.com', 'facebook.com', 'apple.com', 'microsoft.com',
    'amazon.com', 'paypal.com', 'instagram.com', 'twitter.com',
    'netflix.com', 'linkedin.com', 'gouv.fr', 'impots.gouv.fr',
  ];
  final isTrusted = trustedDomains.any((d) => host == d || host.endsWith('.$d'));
  final hasSuspiciousPath = _suspiciousPathKeywords.any((kw) => path.contains(kw));
  final suspiciousPathCombo = hasSuspiciousPath && !isTrusted;
  checks.add(_CheckResult(
    label: 'Chemin sensible',
    passed: !suspiciousPathCombo,
    detail: suspiciousPathCombo
        ? 'Le chemin contient des mots-clés sensibles (login, verify…) sur un domaine non vérifié.'
        : hasSuspiciousPath
            ? 'Page de connexion sur un domaine connu — normal.'
            : 'Aucun chemin sensible détecté.',
    penalty: suspiciousPathCombo ? 20 : 0,
  ));
  if (suspiciousPathCombo) {
    totalPenalty += 20;
    recommendations.add('Ne saisissez jamais vos identifiants sur un site dont vous n\'êtes pas sûr.');
  }

  // 9. URL encoding abuse
  final encodingCount = RegExp(r'%[0-9a-fA-F]{2}').allMatches(raw).length;
  final excessiveEncoding = encodingCount > 5;
  checks.add(_CheckResult(
    label: 'Encodage suspect',
    passed: !excessiveEncoding,
    detail: excessiveEncoding
        ? 'L\'URL contient beaucoup de caractères encodés ($encodingCount) — tentative possible de masquage.'
        : 'Pas d\'encodage excessif.',
    penalty: excessiveEncoding ? 15 : 0,
  ));
  if (excessiveEncoding) totalPenalty += 15;

  final clampedScore = totalPenalty.clamp(0, 100);
  final level = switch (clampedScore) {
    <= 20 => _RiskLevel.safe,
    <= 40 => _RiskLevel.caution,
    <= 60 => _RiskLevel.suspect,
    _ => _RiskLevel.dangerous,
  };

  if (recommendations.isEmpty && clampedScore == 0) {
    recommendations.add('Cette URL ne présente aucun signe suspect évident. Restez vigilant.');
  }

  return _AnalysisResult(
    score: clampedScore,
    level: level,
    checks: checks,
    recommendations: recommendations,
  );
}

// ---------- Widgets ----------

class _RiskBanner extends StatelessWidget {
  final _AnalysisResult result;
  const _RiskBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (result.level) {
      _RiskLevel.safe => ('Sûr', Icons.check_circle_rounded, AppColors.secondary),
      _RiskLevel.caution => ('Attention', Icons.info_rounded, AppColors.accent),
      _RiskLevel.suspect => ('Suspect', Icons.warning_rounded, AppColors.devices),
      _RiskLevel.dangerous => ('Dangereux', Icons.dangerous_rounded, AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score de risque : ${result.score}/100',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecksList extends StatelessWidget {
  final List<_CheckResult> checks;
  const _ChecksList({required this.checks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text('Détail des vérifications', style: theme.textTheme.titleMedium),
          ),
          ...checks.map((c) => _CheckTile(check: c)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final _CheckResult check;
  const _CheckTile({required this.check});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = check.passed ? AppColors.secondary : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            check.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.label,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(check.detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;
  const _RecommendationsCard({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommandations',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: theme.textTheme.bodyMedium),
                    Expanded(child: Text(r, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _TipsSection({required this.expanded, required this.onToggle});

  static const _tips = [
    (
      'Typosquatting',
      'Les escrocs enregistrent des domaines proches de marques connues en changeant une lettre (ex. g00gle.com, arnazon.com).'
    ),
    (
      'Adresse IP',
      'Un lien vers une adresse IP (ex. http://192.168.1.1/login) n\'est presque jamais légitime.'
    ),
    (
      'Le piège du @',
      'Dans une URL, tout ce qui précède le @ est ignoré. http://google.com@evil.com mène vers evil.com.'
    ),
    (
      'Sous-domaines trompeurs',
      'secure.paypal.com.evil.org est un sous-domaine de evil.org, pas de PayPal.'
    ),
    (
      'URLs raccourcies',
      'Les raccourcisseurs (bit.ly, tinyurl…) masquent la destination réelle. Utilisez un outil de prévisualisation avant de cliquer.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.school_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Astuces : reconnaître les URLs piégées',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                children: _tips
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline_rounded,
                                  size: 18, color: AppColors.accent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.$1,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(t.$2, style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
