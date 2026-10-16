import 'package:flutter/material.dart';


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
        return 'monthly';
      case PublicationType.yearlyBook:
        return 'yearly';
      case PublicationType.brochure:
        return 'brochure';
      case PublicationType.archive:
        return 'archive';
      case PublicationType.filesAndBooks:
        return 'file';
    }
  }

  IconData get icon {
    switch (this) {
      case PublicationType.weekly:
        return Icons.newspaper;
      case PublicationType.quarterly:
        return Icons.calendar_month;
      case PublicationType.yearlyBook:
        return Icons.book;
      case PublicationType.brochure:
        return Icons.broken_image;
      case PublicationType.archive:
        return Icons.archive;
      case PublicationType.filesAndBooks:
        return Icons.folder;
    }
  }

  static PublicationType fromSlug(String slug) {
    return PublicationType.values.firstWhere(
      (t) => t.slug == slug,
      orElse: () => PublicationType.weekly,
    );
  }
}