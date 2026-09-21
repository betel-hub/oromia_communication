import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/publication.dart';
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
      appBar: AppBar(title: Text(widget.type.displayName)),
      body: Column(
        children: [
          // Archive filter chips
          if (widget.type == PublicationType.archive) _buildArchiveFilters(),
          Expanded(
            child: pubAsync.when(
              data: (items) {
                final filtered = widget.type == PublicationType.archive
                    ? (_archiveFilter == 'all'
                        ? items
                        : items.where((p) => p.type == _archiveFilter).toList())
                    : items;

                if (filtered.isEmpty) {
                  return const Center(child: Text('No publications available'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final pub = filtered[i];
                    return _buildPublicationCard(context, pub);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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
      {'value': 'quarterly', 'label': 'Quarterly'},
      {'value': 'yearly', 'label': 'Yearly'},
      {'value': 'brochure', 'label': 'Brochure'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final selected = _archiveFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f['label']!),
              selected: selected,
              onSelected: (_) {
                setState(() => _archiveFilter = f['value']!);
              },
              backgroundColor: AppColors.lightGray,
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: selected ? AppColors.primaryBlue : AppColors.black,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPublicationCard(BuildContext context, Publication pub) {
    return GestureDetector(
      onTap: () {
        context.push('/kallacha/reader/${pub.id}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: pub.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGray,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.lightGray,
                      child: const Icon(Icons.book, size: 48),
                    ),
                  ),
                  if (pub.issueNumber != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${pub.issueNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pub.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pub.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      pub.subtitle!,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.mediumGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 10, color: AppColors.primaryRed),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('MMM yyyy').format(pub.publishedAt),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.mediumGray),
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
}
