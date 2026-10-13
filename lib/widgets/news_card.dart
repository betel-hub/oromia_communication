import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/news.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const NewsCard({
    super.key,
    required this.news,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? _buildHorizontal() : _buildList();
  }

  Widget _buildHorizontal() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGray, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: news.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: AppColors.lightGray,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  color: AppColors.lightGray,
                  child: const Icon(Icons.image, color: AppColors.mediumGray),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _meta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  width: 110,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 110,
                    height: 90,
                    color: AppColors.lightGray,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 110,
                    height: 90,
                    color: AppColors.lightGray,
                    child: const Icon(Icons.image, color: AppColors.mediumGray),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _meta(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 12, color: AppColors.mediumGray),
        const SizedBox(width: 3),
        Text(
          DateFormat('MMM d, yyyy').format(news.publishedAt),
          style: const TextStyle(fontSize: 11, color: AppColors.mediumGray),
        ),
        const Spacer(),
        const Icon(Icons.remove_red_eye_outlined,
            size: 12, color: AppColors.mediumGray),
        const SizedBox(width: 3),
        Text(
          '${news.viewCount}',
          style: const TextStyle(fontSize: 11, color: AppColors.mediumGray),
        ),
      ],
    );
  }
}