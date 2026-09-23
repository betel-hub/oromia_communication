import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/news_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(allNewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
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
              hintText: 'Search news...',
              hintStyle: TextStyle(color: AppColors.mediumGray, fontSize: 14),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
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
                setState(() => _query = '');
              }
            },
          ),
        ],
      ),
      body: _query.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: AppColors.mediumGray),
                  SizedBox(height: 16),
                  Text('Start typing to search...',
                      style: TextStyle(color: AppColors.mediumGray)),
                ],
              ),
            )
          : newsAsync.when(
              data: (newsList) {
                final matches = newsList
                    .where((n) =>
                        n.title.toLowerCase().contains(_query) ||
                        n.content.toLowerCase().contains(_query))
                    .toList();

                if (matches.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: AppColors.mediumGray),
                        SizedBox(height: 16),
                        Text('No results found',
                            style: TextStyle(color: AppColors.mediumGray)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final n = matches[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: n.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: n.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.image,
                                          color: AppColors.mediumGray),
                                ),
                              )
                            : const Icon(Icons.newspaper,
                                color: AppColors.primaryBlue),
                        title: Text(
                          n.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${n.viewCount} views',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => context.push(
                          '/news/all/${n.id}',
                          extra: n,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
    );
  }
}