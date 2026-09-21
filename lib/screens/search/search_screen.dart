import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/media_provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/publication_provider.dart';

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
    final mediaAsync = ref.watch(mediaListProvider('video'));
    final pubsAsync = ref.watch(publicationListProvider('weekly'));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            hintText: 'Search news, media, publications...',
            hintStyle: TextStyle(color: AppColors.white70),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v.toLowerCase()),
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
              child: Text('Start typing to search...',
                  style: TextStyle(color: AppColors.mediumGray)),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // News Results
                newsAsync.when(
                  data: (news) {
                    final matches = news
                        .where((n) =>
                            n.title.toLowerCase().contains(_query))
                        .take(5)
                        .toList();
                    if (matches.isEmpty) return const SizedBox.shrink();
                    return _buildSection(
                      title: 'News (${matches.length})',
                      children: matches
                          .map((n) => ListTile(
                                leading: const Icon(Icons.newspaper,
                                    color: AppColors.primaryBlue),
                                title: Text(n.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                onTap: () => context.push(
                                    '/news/${n.categorySlug}/${n.id}'),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (context, error) => const SizedBox.shrink(),
                ),

                // Media Results
                mediaAsync.when(
                  data: (media) {
                    final matches = media
                        .where((m) =>
                            m.title.toLowerCase().contains(_query))
                        .take(5)
                        .toList();
                    if (matches.isEmpty) return const SizedBox.shrink();
                    return _buildSection(
                      title: 'Media (${matches.length})',
                      children: matches
                          .map((m) => ListTile(
                                leading: m.thumbnailUrl != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: m.thumbnailUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.video_library,
                                        color: AppColors.primaryBlue),
                                title: Text(m.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                onTap: () {},
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (context, error) => const SizedBox.shrink(),
                ),

                // Publications Results
                pubsAsync.when(
                  data: (pubs) {
                    final matches = pubs
                        .where((p) =>
                            p.title.toLowerCase().contains(_query))
                        .take(5)
                        .toList();
                    if (matches.isEmpty) return const SizedBox.shrink();
                    return _buildSection(
                      title: 'Kallacha Oromia (${matches.length})',
                      children: matches
                          .map((p) => ListTile(
                                leading: p.coverUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: p.coverUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.book,
                                        color: AppColors.primaryBlue),
                                title: Text(p.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                onTap: () {},
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (context, error) => const SizedBox.shrink(),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
