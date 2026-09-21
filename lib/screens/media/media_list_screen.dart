import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/media.dart';
import '../../providers/media_provider.dart';

class MediaListScreen extends ConsumerWidget {
  final MediaType type;

  const MediaListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(mediaListProvider(type.slug));

    return Scaffold(
      appBar: AppBar(title: Text(type.displayName)),
      body: mediaAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No media available'));
          }
          switch (type) {
            case MediaType.pressRelease:
              return _buildPressReleaseList(items);
            case MediaType.documentary:
            case MediaType.video:
              return _buildVideoGrid(items);
            case MediaType.imageGallery:
              return _buildGalleryGrid(items);
            case MediaType.audioFiles:
              return _buildAudioList(items);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPressReleaseList(List<MediaItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.description, color: AppColors.primaryBlue),
            title: Text(item.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                DateFormat('MMM d, yyyy').format(item.publishedAt)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid(List<MediaItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () {},
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Container(color: AppColors.lightGray),
                      ),
                      Container(color: Colors.black26),
                      const Center(
                        child: Icon(Icons.play_circle_filled,
                            color: Colors.white, size: 48),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 11, color: AppColors.primaryRed),
                          const SizedBox(width: 3),
                          Text(
                            DateFormat('MMM d, yyyy').format(item.publishedAt),
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.mediumGray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(height: 2, color: AppColors.primaryRed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid(List<MediaItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: item.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Container(color: AppColors.lightGray),
                ),
                if (item.imageUrls != null && item.imageUrls!.length > 1)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${item.imageUrls!.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioList(List<MediaItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final mins = item.duration ~/ 60;
        final secs = (item.duration % 60).toString().padLeft(2, '0');
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.audiotrack,
                color: AppColors.primaryBlue, size: 32),
            title: Text(item.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$mins:$secs  •  ${DateFormat('MMM d, yyyy').format(item.publishedAt)}'),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_filled,
                  color: AppColors.primaryRed, size: 36),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
