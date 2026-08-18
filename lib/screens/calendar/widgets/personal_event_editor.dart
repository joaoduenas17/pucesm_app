import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/calendar_event.dart';

class PersonalEventDraft {
  final String title;
  final String? description;
  final DateTime start;
  final DateTime? end;

  const PersonalEventDraft({
    required this.title,
    required this.start,
    this.description,
    this.end,
  });
}

class PersonalEventEditor extends StatefulWidget {
  final CalendarEvent? existing;
  final DateTime initialDate;

  const PersonalEventEditor({
    super.key,
    required this.initialDate,
    this.existing,
  });

  @override
  State<PersonalEventEditor> createState() => _PersonalEventEditorState();
}

class _PersonalEventEditorState extends State<PersonalEventEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _start;
  DateTime? _end;
  late bool _hasEnd;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _start = dateOnly(existing?.start ?? widget.initialDate);
    _end = existing?.end == null ? null : dateOnly(existing!.end!);
    _hasEnd = _end != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Fecha del evento',
    );
    if (selected == null || !mounted) return;

    setState(() {
      _start = dateOnly(selected);
      if (_hasEnd && (_end == null || _end!.isBefore(_start))) {
        _end = _start;
      }
    });
  }

  Future<void> _pickEnd() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _end ?? _start,
      firstDate: _start,
      lastDate: DateTime(2100),
      helpText: 'Fecha final',
    );
    if (selected == null || !mounted) return;
    setState(() => _end = dateOnly(selected));
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final description = _descriptionController.text.trim();
    Navigator.pop(
      context,
      PersonalEventDraft(
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
        start: _start,
        end: _hasEnd ? (_end ?? _start) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_EC');

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.edit_calendar_outlined,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existing == null
                                ? 'Nuevo evento personal'
                                : 'Editar evento personal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Se guardará únicamente en esta aplicación.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titleController,
                  autofocus: widget.existing == null,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    final title = value?.trim() ?? '';
                    if (title.isEmpty) return 'Ingresa un título';
                    if (title.length < 3) return 'El título es muy corto';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                _DateTile(
                  label: 'Fecha',
                  value: dateFormat.format(_start),
                  onTap: _pickStart,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _hasEnd,
                  onChanged: (value) {
                    setState(() {
                      _hasEnd = value;
                      _end = value ? (_end ?? _start) : null;
                    });
                  },
                  secondary: const Icon(Icons.date_range_outlined),
                  title: const Text(
                    'Evento de varios días',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('Permite seleccionar una fecha final'),
                ),
                if (_hasEnd) ...[
                  const SizedBox(height: 4),
                  _DateTile(
                    label: 'Finaliza',
                    value: dateFormat.format(_end ?? _start),
                    onTap: _pickEnd,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          widget.existing == null ? 'Crear evento' : 'Guardar',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}
