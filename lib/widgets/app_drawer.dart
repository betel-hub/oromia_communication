import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../models/news_category.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.primaryBlue,
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.darkBlue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.newspaper,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Oromia Communication\nBureau',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildItem(context, Icons.home, 'Home', () {
                    Navigator.pop(context);
                    context.go('/home');
                  }),

                  // 👇 EXPANDABLE NEWS ITEM 👇
                  ExpansionTile(
                    leading: const Icon(Icons.circle,
                        size: 8, color: AppColors.primaryRed),
                    title: const Text(
                      'News',
                      style: TextStyle(color: AppColors.white, fontSize: 15),
                    ),
                    iconColor: AppColors.white,
                    collapsedIconColor: AppColors.white,
                    backgroundColor: AppColors.primaryBlue,
                    collapsedBackgroundColor: AppColors.primaryBlue,
                    children: [
                      NewsCategory.politics,
                      NewsCategory.social,
                      NewsCategory.economy,
                      NewsCategory.sport,
                      NewsCategory.technology,
                      NewsCategory.environment,
                      NewsCategory.features,
                    ].map((cat) {
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 48, right: 16),
                        title: Text(
                          cat.displayName,
                          style: const TextStyle(
                              color: AppColors.white70, fontSize: 13),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/news/${cat.slug}');
                        },
                      );
                    }).toList(),
                  ),
                  // 👆 END EXPANDABLE 👆

                 _buildItem(context, Icons.gavel, 'Tenders', () {
  Navigator.pop(context);
  context.push('/tenders');
}),
_buildItem(context, Icons.info_outline, 'About', () {
  Navigator.pop(context);
  context.push('/about');
}),

                  // 👇 GOVERNMENT EXPANDABLE 👇
                  ExpansionTile(
                    leading: const Icon(Icons.circle,
                        size: 8, color: AppColors.primaryRed),
                    title: const Text('Government',
                        style:
                            TextStyle(color: AppColors.white, fontSize: 15)),
                    iconColor: AppColors.white,
                    collapsedIconColor: AppColors.white,
                    backgroundColor: AppColors.primaryBlue,
                    collapsedBackgroundColor: AppColors.primaryBlue,
                    children: [
                      _buildSubItem(context, 'Regional Sectors',
                          () => context.push('/government/regional-sectors')),
                      _buildSubItem(context, 'Zones → Woredas',
                          () => context.push('/government/zone')),
                      _buildSubItem(context, 'Cities → Sub-Cities',
                          () => context.push('/government/city')),
                    ],
                  ),
                  // 👆 END GOVERNMENT EXPANDABLE 👆

                  ExpansionTile(
  leading: const Icon(Icons.circle, size: 8, color: AppColors.primaryRed),
  title: const Text('Media',
      style: TextStyle(color: AppColors.white, fontSize: 15)),
  iconColor: AppColors.white,
  collapsedIconColor: AppColors.white,
  backgroundColor: AppColors.primaryBlue,
  collapsedBackgroundColor: AppColors.primaryBlue,
  children: [
    _buildSubItem(context, 'Press Release',
        () => context.push('/media/press-release')),
    _buildSubItem(context, 'Documentary',
        () => context.push('/media/documentary')),
    _buildSubItem(context, 'Video',
        () => context.push('/media/video')),
    _buildSubItem(context, 'Image & Gallery',
        () => context.push('/media/image-gallery')),
    _buildSubItem(context, 'Audio Files',
        () => context.push('/media/audio-files')),
  ],
),
                 ExpansionTile(
  leading: const Icon(Icons.circle, size: 8, color: AppColors.primaryRed),
  title: const Text('Kallacha Oromia',
      style: TextStyle(color: AppColors.white, fontSize: 15)),
  iconColor: AppColors.white,
  collapsedIconColor: AppColors.white,
  backgroundColor: AppColors.primaryBlue,
  collapsedBackgroundColor: AppColors.primaryBlue,
  children: [
    _buildSubItem(context, 'Weekly Newspaper',
        () => context.push('/kallacha/weekly')),
    _buildSubItem(context, 'Quarterly Newspaper',
        () => context.push('/kallacha/quarterly')),
    _buildSubItem(context, 'Yearly Book',
        () => context.push('/kallacha/yearly')),
    _buildSubItem(context, 'Brochure',
        () => context.push('/kallacha/brochure')),
    _buildSubItem(context, 'Archive',
        () => context.push('/kallacha/archive')),
    _buildSubItem(context, 'Files & Books',
        () => context.push('/kallacha/files')),
  ],
),
                 _buildItem(context, Icons.shopping_bag, 'Shop', () {
  Navigator.pop(context);
  context.push('/shop');
}),
                  _buildItem(context, Icons.info_outline, 'About', () {
                    Navigator.pop(context);
                  }),
                  const Divider(color: AppColors.white24),
                 _buildItem(context, Icons.language, 'Language', () {
  Navigator.pop(context);
  context.push('/language');
}),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '© 2026 Oromia Communication Bureau',
                style: TextStyle(
                  color: AppColors.white54,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: const Icon(Icons.circle, size: 8, color: AppColors.primaryRed),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.white54,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  // 👇 NEW helper method for sub-items 👇
  Widget _buildSubItem(
      BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      title: Text(title,
          style: const TextStyle(color: AppColors.white70, fontSize: 13)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}