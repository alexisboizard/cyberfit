class NewsItem {
  final String title;
  final String description;
  final String url;
  final String source;
  final DateTime publishedAt;

  const NewsItem({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
  });
}
