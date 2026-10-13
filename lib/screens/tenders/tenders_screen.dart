import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/tender.dart';
import '../../providers/tender_provider.dart';

class TendersScreen extends ConsumerWidget {
  const TendersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tendersAsync = ref.watch(tendersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tendersProvider),
          ),
        ],
      ),
      body: tendersAsync.when(
        data: (tenders) {
          if (tenders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel, size: 64, color: AppColors.mediumGray),
                  SizedBox(height: 16),
                  Text('No tenders available',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    'Check back later',
                    style: TextStyle(color: AppColors.mediumGray),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tenders.length,
            itemBuilder: (context, i) => _buildTenderCard(context, tenders[i]),
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
                Text('Error: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(tendersProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTenderCard(BuildContext context, Tender tender) {
    // Days-left badge color
    Color badgeColor;
    String badgeText;
    if (tender.daysLeft <= 0) {
      badgeColor = AppColors.mediumGray;
      badgeText = 'Expired';
    } else if (tender.daysLeft <= 3) {
      badgeColor = AppColors.primaryRed;
      badgeText = '${tender.daysLeft} days left';
    } else if (tender.daysLeft <= 7) {
      badgeColor = Colors.orange;
      badgeText = '${tender.daysLeft} days left';
    } else {
      badgeColor = AppColors.success;
      badgeText = '${tender.daysLeft} days left';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    tender.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              tender.description,
              style: const TextStyle(fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Deadline + View button
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.mediumGray),
                const SizedBox(width: 6),
                Text(
                  'Deadline: ${DateFormat('MMM d, yyyy').format(tender.deadline)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDocumentDialog(context, tender),
                  child: const Text('View Document'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentDialog(BuildContext context, Tender tender) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tender.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tender document will open here.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              '(Backend integration coming soon)',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}