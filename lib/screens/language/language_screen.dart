import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/language_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'code': 'am', 'name': 'Amharic', 'native': 'አማርኛ', 'flag': '🇪🇹'},
    {'code': 'om', 'name': 'Afaan Oromo', 'native': 'Afaan Oromoo', 'flag': '🇪🇹'},
    {'code': 'ti', 'name': 'Tigrigna', 'native': 'ትግርኛ', 'flag': '🇪🇹'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: languages.map((lang) {
          final selected = current.languageCode == lang['code'];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: selected
                ? AppColors.primaryBlue.withValues(alpha: 0.08)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.borderGray,
                width: selected ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Text(lang['flag']!,
                  style: const TextStyle(fontSize: 32)),
              title: Text(
                lang['native']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.black,
                ),
              ),
              subtitle: Text(lang['name']!),
              trailing: selected
                  ? const Icon(Icons.check_circle,
                      color: AppColors.primaryBlue)
                  : null,
              onTap: () {
                ref
                    .read(languageProvider.notifier)
                    .setLanguage(lang['code']!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Language set to ${lang['name']}'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.success,
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  if (context.mounted) context.pop();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}