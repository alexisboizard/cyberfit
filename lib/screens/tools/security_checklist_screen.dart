import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

const _storageKey = 'security_checklist';

class _ChecklistCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<_ChecklistItem> items;

  const _ChecklistCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _ChecklistItem {
  final String id;
  final String label;

  const _ChecklistItem({required this.id, required this.label});
}

const _categories = [
  _ChecklistCategory(
    id: 'passwords',
    label: 'Mots de passe',
    icon: Icons.key_rounded,
    color: AppColors.passwords,
    items: [
      _ChecklistItem(id: 'pwd_unique', label: 'Utiliser un mot de passe unique par compte'),
      _ChecklistItem(id: 'pwd_manager', label: 'Installer un gestionnaire de mots de passe'),
      _ChecklistItem(id: 'pwd_length', label: 'Tous mes mots de passe font 12+ caractères'),
      _ChecklistItem(id: 'pwd_change', label: 'Changer les mots de passe compromis'),
    ],
  ),
  _ChecklistCategory(
    id: 'authentication',
    label: 'Authentification',
    icon: Icons.shield_rounded,
    color: AppColors.authentication,
    items: [
      _ChecklistItem(id: 'auth_2fa_email', label: 'Activer la 2FA sur mon email principal'),
      _ChecklistItem(id: 'auth_2fa_bank', label: 'Activer la 2FA sur mes comptes bancaires'),
      _ChecklistItem(id: 'auth_2fa_social', label: 'Activer la 2FA sur les réseaux sociaux'),
      _ChecklistItem(id: 'auth_recovery', label: 'Sauvegarder mes codes de récupération'),
    ],
  ),
  _ChecklistCategory(
    id: 'devices',
    label: 'Appareils',
    icon: Icons.laptop_rounded,
    color: AppColors.devices,
    items: [
      _ChecklistItem(id: 'dev_update', label: 'Mettre à jour mon OS et mes applications'),
      _ChecklistItem(id: 'dev_lock', label: 'Configurer le verrouillage automatique'),
      _ChecklistItem(id: 'dev_antivirus', label: 'Installer ou vérifier l\'antivirus'),
      _ChecklistItem(id: 'dev_backup', label: 'Configurer les sauvegardes automatiques'),
      _ChecklistItem(id: 'dev_encrypt', label: 'Activer le chiffrement du disque'),
    ],
  ),
  _ChecklistCategory(
    id: 'privacy',
    label: 'Confidentialité',
    icon: Icons.visibility_off_rounded,
    color: AppColors.privacy,
    items: [
      _ChecklistItem(id: 'priv_social', label: 'Vérifier la confidentialité des réseaux sociaux'),
      _ChecklistItem(id: 'priv_google', label: 'Faire un Privacy Checkup Google'),
      _ChecklistItem(id: 'priv_permissions', label: 'Vérifier les permissions des applications'),
      _ChecklistItem(id: 'priv_cookies', label: 'Nettoyer les cookies et trackers'),
    ],
  ),
  _ChecklistCategory(
    id: 'network',
    label: 'Réseau',
    icon: Icons.wifi_lock_rounded,
    color: AppColors.emails,
    items: [
      _ChecklistItem(id: 'net_wifi', label: 'Sécuriser mon réseau Wi-Fi (WPA3/WPA2)'),
      _ChecklistItem(id: 'net_vpn', label: 'Utiliser un VPN sur les réseaux publics'),
      _ChecklistItem(id: 'net_dns', label: 'Configurer un DNS sécurisé'),
    ],
  ),
];

final _totalItems = _categories.fold<int>(0, (sum, c) => sum + c.items.length);

class SecurityChecklistScreen extends ConsumerStatefulWidget {
  const SecurityChecklistScreen({super.key});

  @override
  ConsumerState<SecurityChecklistScreen> createState() => _SecurityChecklistScreenState();
}

class _SecurityChecklistScreenState extends ConsumerState<SecurityChecklistScreen>
    with TickerProviderStateMixin {
  final Set<String> _completed = {};
  final Set<String> _expandedCategories = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    for (final cat in _categories) {
      _expandedCategories.add(cat.id);
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    if (mounted) {
      setState(() {
        _completed.addAll(saved);
        _loaded = true;
      });
    }
  }

  Future<void> _toggle(String id) async {
    setState(() {
      if (_completed.contains(id)) {
        _completed.remove(id);
      } else {
        _completed.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _completed.toList());
  }

  double get _progress => _totalItems > 0 ? _completed.length / _totalItems : 0;

  String get _motivationalText {
    final pct = (_progress * 100).round();
    if (pct == 0) return 'C\'est le moment de sécuriser votre vie numérique !';
    if (pct < 25) return 'Bon début ! Continuez sur cette lancée.';
    if (pct < 50) return 'Vous progressez bien, gardez le rythme !';
    if (pct < 75) return 'Impressionnant ! Plus que quelques étapes.';
    if (pct < 100) return 'Presque terminé, vous y êtes presque !';
    return 'Félicitations ! Votre hygiène numérique est exemplaire.';
  }

  int _categoryCompleted(_ChecklistCategory cat) =>
      cat.items.where((item) => _completed.contains(item.id)).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                          Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('Checklist sécurité', style: theme.textTheme.displaySmall),
                  ],
                ),
              ),
            ),

            // Progress circle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Center(
                  child: _ProgressRing(
                    progress: _progress,
                    completed: _completed.length,
                    total: _totalItems,
                  ),
                ),
              ),
            ),

            // Motivational text
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Text(
                  _motivationalText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            // Categories
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
                  final done = _categoryCompleted(cat);
                  final isExpanded = _expandedCategories.contains(cat.id);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Category header
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCategories.remove(cat.id);
                                } else {
                                  _expandedCategories.add(cat.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: cat.color.withOpacity(0.05),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: cat.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(cat.icon, color: cat.color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat.label,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: done == cat.items.length
                                          ? AppColors.secondary.withOpacity(0.12)
                                          : cat.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$done/${cat.items.length}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: done == cat.items.length
                                            ? AppColors.secondary
                                            : cat.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Items
                          AnimatedCrossFade(
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Column(
                              children: cat.items.map((item) {
                                final checked = _completed.contains(item.id);
                                return _ChecklistTile(
                                  item: item,
                                  checked: checked,
                                  color: cat.color,
                                  onToggle: () => _toggle(item.id),
                                );
                              }).toList(),
                            ),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final _ChecklistItem item;
  final bool checked;
  final Color color;
  final VoidCallback onToggle;

  const _ChecklistTile({
    required this.item,
    required this.checked,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: checked ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: checked ? color : theme.colorScheme.onSurface.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked
                      ? theme.colorScheme.onSurface.withOpacity(0.4)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const _ProgressRing({
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (progress * 100).round();

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                trackColor: theme.colorScheme.onSurface.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$completed / $total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;

  _RingPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [AppColors.primary, AppColors.secondary],
      );

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect);

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}
