import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/publication.dart';
import '../../models/publication_type.dart';
import '../../providers/publication_provider.dart';

class PublicationListScreen extends ConsumerStatefulWidget {
  final PublicationType type;

  const PublicationListScreen({super.key, required this.type});

  @override
  ConsumerState<PublicationListScreen> createState() =>
      _PublicationListScreenState();
}

class _PublicationListScreenState extends ConsumerState<PublicationListScreen> {
  String _archiveFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final pubAsync = ref.watch(publicationListProvider(widget.type.slug));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(publicationListProvider(widget.type.slug)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.type == PublicationType.archive) _buildArchiveFilters(),
          Expanded(
            child: pubAsync.when(
              data: (items) {
                final filtered = widget.type == PublicationType.archive
                    ? (_archiveFilter == 'all'
                        ? items
                        : items.where((p) => p.type == _archiveFilter).toList())
                    : items;

                if (filtered.isEmpty) return _buildEmptyState();
                return _buildGrid(filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .invalidate(publicationListProvider(widget.type.slug)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveFilters() {
    const filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'weekly', 'label': 'Weekly'},
      {'value': 'monthly', 'label': 'Quarterly'},
      {'value': 'yearly', 'label': 'Yearly'},
      {'value': 'brochure', 'label': 'Brochure'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: filters.map((f) {
          final selected = _archiveFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f['label']!),
              selected: selected,
              onSelected: (_) => setState(() => _archiveFilter = f['value']!),
              backgroundColor: AppColors.lightGray,
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: selected ? AppColors.primaryBlue : AppColors.black,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid(List<Publication> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildCoverCard(items[i]),
    );
  }

  Widget _buildCoverCard(Publication pub) {
    return GestureDetector(
      onTap: () => context.push('/kallacha/reader/${pub.id}?type=${pub.type}'),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: pub.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGray,
                      child: const Center(
                          child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.lightGray,
                      child: const Icon(Icons.book,
                          size: 48, color: AppColors.mediumGray),
                    ),
                  ),
                  if (pub.issueNumber != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Issue ${pub.issueNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${pub.pageCount} pages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pub.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pub.subtitle != null && pub.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      pub.subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mediumGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 10, color: AppColors.primaryRed),
                      const SizedBox(width: 3),
                      if (pub.publishedAt != null)
                        Text(
                          DateFormat('MMM yyyy').format(pub.publishedAt!),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.mediumGray),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.type.icon,
              size: 64, color: AppColors.mediumGray),
          const SizedBox(height: 16),
          Text('No ${widget.type.displayName} available',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          const Text('Check back later',
              style: TextStyle(
                  color: AppColors.mediumGray, fontSize: 12)),
        ],
      ),
    );
  }
}