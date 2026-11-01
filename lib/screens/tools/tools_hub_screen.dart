import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class ToolsHubScreen extends ConsumerWidget {
  const ToolsHubScreen({super.key});

  static const _tools = [
    _ToolDef(
      icon: Icons.password_rounded,
      color: AppColors.passwords,
      title: 'Force du\nmot de passe',
      subtitle: 'Évaluez la solidité',
      route: '/tools/password',
    ),
    _ToolDef(
      icon: Icons.mark_email_read_rounded,
      color: AppColors.emails,
      title: 'Email\nExposure',
      subtitle: 'Fuites de données',
      route: '/tools/email',
    ),
    _ToolDef(
      icon: Icons.link_rounded,
      color: AppColors.authentication,
      title: 'Analyse\nd\'URL',
      subtitle: 'Liens suspects',
      route: '/tools/url',
    ),
    _ToolDef(
      icon: Icons.checklist_rounded,
      color: AppColors.secondary,
      title: 'Checklist\nsécurité',
      subtitle: 'Sécurisez vos comptes',
      route: '/tools/checklist',
    ),
    _ToolDef(
      icon: Icons.phishing_rounded,
      color: AppColors.streak,
      title: 'Simulateur\nphishing',
      subtitle: 'Testez vos réflexes',
      route: '/tools/phishing',
    ),
    _ToolDef(
      icon: Icons.qr_code_scanner_rounded,
      color: AppColors.devices,
      title: 'Scanner\nQR Code',
      subtitle: 'Bientôt disponible',
      route: null,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outils', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Votre boîte à outils cyber',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tool = _tools[index];
                    final comingSoon = tool.route == null;
                    return _ToolTile(tool: tool, comingSoon: comingSoon);
                  },
                  childCount: _tools.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolDef {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? route;

  const _ToolDef({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _ToolTile extends StatelessWidget {
  final _ToolDef tool;
  final bool comingSoon;

  const _ToolTile({required this.tool, required this.comingSoon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: comingSoon ? null : () => context.push(tool.route!),
      child: Opacity(
        opacity: comingSoon ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tool.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tool.color.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tool.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tool.icon, color: tool.color, size: 24),
                  ),
                  if (comingSoon) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tool.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bientôt',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tool.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                tool.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool.subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
