import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../data/study_programs.dart';
import '../../models/user_profile.dart';
import '../../widgets/study_level_selector.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _saving = false;
  bool _initialized = false;

  StudyLevel _level = StudyLevel.grado;
  String? _selectedProgram;

  List<String> get _currentPrograms => StudyPrograms.forLevel(_level);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final state = context.read<AppState>();
    _nameCtrl.text = state.profileName;
    _emailCtrl.text = state.profileEmail;
    _level = state.studyLevel;
    _selectedProgram = _currentPrograms.contains(state.profileProgram)
        ? state.profileProgram
        : StudyPrograms.defaultFor(_level);
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
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

    await context.read<AppState>().updateProfile(
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      level: _level,
      program: _selectedProgram!,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  void _onLevelChanged(StudyLevel value) {
    setState(() {
      _level = value;

      final list = _currentPrograms;
      if (_selectedProgram == null || !list.contains(_selectedProgram)) {
        _selectedProgram = list.isNotEmpty ? list.first : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Configura tus preferencias para personalizar el contenido mostrado en la aplicación.',
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.25),
            ),
          ),
          const SizedBox(height: 14),

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
                    if (t.isEmpty) return 'Ingresa un nombre';
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
                    if (t.isEmpty) return 'Ingresa un correo';
                    if (!t.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                const _BlockTitle(title: 'Nivel'),
                const SizedBox(height: 10),

                StudyLevelSelector(value: _level, onChanged: _onLevelChanged),

                const SizedBox(height: 16),

                _BlockTitle(
                  title: switch (_level) {
                    StudyLevel.grado => 'Carrera (Grado)',
                    StudyLevel.posgrado => 'Programa (Posgrado)',
                    StudyLevel.pucetec => 'Carrera tecnológica (PUCE TEC)',
                  },
                ),
                const SizedBox(height: 10),

                // ✅ FIX OVERFLOW: isExpanded + selectedItemBuilder
                DropdownButtonFormField<String>(
                  key: ValueKey(_level),
                  initialValue: _selectedProgram,
                  isExpanded: true, // ✅ CLAVE para que no se desborde
                  items: _currentPrograms
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: p,
                          child: Text(p, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) {
                    return _currentPrograms.map((p) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          p,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (v) => setState(() => _selectedProgram = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined),
                    labelText: 'Seleccionar',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Selecciona una opción';
                    }
                    return null;
                  },
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
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
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
