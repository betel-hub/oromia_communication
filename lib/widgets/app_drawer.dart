import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../models/news_category.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Drawer(
      child: Container(
        color: AppColors.primaryBlue,
        child: Column(
          children: [
            // ============ HEADER ============
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.darkBlue),
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
                  Text(
                    t.appName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ============ MENU ITEMS ============
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildItem(context, Icons.home, t.home, () {
                      Navigator.pop(context);
                      context.go('/home');
                    }),

                    // ------- NEWS EXPANDABLE -------
                    ExpansionTile(
                      leading: const Icon(Icons.circle,
                          size: 8, color: AppColors.primaryRed),
                      title: Text(
                        t.news,
                        style: const TextStyle(
                            color: AppColors.white, fontSize: 15),
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
                          contentPadding: const EdgeInsets.only(
                              left: 48, right: 16),
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

                    // ------- TENDERS -------
                    _buildItem(context, Icons.gavel, t.tenders, () {
                      Navigator.pop(context);
                      context.push('/tenders');
                    }),

                    // ------- GOVERNMENT EXPANDABLE -------
                    ExpansionTile(
                      leading: const Icon(Icons.circle,
                          size: 8, color: AppColors.primaryRed),
                      title: Text(t.government,
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 15)),
                      iconColor: AppColors.white,
                      collapsedIconColor: AppColors.white,
                      backgroundColor: AppColors.primaryBlue,
                      collapsedBackgroundColor: AppColors.primaryBlue,
                      children: [
                        _buildSubItem(
                          context,
                          'Regional Sectors',
                          () => context.push('/government/regional-sectors'),
                        ),
                        _buildSubItem(
                          context,
                          'Zones → Woredas',
                          () => context.push('/government/zone'),
                        ),
                        _buildSubItem(
                          context,
                          'Cities → Sub-Cities',
                          () => context.push('/government/city'),
                        ),
                      ],
                    ),

                    // ------- MEDIA EXPANDABLE -------
                    ExpansionTile(
                      leading: const Icon(Icons.circle,
                          size: 8, color: AppColors.primaryRed),
                      title: Text(t.media,
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 15)),
                      iconColor: AppColors.white,
                      collapsedIconColor: AppColors.white,
                      backgroundColor: AppColors.primaryBlue,
                      collapsedBackgroundColor: AppColors.primaryBlue,
                      children: [
                        _buildSubItem(
                          context,
                          'Press Release',
                          () => context.push('/media/press-release'),
                        ),
                        _buildSubItem(
                          context,
                          'Documentary',
                          () => context.push('/media/documentary'),
                        ),
                        _buildSubItem(
                          context,
                          'Video',
                          () => context.push('/media/video'),
                        ),
                        _buildSubItem(
                          context,
                          'Image & Gallery',
                          () => context.push('/media/image-gallery'),
                        ),
                        _buildSubItem(
                          context,
                          'Audio Files',
                          () => context.push('/media/audio-files'),
                        ),
                      ],
                    ),

                    // ------- KALLACHA OROMIA EXPANDABLE -------
                    ExpansionTile(
                      leading: const Icon(Icons.circle,
                          size: 8, color: AppColors.primaryRed),
                      title: Text(t.kallachaOromia,
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 15)),
                      iconColor: AppColors.white,
                      collapsedIconColor: AppColors.white,
                      backgroundColor: AppColors.primaryBlue,
                      collapsedBackgroundColor: AppColors.primaryBlue,
                      children: [
                        _buildSubItem(
                          context,
                          'Weekly Newspaper',
                          () => context.push('/kallacha/weekly'),
                        ),
                        _buildSubItem(
                          context,
                          'Quarterly Newspaper',
                          () => context.push('/kallacha/quarterly'),
                        ),
                        _buildSubItem(
                          context,
                          'Yearly Book',
                          () => context.push('/kallacha/yearly'),
                        ),
                        _buildSubItem(
                          context,
                          'Brochure',
                          () => context.push('/kallacha/brochure'),
                        ),
                        _buildSubItem(
                          context,
                          'Archive',
                          () => context.push('/kallacha/archive'),
                        ),
                        _buildSubItem(
                          context,
                          'Files & Books',
                          () => context.push('/kallacha/files'),
                        ),
                      ],
                    ),

                    // ------- SHOP -------
                    _buildItem(context, Icons.shopping_bag, t.shop, () {
                      Navigator.pop(context);
                      context.push('/shop');
                    }),

                    // ------- AI ASSISTANT -------
                    _buildItem(context, Icons.smart_toy, 'AI Assistant', () {
                      Navigator.pop(context);
                      context.push('/ai');
                    }),

                    // ------- ABOUT -------
                    _buildItem(context, Icons.info_outline, t.about, () {
                      Navigator.pop(context);
                      context.push('/about');
                    }),

                    const Divider(color: AppColors.white24),

                    // ------- LANGUAGE -------
                    _buildItem(context, Icons.language, t.language, () {
                      Navigator.pop(context);
                      context.push('/language');
                    }),
                  ],
                ),
              ),
            ),

            // ============ FOOTER ============
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t.copyright,
                style: const TextStyle(
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

  // ============ MAIN MENU ITEM ============
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

  // ============ SUB MENU ITEM ============
  Widget _buildSubItem(
      BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.white70, fontSize: 13),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}