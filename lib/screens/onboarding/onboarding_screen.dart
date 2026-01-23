import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StudyLevel { grado, posgrado }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _saving = false;

  StudyLevel _level = StudyLevel.grado;
  String? _selectedProgram;

  // ✅ Usa tu lista REAL (la que me pasaste)
  static const List<String> _gradoPrograms = [
    'Administración de Empresas',
    'Arquitectura',
    'Biología Marina',
    'Derecho',
    'Diseño Gráfico',
    'Enfermería',
    'Fisioterapia',
    'Ingeniería Civil',
    'Ingeniería en Alimentos',
    'Medicina',
    'Negocios Internacionales',
    'Nutrición y Dietética',
    'Psicología Clínica',
    'Software',
  ];

  // ✅ Posgrado: déjalo por ahora con ejemplos (luego lo conectamos al backend)
  static const List<String> _posgradoPrograms = [
    'Especialización en Salud y Seguridad Ocupacional',
    'Maestría en Derecho Constitucional',
    'Maestría en Derecho Penal',
    'Maestría en Geotecnia Aplicada',
    'Maestría en Hidráulica mención Gestión de Recursos Hídricos',
    'Maestría en Ingeniería Civil mención Estructuras Sismorresistentes',
    'Maestría en Innovación en Educación',
  ];

  List<String> get _currentPrograms =>
      _level == StudyLevel.grado ? _gradoPrograms : _posgradoPrograms;

  @override
  void initState() {
    super.initState();
    // defaults
    _selectedProgram = _currentPrograms.isNotEmpty ? _currentPrograms.first : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onLevelChanged(StudyLevel v) {
    setState(() {
      _level = v;
      final list = _currentPrograms;
      if (_selectedProgram == null || !list.contains(_selectedProgram)) {
        _selectedProgram = list.isNotEmpty ? list.first : null;
      }
    });
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu carrera/programa.')),
      );
      return;
    }

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameCtrl.text.trim());
    await prefs.setString('profile_email', _emailCtrl.text.trim());
    await prefs.setString('profile_level', _level == StudyLevel.grado ? 'grado' : 'posgrado');
    await prefs.setString('profile_program', _selectedProgram!);

    // ✅ bandera onboarding
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;
    setState(() => _saving = false);

    // ✅ manda al home (ajusta ruta a la tuya)
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.18),
                    cs.primary.withOpacity(0.06),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bienvenido a PUCESM App 👋',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Antes de empezar, configure estas opciones para personalizar noticias, carreras y recordatorios.',
                    style: TextStyle(color: Color(0xFF5B6472), height: 1.25),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Ingresa tu nombre';
                      if (t.length < 3) return 'Nombre demasiado corto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Ingresa tu correo';
                      if (!t.contains('@')) return 'Correo no válido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _BlockTitle(title: 'Nivel'),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _Pill(
                        label: 'Grado',
                        icon: Icons.school_outlined,
                        active: _level == StudyLevel.grado,
                        onTap: () => _onLevelChanged(StudyLevel.grado),
                      ),
                      const SizedBox(width: 10),
                      _Pill(
                        label: 'Posgrado',
                        icon: Icons.workspace_premium_outlined,
                        active: _level == StudyLevel.posgrado,
                        onTap: () => _onLevelChanged(StudyLevel.posgrado),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _BlockTitle(
                    title: _level == StudyLevel.grado ? 'Carrera (Grado)' : 'Programa (Posgrado)',
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _selectedProgram,
                    items: _currentPrograms
                        .map((p) => DropdownMenuItem<String>(
                              value: p,
                              child: Text(p, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProgram = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school_outlined),
                      labelText: 'Seleccionar',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Selecciona una opción' : null,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(_saving ? 'Guardando...' : 'Empezar'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Podrás cambiar esto luego en Perfil → Editar perfil.',
                    style: TextStyle(color: cs.primary.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  final String title;
  const _BlockTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
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

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: active ? cs.primary.withOpacity(0.14) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? cs.primary.withOpacity(0.45) : const Color(0x1A000000),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? cs.primary : const Color(0xFF5B6472)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? cs.primary : const Color(0xFF5B6472),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
