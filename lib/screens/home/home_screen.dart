import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../providers/auth_provider.dart';
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
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              final isAuth = ref.read(authStateProvider).isAuthenticated;
              context.push(isAuth ? '/profile' : '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: newsAsync.when(
        data: (newsList) {
          if (newsList.isEmpty) {
            return const Center(child: Text('No news available'));
          }

          final featured = newsList.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allNewsProvider);
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Carousel
                  _buildHeroCarousel(context, featured),

                  const SizedBox(height: 16),

                  // Latest News header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Latest News',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/news/all'),
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

                  // All news
                  ...newsList.map((news) => NewsCard(
                        news: news,
                        isHorizontal: false,
                        onTap: () => context.push(
                          '/news/all/${news.id}',
                          extra: news,
                        ),
                      )),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Could not load news'),
                const SizedBox(height: 8),
                Text('$err',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allNewsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCarousel(BuildContext context, List<News> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final news = featured[index];
          return GestureDetector(
            onTap: () {
              context.push('/news/all/${news.id}', extra: news);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                            child: const Text(
                              'Recent News',
                              style: TextStyle(
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
                                '${news.publishedAt.day}/${news.publishedAt.month}/${news.publishedAt.year}',
                                style: const TextStyle(
                                    color: AppColors.white70, fontSize: 11),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.remove_red_eye_outlined,
                                  size: 12, color: AppColors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${news.viewCount}',
                                style: const TextStyle(
                                    color: AppColors.white70, fontSize: 11),
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
}