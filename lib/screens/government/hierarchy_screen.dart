import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/government.dart';
import '../../providers/government_provider.dart';

class HierarchyScreen extends ConsumerWidget {
  final String rootType; // 'zone' or 'city'
  final int? parentId;
  final String? parentType; // 'zone' | 'woreda' | 'city' | 'sub_city'
  final String? title;

  const HierarchyScreen({
    super.key,
    required this.rootType,
    this.parentId,
    this.parentType,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = _loadItems(ref);
    final screenTitle = title ?? (rootType == 'zone' ? 'Zones' : 'Cities');

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: item.childCount > 0
                      ? Text('${item.childCount} ${item.childTypeLabel}')
                      : null,
                  trailing: item.type == 'kebele'
                      ? const Icon(Icons.info_outline)
                      : const Icon(Icons.chevron_right),
                  onTap: () => _onTap(context, item),
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

  AsyncValue<List<GovRegion>> _loadItems(WidgetRef ref) {
    if (parentId == null) {
      return rootType == 'zone'
          ? ref.watch(zonesProvider)
          : ref.watch(citiesProvider);
    }
    switch (parentType) {
      case 'zone':
        return ref.watch(woredasProvider(parentId!));
      case 'woreda':
        return ref.watch(kebelesProvider(parentId!));
      case 'city':
        return ref.watch(subCitiesProvider(parentId!));
      case 'sub_city':
        return ref.watch(kebelesProvider(parentId!));
      default:
        return const AsyncValue.data([]);
    }
  }

  void _onTap(BuildContext context, GovRegion item) {
    if (item.type == 'kebele') {
      // Leaf: show a dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(item.name),
          content: const Text('This is a Kebele (leaf level).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // Drill down
    
    final nextTitle = '${item.name} ${_nextLabel(item.type)}';
    context.push(
      '/government/${item.type}/${item.id}',
      extra: {'title': nextTitle, 'parentType': item.type},
    );
  }

  

  String _nextLabel(String type) {
    switch (type) {
      case 'zone':
        return 'Woredas';
      case 'woreda':
        return 'Kebeles';
      case 'city':
        return 'Sub-Cities';
      case 'sub_city':
        return 'Kebeles';
      default:
        return '';
    }
  }
}