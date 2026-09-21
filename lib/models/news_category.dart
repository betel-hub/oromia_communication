enum NewsCategory {
  all,
  politics,
  social,
  economy,
  sport,
  technology,
  environment,
  features,
}

extension NewsCategoryExtension on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.all:
        return 'All News';
      case NewsCategory.politics:
        return 'Politics News';
      case NewsCategory.social:
        return 'Social News';
      case NewsCategory.economy:
        return 'Economy News';
      case NewsCategory.sport:
        return 'Sport News';
      case NewsCategory.technology:
        return 'Technology News';
      case NewsCategory.environment:
        return 'Environment News';
      case NewsCategory.features:
        return 'Feature News';
    }
  }

  String get slug {
    switch (this) {
      case NewsCategory.all:
        return 'all';
      case NewsCategory.politics:
        return 'politics';
      case NewsCategory.social:
        return 'social';
      case NewsCategory.economy:
        return 'economy';
      case NewsCategory.sport:
        return 'sport';
      case NewsCategory.technology:
        return 'technology';
      case NewsCategory.environment:
        return 'environment';
      case NewsCategory.features:
        return 'features';
    }
  }

  static NewsCategory fromSlug(String slug) {
    return NewsCategory.values.firstWhere(
      (c) => c.slug == slug,
      orElse: () => NewsCategory.all,
    );
  }
}