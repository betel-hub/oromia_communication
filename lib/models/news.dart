class News {
  final String id;         // UUID from API (string, not int)
  final String title;
  final String content;
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
    this.excerpt,
    required this.imageUrl,
    required this.categoryName,
    required this.categorySlug,
    required this.publishedAt,
    required this.viewCount,
    this.isFeatured = false,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: (json['news_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      content: (json['summary'] ?? json['content'] ?? json['body'] ?? '')
          .toString(),
      excerpt: json['summary']?.toString(),
      imageUrl: (json['thumbnail'] ?? json['image_url'] ?? '').toString(),
      categoryName:
          (json['category_name'] ?? json['category'] ?? '').toString(),
      categorySlug:
          (json['category_slug'] ?? json['category'] ?? '').toString(),
      publishedAt: _toDate(
        json['news_created_date'] ?? json['published_at'],
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