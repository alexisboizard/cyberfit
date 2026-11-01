import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../main.dart';
import '../../providers/guide_provider.dart';
import '../../providers/purchase_provider.dart';

final _favoritesRefreshProvider = StateProvider<int>((ref) => 0);

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedCategory;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Guides', style: theme.textTheme.displaySmall),
            ),
            const SizedBox(height: 16),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Tous les guides'),
                    Tab(text: 'Favoris'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search bar (only in "all" tab)
            if (_tabController.index == 0) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un guide...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),

              // Category chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(
                      label: 'Tous',
                      selected: _selectedCategory == null,
                      onSelected: () => setState(() => _selectedCategory = null),
                    ),
                    ...AppConstants.categories.map(
                      (cat) => _FilterChip(
                        label: AppConstants.categoryLabels[cat] ?? cat,
                        selected: _selectedCategory == cat,
                        onSelected: () =>
                            setState(() => _selectedCategory = cat),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AllGuidesTab(
                    searchQuery: _searchQuery,
                    selectedCategory: _selectedCategory,
                  ),
                  const _FavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllGuidesTab extends ConsumerWidget {
  final String searchQuery;
  final String? selectedCategory;

  const _AllGuidesTab({
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = searchQuery.isNotEmpty
        ? ref.watch(guideSearchProvider(searchQuery))
        : ref.watch(guidesProvider);
    final theme = Theme.of(context);

    return guidesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (guides) {
        final filtered = selectedCategory != null
            ? guides.where((g) => g.category == selectedCategory).toList()
            : guides;

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                const Text('Aucun guide trouvé'),
              ],
            ),
          );
        }

        final isPremium = ref.watch(isPremiumProvider);
        final freeLimit = AppConstants.freeGuidesLimit;
        final storage = ref.read(storageServiceProvider);
        ref.watch(_favoritesRefreshProvider);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final guide = filtered[index];
            final isLocked = !isPremium && index >= freeLimit;
            final isFav = storage.isGuideFavorite(guide.id);

            return _GuideCard(
              title: guide.title,
              duration: guide.duration,
              platforms: guide.platforms,
              isLocked: isLocked,
              isFavorite: isFav,
              onTap: () {
                if (isLocked) {
                  context.push('/premium');
                } else {
                  context.push('/guide/${guide.id}');
                }
              },
              onToggleFavorite: isLocked
                  ? null
                  : () async {
                      await storage.toggleGuideFavorite(guide.id);
                      ref.read(_favoritesRefreshProvider.notifier).state++;
                    },
            );
          },
        );
      },
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(guidesProvider);
    final storage = ref.read(storageServiceProvider);
    ref.watch(_favoritesRefreshProvider);
    final theme = Theme.of(context);
    final favoriteIds = storage.favoriteGuides;

    if (favoriteIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.15),
              ),
              const SizedBox(height: 16),
              Text(
                'Pas encore de favoris',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoutez des guides en favoris pour les retrouver facilement',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return guidesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (guides) {
        final favGuides =
            guides.where((g) => favoriteIds.contains(g.id)).toList();

        if (favGuides.isEmpty) {
          return const Center(child: Text('Aucun favori trouvé'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: favGuides.length,
          itemBuilder: (context, index) {
            final guide = favGuides[index];
            return _GuideCard(
              title: guide.title,
              duration: guide.duration,
              platforms: guide.platforms,
              isLocked: false,
              isFavorite: true,
              onTap: () => context.push('/guide/${guide.id}'),
              onToggleFavorite: () async {
                await storage.toggleGuideFavorite(guide.id);
                ref.read(_favoritesRefreshProvider.notifier).state++;
              },
            );
          },
        );
      },
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final int duration;
  final List<String> platforms;
  final bool isLocked;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const _GuideCard({
    required this.title,
    required this.duration,
    required this.platforms,
    required this.isLocked,
    required this.isFavorite,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isLocked
                            ? theme.colorScheme.onSurface.withOpacity(0.35)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          '$duration min',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        ...platforms.take(2).map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock_rounded, color: AppColors.gold, size: 20)
              else ...[
                if (onToggleFavorite != null)
                  GestureDetector(
                    onTap: onToggleFavorite,
                    child: Icon(
                      isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: isFavorite
                          ? AppColors.accent
                          : theme.colorScheme.onSurface.withOpacity(0.25),
                      size: 22,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
