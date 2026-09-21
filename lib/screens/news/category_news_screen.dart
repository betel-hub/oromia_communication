import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ConsumerState<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends ConsumerState<CategoryNewsScreen> {
  String _sortBy = 'most_recent';

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(categoryNewsProvider(widget.category.slug));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.displayName),
      ),
      body: Column(
        children: [
          // Sort dropdown
          SortDropdown(
            initialValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value);
            },
          ),
          const Divider(height: 1),
          // News list
          Expanded(
            child: newsAsync.when(
              data: (newsList) {
                final sorted = _sortNews(newsList);
                if (sorted.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(categoryNewsProvider(widget.category.slug));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      return NewsCard(
                        news: sorted[index],
                        isHorizontal: false,
                       onTap: () {
  context.push('/news/${widget.category.slug}/${sorted[index].id}');
},
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, size: 64, color: AppColors.mediumGray),
          SizedBox(height: 16),
          Text(
            'No news found',
            style: TextStyle(fontSize: 16, color: AppColors.darkGray),
          ),
        ],
      ),
    );
  }
}