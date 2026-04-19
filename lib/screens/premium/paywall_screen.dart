import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../services/purchase_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _purchasing = false;
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(0.2),
                  AppColors.accent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, size: 64, color: AppColors.gold),
                const SizedBox(height: 16),
                Text(
                  'CyberFit Premium',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Devenez un expert en cybersécurité',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Features
          _FeatureRow(
            icon: Icons.all_inclusive,
            title: 'Défis illimités',
            subtitle: 'Complétez autant de défis que vous voulez, chaque semaine',
          ),
          _FeatureRow(
            icon: Icons.emoji_events,
            title: 'Tous les badges',
            subtitle: 'Débloquez l\'intégralité de la collection',
          ),
          _FeatureRow(
            icon: Icons.menu_book,
            title: 'Tous les guides',
            subtitle: 'Accédez à tous les tutoriels détaillés',
          ),
          _FeatureRow(
            icon: Icons.local_fire_department,
            title: 'Protection de streak',
            subtitle: 'Manquez un jour sans perdre votre série',
          ),
          const SizedBox(height: 32),

          // Pricing
          offeringsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _FallbackPricing(
              onPurchase: null,
              purchasing: _purchasing,
            ),
            data: (offerings) {
              final packages = offerings?.current?.availablePackages ?? [];

              if (packages.isEmpty) {
                return _FallbackPricing(
                  onPurchase: null,
                  purchasing: _purchasing,
                );
              }

              return Column(
                children: packages.map((pkg) {
                  final isAnnual = pkg.packageType == PackageType.annual;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PricingCard(
                      title: isAnnual ? 'Annuel' : 'Mensuel',
                      price: pkg.storeProduct.priceString,
                      subtitle: isAnnual ? 'Économisez ~45%' : 'Facturé chaque mois',
                      highlighted: isAnnual,
                      onTap: _purchasing
                          ? null
                          : () => _purchase(pkg),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Restore
          Center(
            child: TextButton(
              onPressed: _restoring ? null : _restore,
              child: _restoring
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Restaurer mes achats'),
            ),
          ),
          const SizedBox(height: 8),

          // Legal
          Text(
            'L\'abonnement se renouvelle automatiquement. '
            'Vous pouvez annuler à tout moment dans les paramètres de votre compte Apple/Google.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _purchase(dynamic package) async {
    setState(() => _purchasing = true);
    try {
      final success = await PurchaseService.purchasePackage(package);
      if (success && mounted) {
        final uid = ref.read(authStateProvider).value?.uid;
        if (uid != null) {
          await ref
              .read(firestoreServiceProvider)
              .updateUser(uid, {'isPremium': true});
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bienvenue dans CyberFit Premium !')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      final success = await PurchaseService.restorePurchases();
      if (mounted) {
        if (success) {
          final uid = ref.read(authStateProvider).value?.uid;
          if (uid != null) {
            await ref
                .read(firestoreServiceProvider)
                .updateUser(uid, {'isPremium': true});
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Achats restaurés avec succès !')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun achat trouvé')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool highlighted;
  final VoidCallback? onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.highlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: highlighted ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlighted
            ? const BorderSide(color: AppColors.gold, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (highlighted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Populaire',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: highlighted ? AppColors.gold : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackPricing extends StatelessWidget {
  final VoidCallback? onPurchase;
  final bool purchasing;

  const _FallbackPricing({this.onPurchase, required this.purchasing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PricingCard(
          title: 'Mensuel',
          price: '2,99 €',
          subtitle: 'Facturé chaque mois',
          highlighted: false,
          onTap: onPurchase,
        ),
        const SizedBox(height: 12),
        _PricingCard(
          title: 'Annuel',
          price: '19,99 €',
          subtitle: 'Économisez ~45%',
          highlighted: true,
          onTap: onPurchase,
        ),
      ],
    );
  }
}
