import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class VirtualScreen extends StatefulWidget {
  const VirtualScreen({super.key});

  @override
  State<VirtualScreen> createState() => _VirtualScreenState();
}

class _VirtualScreenState extends State<VirtualScreen> {
  bool? _logged;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final logged = prefs.getBool('logged') ?? false;

    if (!mounted) return;
    setState(() => _logged = logged);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', false);

    if (!mounted) return;
    setState(() => _logged = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_logged == null) {
      // OJO: Sin Scaffold para no duplicar el de BottomNav
      return const Center(child: CircularProgressIndicator());
    }

    if (_logged == false) {
      // Login se renderiza dentro del shell (verás el AppBar del BottomNav)
      return LoginScreen(onLoginSuccess: _loadSession);
    }

    // Dashboard sin Scaffold/AppBar (evita duplicado)
    return _VirtualDashboardBody(onLogout: _logout);
  }
}

class _VirtualDashboardBody extends StatelessWidget {
  final VoidCallback onLogout;
  const _VirtualDashboardBody({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Botón “cerrar sesión” como acción dentro del contenido (ya no en AppBar)
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
        ),

        const SizedBox(height: 6),
        const _EVAHeaderCard(),
        const SizedBox(height: 16),

        _EVASectionCard(
          title: 'Materias',
          subtitle: 'Accede a tus asignaturas y contenidos.',
          icon: Icons.menu_book,
          onTap: () => context.go('/virtual/materias'),
        ),
        const SizedBox(height: 12),

        _EVASectionCard(
          title: 'Tareas',
          subtitle: 'Revisa y gestiona tus actividades.',
          icon: Icons.assignment_turned_in,
          onTap: () => context.go('/virtual/tareas'),
        ),
        const SizedBox(height: 12),

        _EVASectionCard(
          title: 'Calificaciones',
          subtitle: 'Consulta tu rendimiento académico.',
          icon: Icons.bar_chart,
          onTap: () => context.go('/virtual/calificaciones'),
        ),
        const SizedBox(height: 12),

        _EVASectionCard(
          title: 'Mensajes',
          subtitle: 'Comunicación con docentes.',
          icon: Icons.chat_bubble_outline,
          onTap: () => context.go('/virtual/mensajes'),
        ),
        const SizedBox(height: 12),

        _EVASectionCard(
          title: 'Perfil',
          subtitle: 'Información personal y ajustes.',
          icon: Icons.person_outline,
          onTap: () => context.go('/virtual/perfil'),
        ),
      ],
    );
  }
}

class _EVAHeaderCard extends StatelessWidget {
  const _EVAHeaderCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/logo_puce.png',
              width: 52,
              height: 52,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVA PUCESM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Accede a tus recursos académicos desde la app.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EVASectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _EVASectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, 6),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: primary),
          ],
        ),
      ),
    );
  }
}

