class News {
  final int id;
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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      imageUrl: json['image_url'] ?? '',
      categoryName: json['category_name'] ?? '',
      categorySlug: json['category_slug'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      viewCount: json['view_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
    );
  }
}