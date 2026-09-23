import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:meine_entwickler/core/theme/app_colors.dart';
import 'package:meine_entwickler/core/theme/app_theme.dart';
import 'package:meine_entwickler/l10n/app_localizations.dart';

import 'models/media.dart';
import 'models/news.dart';
import 'models/news_category.dart';
import 'models/publication.dart';
import 'providers/language_provider.dart';
import 'screens/about/about_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/government/government_menu_screen.dart';
import 'screens/government/hierarchy_screen.dart';
import 'screens/government/regional_sectors_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/kallacha/publication_list_screen.dart';
import 'screens/kallacha/reader_screen.dart';
import 'screens/language/language_screen.dart';
import 'screens/media/media_list_screen.dart';
import 'screens/news/category_news_screen.dart';
import 'screens/news/news_detail_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/shop/cart_screen.dart';
import 'screens/shop/checkout_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tenders/tenders_screen.dart';

void main() {
  runApp(const ProviderScope(child: OromiaApp()));
}

class OromiaApp extends ConsumerWidget {
  const OromiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    // Flutter doesn't bundle Tigrigna ('ti') for Material widgets — fall back to English
    final materialLocale =
        locale.languageCode == 'ti' ? const Locale('en') : locale;

    return MaterialApp.router(
      title: 'Oromia Communication Bureau',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      locale: materialLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
        Locale('ti'),
      ],

      routerConfig: _router,
    );
  }
}

// ==================== ROUTER ====================
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ============ SPLASH ============
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ============ HOME ============
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // ============ AUTH ============
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // ============ NEWS ============
    GoRoute(
      path: '/news/:categorySlug',
      name: 'categoryNews',
      builder: (context, state) {
        final slug = state.pathParameters['categorySlug'] ?? 'all';
        final category = NewsCategoryExtension.fromSlug(slug);
        return CategoryNewsScreen(category: category);
      },
    ),
    GoRoute(
      path: '/news/:categorySlug/:id',
      name: 'newsDetail',
      builder: (context, state) {
        final news = state.extra as News?;
        if (news == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('News not found',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          );
        }
        return NewsDetailScreen(news: news);
      },
    ),

    // ============ GOVERNMENT ============
    GoRoute(
      path: '/government',
      name: 'government',
      builder: (context, state) => const GovernmentMenuScreen(),
    ),
    GoRoute(
      path: '/government/regional-sectors',
      name: 'regionalSectors',
      builder: (context, state) => const RegionalSectorsScreen(),
    ),
    GoRoute(
      path: '/government/zone',
      name: 'zonesRoot',
      builder: (context, state) => const HierarchyScreen(rootType: 'zone'),
    ),
    GoRoute(
      path: '/government/city',
      name: 'citiesRoot',
      builder: (context, state) => const HierarchyScreen(rootType: 'city'),
    ),
    GoRoute(
      path: '/government/:parentType/:parentId',
      name: 'hierarchyLevel',
      builder: (context, state) {
        final parentType = state.pathParameters['parentType'] ?? '';
        final parentId =
            int.tryParse(state.pathParameters['parentId'] ?? '0') ?? 0;
        final extra = state.extra as Map<String, dynamic>?;
        return HierarchyScreen(
          rootType: parentType == 'zone' ? 'zone' : 'city',
          parentId: parentId,
          parentType: parentType,
          title: extra?['title'] as String?,
        );
      },
    ),

    // ============ MEDIA ============
    GoRoute(
      path: '/media/:type',
      name: 'mediaList',
      builder: (context, state) {
        final slug = state.pathParameters['type'] ?? 'press-release';
        final type = MediaTypeExtension.fromSlug(slug);
        return MediaListScreen(type: type);
      },
    ),

    // ============ KALLACHA OROMIA ============
    GoRoute(
      path: '/kallacha/:type',
      name: 'publicationList',
      builder: (context, state) {
        final slug = state.pathParameters['type'] ?? 'weekly';
        final type = PublicationTypeExtension.fromSlug(slug);
        return PublicationListScreen(type: type);
      },
    ),
    GoRoute(
      path: '/kallacha/reader/:bookId',
      name: 'reader',
      builder: (context, state) {
        final id =
            int.tryParse(state.pathParameters['bookId'] ?? '0') ?? 0;
        return ReaderScreen(bookId: id);
      },
    ),

    // ============ SHOP ============
    GoRoute(
      path: '/shop',
      name: 'shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: '/shop/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/shop/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),

    // ============ TENDERS ============
    GoRoute(
      path: '/tenders',
      name: 'tenders',
      builder: (context, state) => const TendersScreen(),
    ),

    // ============ ABOUT ============
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),

    // ============ SEARCH ============
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),

    // ============ LANGUAGE ============
    GoRoute(
      path: '/language',
      name: 'language',
      builder: (context, state) => const LanguageScreen(),
    ),
  ],
);