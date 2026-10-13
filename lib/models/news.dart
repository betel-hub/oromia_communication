class News {
  final String id;
  final String title;
  final String content;    // Raw HTML — will be rendered in detail screen
  final String summary;    // Plain text for list previews
  final String? excerpt;
  final String imageUrl;
  final String categoryName;
  final String categorySlug;
  final DateTime publishedAt;
  final int viewCount;
  final bool isFeatured;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    this.excerpt,
    required this.imageUrl,
    required this.categoryName,
    required this.categorySlug,
    required this.publishedAt,
    required this.viewCount,
    this.isFeatured = false,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    final rawBody =
        (json['body'] ?? json['summary'] ?? json['content'] ?? '').toString();
    final rawSummary = (json['summary'] ?? rawBody).toString();

    return News(
      id: (json['news_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      content: rawBody,                    // HTML preserved for detail
      summary: _stripHtml(rawSummary),     // Plain text for cards
      excerpt: rawSummary,
      imageUrl: (json['thumbnail'] ?? json['image_url'] ?? '').toString(),
      categoryName:
          (json['category_name'] ?? json['category'] ?? '').toString(),
      categorySlug:
          (json['category_slug'] ?? json['category'] ?? '').toString(),
      publishedAt: _toDate(
        json['created_at'] ?? json['news_created_date'] ?? json['published_at'],
      ),
      viewCount: _toInt(json['view_count'] ?? json['views']),
      isFeatured: json['is_featured'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'news_id': id,
        'title': title,
        'summary': content,
        'thumbnail': imageUrl,
        'category_name': categoryName,
        'category_slug': categorySlug,
        'news_created_date': publishedAt.toIso8601String(),
        'view_count': viewCount,
        'is_featured': isFeatured,
      };
}

// ============ HELPERS ============
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

/// Strips HTML tags and returns plain text.
String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .trim();
}