import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guide_model.dart';
import 'auth_provider.dart';

final guidesProvider = FutureProvider<List<GuideModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getGuides();
});

final guidesByCategoryProvider =
    FutureProvider.family<List<GuideModel>, String>((ref, category) {
  return ref.watch(firestoreServiceProvider).getGuides(category: category);
});

final guideSearchProvider =
    FutureProvider.family<List<GuideModel>, String>((ref, query) async {
  final guides = await ref.watch(guidesProvider.future);
  final lowerQuery = query.toLowerCase();
  return guides.where((g) {
    return g.title.toLowerCase().contains(lowerQuery) ||
        g.tags.any((t) => t.toLowerCase().contains(lowerQuery)) ||
        g.category.toLowerCase().contains(lowerQuery);
  }).toList();
});
