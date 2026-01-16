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

  bool _notificationsEnabled = true;
  bool _analyticsEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('privacy_notifications') ?? true;
      _analyticsEnabled = prefs.getBool('privacy_analytics') ?? false;
      _loading = false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _setBool('privacy_notifications', value);

    if (!value) {
      // Si el usuario apaga notificaciones, cancelamos recordatorios programados
      await NotificationService.cancelAll();
    }
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ojo: NO borramos lo de tema/accesibilidad (AppState) ni la sesión EVA aquí.
    // Solo datos de perfil / privacidad (modo prototipo).
    await prefs.remove('profile_name');
    await prefs.remove('profile_email');
    await prefs.remove('profile_program');
    await prefs.remove('privacy_notifications');
    await prefs.remove('privacy_analytics');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos locales eliminados ✅')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y seguridad')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'En este prototipo, varias opciones aplican a nivel local. En una versión final, estas configuraciones se gestionan con autenticación institucional.',
                    style: TextStyle(color: Color(0xFF5B6472), height: 1.25),
                  ),
                ),
                const SizedBox(height: 14),

                Card(
                  child: SwitchListTile(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    secondary: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.notifications_active_outlined, color: cs.primary),
                    ),
                    title: const Text('Notificaciones y recordatorios',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Permite recordatorios del calendario académico'),
                  ),
                ),

                Card(
                  child: SwitchListTile(
                    value: _analyticsEnabled,
                    onChanged: (v) async {
                      setState(() => _analyticsEnabled = v);
                      await _setBool('privacy_analytics', v);
                    },
                    secondary: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.insights_outlined, color: cs.primary),
                    ),
                    title: const Text('Analítica (modo prototipo)',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Permite métricas anónimas para mejorar la app'),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.password_outlined, color: cs.primary),
                    ),
                    title: const Text('Cambiar contraseña',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Disponible cuando exista autenticación real'),
                    trailing: const Icon(Icons.lock_outline),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pendiente: autenticación institucional (backend)'),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text('Eliminar datos locales',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Borra perfil y preferencias de privacidad'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirmar'),
                          content: const Text('¿Eliminar los datos locales del prototipo?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (ok == true) {
                        await _clearLocalData();
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
