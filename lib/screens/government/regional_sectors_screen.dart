import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/government_provider.dart';

class RegionalSectorsScreen extends ConsumerWidget {
  const RegionalSectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectorsAsync = ref.watch(regionalSectorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Regional Sectors')),
      body: sectorsAsync.when(
        data: (sectors) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sectors.length,
          itemBuilder: (context, i) {
            final sector = sectors[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sector.description,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    if (sector.phone != null)
                      Row(children: [
                        const Icon(Icons.phone,
                            size: 14, color: AppColors.mediumGray),
                        const SizedBox(width: 6),
                        Text(sector.phone!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray)),
                      ]),
                    if (sector.email != null)
                      Row(children: [
                        const Icon(Icons.email,
                            size: 14, color: AppColors.mediumGray),
                        const SizedBox(width: 6),
                        Text(sector.email!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray)),
                      ]),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}