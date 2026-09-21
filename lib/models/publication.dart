enum PublicationType {
  weekly,
  quarterly,
  yearlyBook,
  brochure,
  archive,
  filesAndBooks,
}

extension PublicationTypeExtension on PublicationType {
  String get displayName {
    switch (this) {
      case PublicationType.weekly:
        return 'Weekly Newspaper';
      case PublicationType.quarterly:
        return 'Quarterly Newspaper';
      case PublicationType.yearlyBook:
        return 'Yearly Book';
      case PublicationType.brochure:
        return 'Brochure';
      case PublicationType.archive:
        return 'Archive';
      case PublicationType.filesAndBooks:
        return 'Files & Books';
    }
  }

  String get slug {
    switch (this) {
      case PublicationType.weekly:
        return 'weekly';
      case PublicationType.quarterly:
        return 'quarterly';
      case PublicationType.yearlyBook:
        return 'yearly';
      case PublicationType.brochure:
        return 'brochure';
      case PublicationType.archive:
        return 'archive';
      case PublicationType.filesAndBooks:
        return 'files';
    }
  }

  static PublicationType fromSlug(String slug) {
    return PublicationType.values.firstWhere(
      (p) => p.slug == slug,
      orElse: () => PublicationType.weekly,
    );
  }
}

class Publication {
  final int id;
  final String title;
  final String? subtitle;
  final String coverUrl;
  final String type;
  final DateTime publishedAt;
  final int pageCount;
  final int? issueNumber;

  Publication({
    required this.id,
    required this.title,
    this.subtitle,
    required this.coverUrl,
    required this.type,
    required this.publishedAt,
    this.pageCount = 20,
    this.issueNumber,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      coverUrl: json['cover_url'] ?? '',
      type: json['type'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      pageCount: json['page_count'] ?? 20,
      issueNumber: json['issue_number'],
    );
  }
}