import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _contactEmail = 'info@pucesm.edu.ec';
  static const _pbx = '053700750';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      // No tiramos exception para no romper UX
      // ignore: avoid_print
      print('No se pudo abrir: $url');
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      queryParameters: {
        'subject': 'Soporte PUCESM App',
        'body': 'Hola, necesito ayuda con:',
      },
    );
    await launchUrl(uri);
  }

  Future<void> _callPbx() async {
    final uri = Uri(scheme: 'tel', path: _pbx);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Centro de ayuda')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Aquí encontrarás respuestas rápidas y canales de contacto oficiales.',
              style: TextStyle(color: Color(0xFF5B6472), height: 1.25),
            ),
          ),
          const SizedBox(height: 14),

          _SectionTitle(title: 'Preguntas frecuentes', color: cs.primary),
          const SizedBox(height: 10),

          // ✅ Se quedan las 2 primeras tal cual
          const _FaqTile(
            title: '¿Cómo edito mi perfil?',
            body:
                'En Perfil → Editar perfil. Puedes ajustar tu nombre, correo y seleccionar tu nivel (Grado/Posgrado) y tu programa.',
          ),
          const _FaqTile(
            title: '¿Cómo activo las notificaciones?',
            body:
                'En Perfil → Privacidad y seguridad. Ahí puedes habilitar notificaciones de Noticias y recordatorios del Calendario.',
          ),

          // ✅ Reemplazo de las 2 preguntas que no te gustaban
          const _FaqTile(
            title: '¿Cómo actualizo las noticias y por qué a veces no cargan imágenes?',
            body:
                'En la pantalla de Noticias puedes hacer “pull to refresh” (desliza hacia abajo) para recargar. '
                'Si una imagen no carga, suele ser por conexión o porque la fuente requiere encabezados de acceso. '
                'Si persiste, prueba con datos móviles o revisa que la app tenga acceso a internet.',
          ),
          const _FaqTile(
            title: '¿Qué hago si no recibo recordatorios del calendario?',
            body:
                'Primero, ve a Perfil → Privacidad y seguridad y verifica que “Calendario académico” esté activado. '
                'Luego revisa permisos de notificaciones del sistema (Android/iOS). '
                'En Android, algunos teléfonos bloquean notificaciones en segundo plano por ahorro de batería: '
                'permite “notificaciones” y evita la restricción de batería para la app.',
          ),

          const SizedBox(height: 18),
          _SectionTitle(title: 'Contacto', color: cs.primary),
          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.mail_outline, color: cs.primary),
              ),
              title: const Text(
                'Correo institucional',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(_contactEmail),
              trailing: const Icon(Icons.chevron_right),
              onTap: _sendEmail,
            ),
          ),
          Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.call_outlined, color: cs.primary),
              ),
              title: const Text('PBX', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('05 3700750'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _callPbx,
            ),
          ),

          const SizedBox(height: 18),
          _SectionTitle(title: 'Enlaces oficiales', color: cs.primary),
          const SizedBox(height: 10),

          _LinkTile(
            icon: Icons.language,
            title: 'Sitio web',
            subtitle: 'pucesm.edu.ec',
            onTap: () => _openUrl('https://pucesm.edu.ec/'),
          ),
          _LinkTile(
            icon: Icons.school_outlined,
            title: 'Noticias',
            subtitle: 'Sección de noticias PUCE Manabí',
            onTap: () => _openUrl('https://pucesm.edu.ec/noticias'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: color.withOpacity(0.9),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String title;
  final String body;
  const _FaqTile({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Text(
            body,
            style: const TextStyle(color: Color(0xFF5B6472), height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: onTap,
      ),
    );
  }
}
