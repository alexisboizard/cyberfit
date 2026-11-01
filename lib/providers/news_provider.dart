import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

final newsProvider = FutureProvider<List<NewsItem>>((ref) {
  return NewsService.fetchNews();
});
