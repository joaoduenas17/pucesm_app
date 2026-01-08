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
        ],
      ),
    ],
  );
}
