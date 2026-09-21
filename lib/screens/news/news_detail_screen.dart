import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../providers/news_provider.dart';
import '../../widgets/news_card.dart';

class NewsDetailScreen extends ConsumerWidget {
  final int newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsDetailProvider(newsId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Bookmark functionality
            },
          ),
        ],
      ),
      body: newsAsync.when(
        data: (news) {
          if (news == null) {
            return const Center(child: Text('News not found'));
          }
          return _buildContent(context, ref, news);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, News news) {
    final relatedAsync = ref.watch(
      relatedNewsProvider({'id': news.id, 'categorySlug': news.categorySlug}),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============ HERO IMAGE ============
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: news.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.lightGray,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.lightGray,
                child: const Icon(Icons.image, size: 80),
              ),
            ),
          ),

          // ============ CONTENT ============
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
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

                // Meta (date + views)
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.mediumGray),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(news.publishedAt),
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

                // Excerpt (bold lead)
                if (news.excerpt != null && news.excerpt!.isNotEmpty) ...[
                  Text(
                    news.excerpt!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content (full article)
                Text(
                  news.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 32),

                // ============ RELATED NEWS ============
                const Text(
                  'Related News',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Related news list
          relatedAsync.when(
            data: (relatedList) {
              if (relatedList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No related news'),
                );
              }
              return Column(
                children: relatedList.map((relatedNews) {
                  return NewsCard(
                    news: relatedNews,
                    isHorizontal: false,
                    onTap: () {
                      context.push('/news/${relatedNews.categorySlug}/${relatedNews.id}');
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}