import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../providers/news_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    final repo = ref.read(newsRepositoryProvider);
    final results = await repo.search(q.trim());

    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
        _hasSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.black, fontSize: 15),
            cursorColor: AppColors.primaryBlue,
            decoration: const InputDecoration(
              hintText: 'Search news, sectors, services...',
              hintStyle:
                  TextStyle(color: AppColors.mediumGray, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
            ),
            onChanged: (v) {
              setState(() => _query = v);
            },
            onSubmitted: _search,
            textInputAction: TextInputAction.search,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_query.isEmpty) {
                context.pop();
              } else {
                _ctrl.clear();
                setState(() {
                  _query = '';
                  _results = [];
                  _hasSearched = false;
                });
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Empty state
    if (_query.trim().length < 2) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.mediumGray),
            SizedBox(height: 16),
            Text(
              'Search Oromia Communication Bureau',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            SizedBox(height: 8),
            Text(
              'News, sectors, services, publications...',
              style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
          ],
        ),
      );
    }

    // Loading
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // No results
    if (_hasSearched && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.mediumGray),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different keyword',
              style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
          ],
        ),
      );
    }

    // Results
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      itemBuilder: (context, i) => _buildResultCard(_results[i]),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? 'news';
    final typeLabel = item['type_label']?.toString() ?? type;
    final title = (item['title'] ?? item['label'] ?? '').toString();
    final thumbnail = item['thumbnail']?.toString();
    final date = item['date']?.toString();
    final url = item['url']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle tap based on type
          if (type == 'news' && url.contains('/detail/')) {
            final uuid = url.split('/detail/').last;
            // Create a minimal News to pass to detail
            final news = News(
              id: uuid,
              title: title,
              content: '',
              summary: '',
              imageUrl: thumbnail ?? '',
              categoryName: '',
              categorySlug: 'all',
              publishedAt: DateTime.now(),
              viewCount: 0,
            );
            context.push('/news/all/$uuid', extra: news);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (thumbnail != null && thumbnail.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: thumbnail,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.lightGray,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.lightGray,
                      child: const Icon(Icons.image,
                          color: AppColors.mediumGray),
                    ),
                  ),
                )
              else
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconForType(type),
                      color: AppColors.primaryBlue),
                ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (date != null && date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 11, color: AppColors.mediumGray),
                          const SizedBox(width: 3),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'news':
        return Icons.newspaper;
      case 'press':
        return Icons.description;
      case 'sector':
        return Icons.business;
      case 'shop':
      case 'book':
        return Icons.shopping_bag;
      case 'tender':
        return Icons.gavel;
      case 'project':
        return Icons.construction;
      case 'service':
        return Icons.payment;
      case 'page':
        return Icons.article;
      default:
        return Icons.search;
    }
  }
}