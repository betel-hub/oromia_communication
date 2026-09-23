import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../models/news_category.dart';
import '../../providers/news_provider.dart';
import '../../widgets/news_card.dart';
import '../../widgets/sort_dropdown.dart';

class CategoryNewsScreen extends ConsumerStatefulWidget {
  final NewsCategory category;

  const CategoryNewsScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryNewsScreen> createState() =>
      _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends ConsumerState<CategoryNewsScreen> {
  String _sortBy = 'most_recent';

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(categoryNewsProvider(widget.category.slug));

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.displayName)),
      body: Column(
        children: [
          SortDropdown(
            initialValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: newsAsync.when(
              data: (newsList) {
                if (newsList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.newspaper,
                            size: 64, color: AppColors.mediumGray),
                        SizedBox(height: 16),
                        Text('No news found',
                            style: TextStyle(color: AppColors.darkGray)),
                      ],
                    ),
                  );
                }

                final sorted = _sortNews(newsList);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final news = sorted[index];
                    return NewsCard(
                      news: news,
                      isHorizontal: false,
                      onTap: () {
                        context.push(
                          '/news/${widget.category.slug}/${news.id}',
                          extra: news,
                        );
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  List<News> _sortNews(List<News> newsList) {
    final sorted = List<News>.from(newsList);
    if (_sortBy == 'most_read') {
      sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    } else {
      sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }
    return sorted;
  }
}