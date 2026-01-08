import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Splash
import '../screens/splash/splash_screen.dart';

// App pública
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

// Entorno Virtual (WebView / in-app browser)
import '../screens/virtual/virtual_screen.dart';

// Noticias
import '../screens/news/news_list_screen.dart';
import '../screens/news/news_detail_screen.dart';
import '../models/news_item.dart';

// Widgets
import '../widgets/bottom_nav.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ======================
      // Splash (sin BottomNav)
      // ======================
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ======================
      // App principal
      // ======================
      ShellRoute(
        builder: (context, state, child) => BottomNav(child: child),
        routes: [
          // -------- Home --------
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),

          // -------- Calendario --------
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),

          // -------- Perfil público --------
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) => const EditProfileScreen(),
          ),

          // ======================
          // Entorno Virtual (EVA)
          // ======================
          GoRoute(
            path: '/virtual',
            builder: (context, state) => const VirtualScreen(),
          ),

          // ======================
          // Noticias
          // ======================
          GoRoute(
            path: '/news',
            builder: (context, state) => const NewsListScreen(),
          ),
          GoRoute(
            path: '/news/detail',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! NewsItem) {
                return const _BadRouteScreen(
                  message: 'Falta NewsItem en state.extra',
                );
              }
              return NewsDetailScreen(item: extra);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _BadRouteScreen(
      message: state.error?.toString() ?? 'Ruta no encontrada',
    ),
  );
}

class _BadRouteScreen extends StatelessWidget {
  final String message;
  const _BadRouteScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
