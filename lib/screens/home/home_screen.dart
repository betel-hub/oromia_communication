import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../providers/news_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/news_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(allNewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oromia Communication Bureau'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          IconButton(
  icon: const Icon(Icons.search),
  onPressed: () => context.push('/search'),
),
        ],
      ),
      drawer: const AppDrawer(),
      body: newsAsync.when(
        data: (newsList) => _buildContent(context, newsList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  // ================================================================
  // CONTENT
  // ================================================================
  Widget _buildContent(BuildContext context, List<News> newsList) {
    final featured = newsList.where((n) => n.isFeatured).toList();
    final politics = newsList.where((n) => n.categorySlug == 'politics').toList();
    final features = newsList.where((n) => n.categorySlug == 'features').toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Carousel
          if (featured.isNotEmpty) _buildHeroCarousel(context, featured),

          const SizedBox(height: 16),

          // Politics News Section
          _buildSection(
            context,
            title: 'Politics News',
            categorySlug: 'politics',
            newsList: politics.isNotEmpty ? politics : newsList.take(5).toList(),
          ),

          const SizedBox(height: 8),

          // Feature News Section
          _buildSection(
            context,
            title: 'Feature News',
            categorySlug: 'features',
            newsList: features.isNotEmpty
                ? features
                : newsList.skip(5).take(5).toList(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================================================================
  // HERO CAROUSEL (with GestureDetector navigation)
  // ================================================================
  Widget _buildHeroCarousel(BuildContext context, List<News> featured) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final news = featured[index];
          return GestureDetector(
            onTap: () {
              context.push('/news/${news.categorySlug}/${news.id}');
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    CachedNetworkImage(
                      imageUrl: news.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.lightGray,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.lightGray,
                        child: const Icon(Icons.image, size: 60),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Mata Duree • ${news.categoryName}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 12, color: AppColors.white70),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(news.publishedAt),
                                style: const TextStyle(
                                  color: AppColors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.remove_red_eye_outlined,
                                  size: 12, color: AppColors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${news.viewCount}',
                                style: const TextStyle(
                                  color: AppColors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // SECTION WITH "VIEW MORE" BUTTON (news cards navigate to detail)
  // ================================================================
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String categorySlug,
    required List<News> newsList,
  }) {
    if (newsList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/news/$categorySlug');
                },
                child: const Text(
                  'View More →',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal list
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return NewsCard(
                news: news,
                isHorizontal: true,
                onTap: () {
                  context.push('/news/${news.categorySlug}/${news.id}');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================
  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}