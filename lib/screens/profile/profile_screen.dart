import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_state.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;

  // Datos editables (persistidos)
  String _name = 'Estudiante PUCE';
  String _email = 'correo@puce.edu.ec';
  String _program = 'Carrera • PUCE Manabí';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? _name;
      _email = prefs.getString('profile_email') ?? _email;
      _program = prefs.getString('profile_program') ?? _program;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _ProfileHeader(
              name: _name,
              email: _email,
              program: _program,
              imagePath: state.profileImagePath,
              onChangePhoto: () => _openPhotoSheet(context),
            ),

          const SizedBox(height: 14),

          _SectionTitle(title: 'Cuenta'),
          const SizedBox(height: 10),

          _SettingTile(
            icon: Icons.edit,
            title: 'Editar perfil',
            subtitle: 'Nombre, correo, carrera y datos básicos',
            onTap: () async {
              final changed = await context.push<bool>('/profile/edit');
              if (changed == true) {
                await _loadProfile();
                if (mounted) _toast(context, 'Perfil actualizado ✅');
              }
            },
          ),

          _SettingTile(
            icon: Icons.lock_outline,
            title: 'Privacidad y seguridad',
            subtitle: 'Notificaciones, permisos y controles',
            onTap: () => context.push('/profile/security'),
          ),

          const SizedBox(height: 18),
          _SectionTitle(title: 'Preferencias'),
          const SizedBox(height: 10),

          _SwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Modo oscuro',
            subtitle: 'Reduce el brillo y mejora la lectura',
            value: state.darkMode,
            onChanged: (v) => context.read<AppState>().setDarkMode(v),
          ),

          _TextScaleTile(
            value: state.textScale,
            onChanged: (v) => context.read<AppState>().setTextScale(v),
          ),

          _SwitchTile(
            icon: Icons.motion_photos_off_outlined,
            title: 'Reducir animaciones',
            subtitle: 'Mejor para accesibilidad y rendimiento',
            value: state.reduceMotion,
            onChanged: (v) => context.read<AppState>().setReduceMotion(v),
          ),

          const SizedBox(height: 18),
          _SectionTitle(title: 'Soporte'),
          const SizedBox(height: 10),

          _SettingTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Preguntas frecuentes y contacto',
            onTap: () => _toast(context, 'Luego lo conectamos a un centro de ayuda 🙂'),
          ),
          _SettingTile(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Versión, créditos y licencias',
            onTap: () => _showAbout(context),
          ),

          const SizedBox(height: 18),
          _SectionTitle(title: 'Enlaces oficiales'),
          const SizedBox(height: 10),
          _SocialLinksCard(
            onOpenWeb: () => _openUrl('https://pucem.edu.ec/'),
            onOpenFacebook: () => _openUrl('https://www.facebook.com/pucemanabi/'),
            onOpenInstagram: () => _openUrl('https://www.instagram.com/pucemanabi/'),
          ),

          const SizedBox(height: 16),

          // Cerrar sesión EVA (real)
          _LogoutButton(
            onTap: () => _logoutEVA(context),
          ),
        ],
      ),
    );
  }

  // =========================
  // FOTO PERFIL
  // =========================
  Future<void> _openPhotoSheet(BuildContext context) async {
    final state = context.read<AppState>();
    final hasPhoto = (state.profileImagePath ?? '').isNotEmpty;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Foto de perfil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Elegir de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndSave(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndSave(context, ImageSource.camera);
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Quitar foto', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<AppState>().clearProfilePhoto();
                      if (context.mounted) _toast(context, 'Foto eliminada');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndSave(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final fileName = 'profile_photo${ext.toLowerCase()}';
    final saved = File(p.join(dir.path, fileName));

    await File(picked.path).copy(saved.path);

    if (!context.mounted) return;
    await context.read<AppState>().setProfileImagePath(saved.path);
    _toast(context, 'Foto actualizada ✅');
  }

  // =========================
  // LOGOUT EVA
  // =========================
  static Future<void> _logoutEVA(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', false);

    if (!context.mounted) return;
    _toast(context, 'Sesión cerrada');
    context.go('/virtual');
  }

  // =========================
  // LINKS
  // =========================
  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // =========================
  // UI helpers
  // =========================
  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PUCESM App',
      applicationVersion: '0.1.0',
      applicationLegalese: 'Proyecto académico – PUCE Manabí',
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String program;
  final String? imagePath;
  final VoidCallback onChangePhoto;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.program,
    required this.imagePath,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasPhoto = (imagePath ?? '').isNotEmpty && File(imagePath!).existsSync();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.18),
            cs.primary.withOpacity(0.06),
          ],
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.primary.withOpacity(0.25),
                    width: 1.2,
                  ),
                  image: hasPhoto
                      ? DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasPhoto
                    ? Icon(Icons.person, size: 36, color: cs.primary)
                    : null,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: cs.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onChangePhoto,
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Text(
                  program,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: cs.primary.withOpacity(0.9),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
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
      ),
    );
  }
}

class _TextScaleTile extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _TextScaleTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    double clamp(double v) {
      if (v < 0.9) return 0.9;
      if (v > 1.2) return 1.2;
      return (v * 10).round() / 10.0;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.text_fields, color: cs.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tamaño de texto',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Slider(
              value: value,
              min: 0.9,
              max: 1.2,
              divisions: 3,
              onChanged: (v) => onChanged(clamp(v)),
            ),
            const Text(
              'Ajusta la legibilidad en toda la aplicación.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLinksCard extends StatelessWidget {
  final VoidCallback onOpenWeb;
  final VoidCallback onOpenFacebook;
  final VoidCallback onOpenInstagram;

  const _SocialLinksCard({
    required this.onOpenWeb,
    required this.onOpenFacebook,
    required this.onOpenInstagram,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget iconBtn(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withOpacity(0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        iconBtn(Icons.language, 'Web', onOpenWeb),
        const SizedBox(width: 10),
        iconBtn(Icons.facebook, 'Facebook', onOpenFacebook),
        const SizedBox(width: 10),
        iconBtn(Icons.camera_alt_outlined, 'Instagram', onOpenInstagram),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.logout, color: cs.primary),
      label: const Text('Cerrar sesión'),
    );
  }
}
