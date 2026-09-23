import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
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
            // ============ HERO IMAGE ============
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

            // ============ CONTENT ============
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (news.categoryName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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

                  // Meta row
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

                  // Article body
                  Text(
                    news.content.isNotEmpty
                        ? news.content
                        : 'No content available.',
                    style: const TextStyle(fontSize: 16, height: 1.7),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}