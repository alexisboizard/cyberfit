import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/news_model.dart';

class NewsService {
  static const _feeds = [
    _Feed('https://www.cert.ssi.gouv.fr/feed/', 'CERT-FR'),
    _Feed('https://www.cybermalveillance.gouv.fr/tous-nos-contenus/feed', 'Cybermalveillance'),
  ];

  static Future<List<NewsItem>> fetchNews() async {
    final allItems = <NewsItem>[];

    for (final feed in _feeds) {
      try {
        final response = await http
            .get(Uri.parse(feed.url))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          allItems.addAll(_parseRss(response.body, feed.source));
        }
      } catch (_) {
        // Skip unavailable feeds
      }
    }

    allItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allItems.take(30).toList();
  }

  static List<NewsItem> _parseRss(String xmlString, String source) {
    final items = <NewsItem>[];
    try {
      final document = XmlDocument.parse(xmlString);
      final itemElements = document.findAllElements('item');

      for (final item in itemElements) {
        final title = item.getElement('title')?.innerText ?? '';
        final description = _cleanHtml(
          item.getElement('description')?.innerText ?? '',
        );
        final link = item.getElement('link')?.innerText ?? '';
        final pubDate = item.getElement('pubDate')?.innerText;

        DateTime published;
        try {
          published = pubDate != null
              ? _parseRssDate(pubDate)
              : DateTime.now();
        } catch (_) {
          published = DateTime.now();
        }

        if (title.isNotEmpty && link.isNotEmpty) {
          items.add(NewsItem(
            title: title,
            description: description.length > 200
                ? '${description.substring(0, 200)}...'
                : description,
            url: link,
            source: source,
            publishedAt: published,
          ));
        }
      }
    } catch (_) {}
    return items;
  }

  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static DateTime _parseRssDate(String date) {
    // RFC 822 format: "Mon, 01 Jan 2024 12:00:00 +0000"
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };

    final parts = date.trim().split(RegExp(r'[\s,]+'));
    if (parts.length >= 5) {
      final day = int.tryParse(parts[1]) ?? 1;
      final month = months[parts[2]] ?? 1;
      final year = int.tryParse(parts[3]) ?? 2024;
      final timeParts = parts[4].split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
      return DateTime(year, month, day, hour, minute);
    }

    return DateTime.tryParse(date) ?? DateTime.now();
  }
}

class _Feed {
  final String url;
  final String source;
  const _Feed(this.url, this.source);
}
