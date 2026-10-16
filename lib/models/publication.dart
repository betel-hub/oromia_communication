class Publication {
  final String id;
  final String title;
  final String? subtitle;
  final String coverUrl;
  final String type;
  final DateTime? publishedAt;
  final int pageCount;
  final int? issueNumber;

  Publication({
    required this.id,
    required this.title,
    this.subtitle,
    required this.coverUrl,
    required this.type,
    this.publishedAt,
    this.pageCount = 0,
    this.issueNumber,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: (json['id'] ?? json['book_id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString(),
      coverUrl: (json['cover_url'] ?? json['thumbnail'] ?? json['cover'] ?? '')
          .toString(),
      type: json['type']?.toString() ?? 'weekly',
      publishedAt: _toDate(
          json['published_at'] ?? json['created_at'] ?? json['date']),
      pageCount: _toInt(json['page_count'] ?? json['pages']),
      issueNumber: json['issue_number'] != null
          ? _toInt(json['issue_number'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'cover_url': coverUrl,
        'type': type,
        'published_at': publishedAt?.toIso8601String(),
        'page_count': pageCount,
        'issue_number': issueNumber,
      };
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}