import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../data/study_programs.dart';
import '../../models/user_profile.dart';
import '../../widgets/study_level_selector.dart';

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

  List<String> get _currentPrograms => StudyPrograms.forLevel(_level);

  @override
  void initState() {
    super.initState();
    _selectedProgram = StudyPrograms.defaultFor(_level);
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
        const SnackBar(content: Text('Selecciona tu carrera o programa.')),
      );
      return;
    }

    setState(() => _saving = true);

    await context.read<AppState>().completeOnboarding(
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      level: _level,
      program: _selectedProgram!,
    );

    if (!mounted) return;
    setState(() => _saving = false);

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
            const _OnboardingLogo(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.18),
                    cs.primary.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido a PUCE Manabí App 👋',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Antes de empezar, configure estas opciones para personalizar noticias, carreras y recordatorios.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.25),
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

                  StudyLevelSelector(value: _level, onChanged: _onLevelChanged),

                  const SizedBox(height: 18),

                  _BlockTitle(
                    title: switch (_level) {
                      StudyLevel.grado => 'Carrera (Grado)',
                      StudyLevel.posgrado => 'Programa (Posgrado)',
                      StudyLevel.pucetec => 'Carrera tecnológica (PUCE TEC)',
                    },
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    key: ValueKey(_level),
                    initialValue: _selectedProgram,
                    isExpanded: true,
                    items: _currentPrograms
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p,
                            child: Text(p, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProgram = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school_outlined),
                      labelText: 'Seleccionar',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Selecciona una opción'
                        : null,
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
                    style: TextStyle(color: cs.primary.withValues(alpha: 0.75)),
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

class _OnboardingLogo extends StatelessWidget {
  const _OnboardingLogo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 124,
        height: 124,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Image.asset(
          'assets/icon/logo_puce.png',
          fit: BoxFit.contain,
          semanticLabel: 'Logo de PUCE Manabí',
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
          color: cs.primary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
