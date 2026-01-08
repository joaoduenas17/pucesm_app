import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Splash
import '../screens/splash/splash_screen.dart';

// App pública
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';


// Entorno Virtual
import '../screens/virtual/virtual_screen.dart';
import '../screens/virtual/materias_screen.dart';
import '../screens/virtual/tareas_screen.dart';
import '../screens/virtual/calificaciones_screen.dart';
import '../screens/virtual/mensajes_screen.dart';
import '../screens/virtual/perfil_virtual_screen.dart';

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
        builder: (context, state, child) {
          return BottomNav(child: child);
        },
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
          GoRoute(
            path: '/virtual/materias',
            builder: (context, state) => const MateriasScreen(),
          ),
          GoRoute(
            path: '/virtual/tareas',
            builder: (context, state) => const TareasScreen(),
          ),
          GoRoute(
            path: '/virtual/calificaciones',
            builder: (context, state) => const CalificacionesScreen(),
          ),
          GoRoute(
            path: '/virtual/mensajes',
            builder: (context, state) => const MensajesScreen(),
          ),
          GoRoute(
            path: '/virtual/perfil',
            builder: (context, state) => const PerfilVirtualScreen(),
          ),
        ],
      ),
    ],
  );
}
