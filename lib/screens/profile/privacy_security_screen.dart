import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _loading = true;

  // ✅ Switch maestro
  bool _masterNotifs = true;

  // Módulos
  bool _newsNotifs = true;
  bool _calendarNotifs = true;
  bool _calendarOnlyMyLevel = true;

  // Leído desde perfil: 'grado' | 'posgrado'
  String _profileLevel = 'grado';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _masterNotifs = prefs.getBool('privacy_notifications') ?? true;

      // ✅ Compatibilidad: si existe notif_news_enabled úsalo, sino notif_news
      _newsNotifs = prefs.getBool('notif_news_enabled') ??
          prefs.getBool('notif_news') ??
          true;

      _calendarNotifs = prefs.getBool('notif_calendar_enabled') ?? true;
      _calendarOnlyMyLevel =
          prefs.getBool('notif_calendar_only_my_level') ?? true;

      _profileLevel = prefs.getString('profile_level') ?? 'grado';

      _loading = false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // ✅ Guardamos ambos keys para evitar inconsistencias con pantallas anteriores
  Future<void> _setNewsEnabled(bool value) async {
    await _setBool('notif_news_enabled', value);
    await _setBool('notif_news', value); // compat
  }

  Future<void> _toggleMaster(bool v) async {
    setState(() => _masterNotifs = v);
    await _setBool('privacy_notifications', v);

    if (!v) {
      // Apaga todo: cancelamos recordatorios programados
      await NotificationService.cancelAll();
    }
  }

  Future<void> _toggleNews(bool v) async {
    setState(() => _newsNotifs = v);
    await _setNewsEnabled(v);
  }

  Future<void> _toggleCalendar(bool v) async {
    setState(() => _calendarNotifs = v);
    await _setBool('notif_calendar_enabled', v);

    // Si apaga calendario, cancelamos recordatorios programados
    if (!v) {
      await NotificationService.cancelAll();
    }
  }

  Future<void> _toggleOnlyMyLevel(bool v) async {
    setState(() => _calendarOnlyMyLevel = v);
    await _setBool('notif_calendar_only_my_level', v);
  }

  Future<void> _testNotification() async {
    // Si el maestro está apagado, igual dejamos que pruebe (pero le avisamos)
    await NotificationService.requestPermissions();

    await NotificationService.showInstant(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'PUCESM App',
      body: 'Si ves esto, tus notificaciones están funcionando ✅',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _masterNotifs
              ? 'Notificación de prueba enviada.'
              : 'Enviado ✅ (pero tu switch maestro está apagado).',
        ),
      ),
    );
  }

  String get _levelLabel => _profileLevel == 'posgrado' ? 'Posgrado' : 'Grado';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final modulesEnabled = _masterNotifs;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y seguridad')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _SectionTitle(title: 'Notificaciones'),

                Card(
                  child: SwitchListTile(
                    value: _masterNotifs,
                    onChanged: _toggleMaster,
                    secondary: _IconBox(
                      icon: Icons.notifications_active_outlined,
                      color: cs.primary,
                    ),
                    title: const Text(
                      'Notificaciones (general)',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Activa o desactiva todas las notificaciones de la app',
                    ),
                  ),
                ),

                Card(
                  child: SwitchListTile(
                    value: _newsNotifs,
                    onChanged: modulesEnabled ? _toggleNews : null,
                    secondary: _IconBox(
                      icon: Icons.newspaper_outlined,
                      color: cs.primary,
                    ),
                    title: const Text(
                      'Noticias',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Recibe avisos cuando haya noticias institucionales',
                    ),
                  ),
                ),

                Card(
                  child: SwitchListTile(
                    value: _calendarNotifs,
                    onChanged: modulesEnabled ? _toggleCalendar : null,
                    secondary: _IconBox(
                      icon: Icons.event_available_outlined,
                      color: cs.primary,
                    ),
                    title: const Text(
                      'Calendario académico',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Permite recordatorios de eventos del calendario',
                    ),
                  ),
                ),

                Card(
                  child: SwitchListTile(
                    value: _calendarOnlyMyLevel,
                    onChanged: (modulesEnabled && _calendarNotifs)
                        ? _toggleOnlyMyLevel
                        : null,
                    secondary: _IconBox(
                      icon: Icons.filter_alt_outlined,
                      color: cs.primary,
                    ),
                    title: const Text(
                      'Solo eventos de mi nivel',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'Filtra notificaciones del calendario para: $_levelLabel',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: _IconBox(
                      icon: Icons.notifications_none,
                      color: cs.primary,
                    ),
                    title: const Text(
                      'Probar notificación',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Verifica permisos y funcionamiento en el dispositivo',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _testNotification,
                  ),
                ),

                const SizedBox(height: 18),

                _SectionTitle(title: 'Datos'),

                Card(
                  child: ListTile(
                    leading: _IconBox(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      bg: Colors.red.withOpacity(0.10),
                    ),
                    title: const Text(
                      'Restablecer preferencias',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Borra preferencias de perfil y notificaciones',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirmar'),
                          content:
                              const Text('¿Deseas restablecer tus preferencias?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Restablecer'),
                            ),
                          ],
                        ),
                      );

                      if (ok == true) {
                        final prefs = await SharedPreferences.getInstance();

                        // Perfil
                        await prefs.remove('profile_name');
                        await prefs.remove('profile_email');
                        await prefs.remove('profile_program');
                        await prefs.remove('profile_level');

                        // Notifs (incluye compat)
                        await prefs.remove('privacy_notifications');
                        await prefs.remove('notif_news_enabled');
                        await prefs.remove('notif_news');
                        await prefs.remove('notif_calendar_enabled');
                        await prefs.remove('notif_calendar_only_my_level');

                        await NotificationService.cancelAll();

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Preferencias restablecidas ✅')),
                        );
                        await _load();
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: cs.primary.withOpacity(0.9),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? bg;

  const _IconBox({
    required this.icon,
    required this.color,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

