enum MediaType {
  pressRelease,
  documentary,
  video,
  imageGallery,
  audioFiles,
}

extension MediaTypeExtension on MediaType {
  String get displayName {
    switch (this) {
      case MediaType.pressRelease:
        return 'Press Release';
      case MediaType.documentary:
        return 'Documentary';
      case MediaType.video:
        return 'Video';
      case MediaType.imageGallery:
        return 'Image & Gallery';
      case MediaType.audioFiles:
        return 'Audio Files';
    }
  }

  String get slug {
    switch (this) {
      case MediaType.pressRelease:
        return 'press-release';
      case MediaType.documentary:
        return 'documentary';
      case MediaType.video:
        return 'video';
      case MediaType.imageGallery:
        return 'image-gallery';
      case MediaType.audioFiles:
        return 'audio-files';
    }
  }

  static MediaType fromSlug(String slug) {
    return MediaType.values.firstWhere(
      (m) => m.slug == slug,
      orElse: () => MediaType.pressRelease,
    );
  }
}

class MediaItem {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? mediaUrl;
  final String type;
  final DateTime publishedAt;
  final int duration; // seconds for audio/video
  final List<String>? imageUrls; // for gallery

  MediaItem({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.mediaUrl,
    required this.type,
    required this.publishedAt,
    this.duration = 0,
    this.imageUrls,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      mediaUrl: json['media_url'],
      type: json['type'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      duration: json['duration'] ?? 0,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
    );
  }
}