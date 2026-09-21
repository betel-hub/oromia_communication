import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/tender_provider.dart';

class TendersScreen extends ConsumerWidget {
  const TendersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tendersAsync = ref.watch(tendersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenders')),
      body: tendersAsync.when(
        data: (tenders) {
          if (tenders.isEmpty) {
            return const Center(child: Text('No tenders available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tenders.length,
            itemBuilder: (context, i) {
              final tender = tenders[i];
              final daysLeft =
                  tender.deadline.difference(DateTime.now()).inDays;
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: daysLeft > 7
                                  ? Colors.green
                                  : AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              daysLeft > 0 ? '$daysLeft days left' : 'Expired',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tender.description,
                        style:
                            const TextStyle(fontSize: 13, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: AppColors.mediumGray),
                          const SizedBox(width: 6),
                          Text(
                            'Deadline: ${DateFormat('MMM d, yyyy').format(tender.deadline)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.mediumGray),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(tender.title),
                                  content: const Text(
                                      'PDF document will open here.\n\n(Mock placeholder — no real PDF yet)'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('View Document'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}