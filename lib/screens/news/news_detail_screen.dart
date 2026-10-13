import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../providers/news_provider.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  News? _fullNews;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFullArticle();
  }

  Future<void> _loadFullArticle() async {
    try {
      final repo = ref.read(newsRepositoryProvider);
      final full = await repo.getById(widget.news.id);
      if (mounted) {
        setState(() {
          _fullNews = full ?? widget.news;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fullNews = widget.news;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = _fullNews ?? widget.news;

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Detail'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO IMAGE
            SizedBox(
              height: 250,
              width: double.infinity,
              child: news.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: news.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.lightGray,
                        child: const Center(
                            child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.lightGray,
                        child: const Icon(Icons.image, size: 80),
                      ),
                    )
                  : Container(
                      color: AppColors.lightGray,
                      child: const Icon(Icons.image, size: 80),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (news.categoryName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        news.categoryName.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.mediumGray),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMMM d, yyyy')
                            .format(news.publishedAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: AppColors.mediumGray),
                      const SizedBox(width: 4),
                      Text(
                        '${news.viewCount} views',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Article body — parse simple HTML
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ..._buildArticleContent(news.content),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parses simple HTML and returns styled widgets
  List<Widget> _buildArticleContent(String rawContent) {
    if (rawContent.isEmpty) {
      return [
        const Text('No content available.',
            style: TextStyle(fontSize: 16)),
      ];
    }

    // Split into paragraphs by <br> or </p> or <p>
    final cleaned = rawContent
        // Replace paragraph breaks with double newlines
        .replaceAll(RegExp(r'</p>\s*<p>'), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        // Remove remaining tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Decode common entities
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    // Split into paragraphs
    final paragraphs = cleaned
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return paragraphs.map<Widget>((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          p,
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            color: AppColors.black,
          ),
        ),
      );
    }).toList();
  }
}