import '../models/calendar_event.dart';

// Fechas publicadas en el Calendario Académico 2026 de la sede Manabí.
// El inicio de 2026-2 proviene del aviso institucional vigente.
final academicCalendarEvents = <CalendarEvent>[
  CalendarEvent.academic(
    category: CalendarCategory.institucional,
    title: 'Inicio de la gestión académica y administrativa',
    start: DateTime(2026, 1, 5),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Primer examen de aptitud académica',
    start: DateTime(2026, 1, 30),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Segundo examen de aptitud académica',
    start: DateTime(2026, 2, 13),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.institucional,
    title: 'Feriado de Carnaval',
    start: DateTime(2026, 2, 16),
    end: DateTime(2026, 2, 17),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Periodo académico extraordinario',
    start: DateTime(2026, 2, 16),
    end: DateTime(2026, 3, 1),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Registro de calificaciones',
    start: DateTime(2026, 2, 16),
    end: DateTime(2026, 2, 26),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Matrícula ordinaria de décimo semestre de Medicina',
    start: DateTime(2026, 2, 18),
    end: DateTime(2026, 3, 4),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Matrícula ordinaria de séptimo semestre de Enfermería e internado',
    start: DateTime(2026, 2, 23),
    end: DateTime(2026, 3, 4),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.institucional,
    title: 'Solicitud de becas',
    start: DateTime(2026, 2, 26),
    end: DateTime(2026, 3, 13),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Tercer examen de aptitud académica',
    start: DateTime(2026, 2, 27),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Periodo académico extraordinario, incluida Medicina',
    start: DateTime(2026, 3, 2),
    end: DateTime(2026, 4, 17),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Inicio de clases de décimo semestre de Medicina',
    start: DateTime(2026, 3, 9),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Cuarto examen de aptitud académica',
    start: DateTime(2026, 3, 13),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.pucetecGrado,
    title: 'Matrícula ordinaria del periodo académico 2026-1',
    start: DateTime(2026, 3, 16),
    end: DateTime(2026, 4, 3),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Quinto examen de aptitud académica',
    start: DateTime(2026, 3, 18),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Inicio de clases de séptimo semestre de Enfermería',
    start: DateTime(2026, 3, 23),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.pucetecGrado,
    title: 'Curso de nivelación y preparatorio de Medicina',
    start: DateTime(2026, 3, 23),
    end: DateTime(2026, 4, 10),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Sexto examen de aptitud académica',
    start: DateTime(2026, 4, 2),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.institucional,
    title: 'Feriado de Viernes Santo',
    start: DateTime(2026, 4, 3),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.pucetecGrado,
    title: 'Matrícula extraordinaria del periodo académico 2026-1',
    start: DateTime(2026, 4, 8),
    end: DateTime(2026, 4, 24),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.grado,
    title: 'Séptimo examen de aptitud académica',
    start: DateTime(2026, 4, 17),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.institucional,
    title: 'Jornadas de inducción',
    start: DateTime(2026, 4, 23),
    end: DateTime(2026, 4, 24),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.pucetecGrado,
    title: 'Inicio de clases del periodo académico 2026-1',
    start: DateTime(2026, 4, 27),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.posgrado,
    title: 'Inicio de clases de programas de posgrado',
    start: DateTime(2026, 4, 27),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.pucetecGrado,
    title: 'Matrícula especial del periodo académico 2026-1',
    start: DateTime(2026, 4, 29),
    end: DateTime(2026, 5, 8),
  ),
  CalendarEvent.academic(
    category: CalendarCategory.institucional,
    title: 'Inicio de clases del periodo académico 2026-2',
    start: DateTime(2026, 10, 19),
  ),
];
