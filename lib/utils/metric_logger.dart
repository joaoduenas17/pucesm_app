import 'package:flutter/foundation.dart';

/// Instrumentación opcional para las pruebas técnicas de la tesis.
///
/// Está desactivada en compilaciones normales. Se habilita con:
/// `--dart-define=THESIS_METRICS=true`.
class MetricLogger {
  const MetricLogger._();

  static const habilitado = bool.fromEnvironment(
    'THESIS_METRICS',
    defaultValue: false,
  );
  static const dispositivo = String.fromEnvironment(
    'THESIS_DEVICE',
    defaultValue: 'sin_etiqueta',
  );
  static const repeticion = String.fromEnvironment(
    'THESIS_RUN',
    defaultValue: 'sin_etiqueta',
  );

  static Stopwatch? _inicioApp;
  static final Set<String> _metricasUnicas = <String>{};

  static void marcarInicioApp() {
    if (!habilitado) return;

    _metricasUnicas.clear();
    _inicioApp = Stopwatch()..start();
  }

  static void registrarDesdeInicio(String nombre, {bool unaSolaVez = true}) {
    final inicio = _inicioApp;
    if (!habilitado || inicio == null || !inicio.isRunning) return;
    if (unaSolaVez && !_metricasUnicas.add(nombre)) return;

    _registrar(nombre, inicio.elapsed, estado: 'ok');
  }

  static Future<T> medir<T>(String nombre, Future<T> Function() accion) {
    if (!habilitado) return accion();
    return _medirHabilitado(nombre, accion);
  }

  static Future<T> _medirHabilitado<T>(
    String nombre,
    Future<T> Function() accion,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final resultado = await accion();
      stopwatch.stop();
      _registrar(nombre, stopwatch.elapsed, estado: 'ok');
      return resultado;
    } catch (error) {
      stopwatch.stop();
      _registrar(
        nombre,
        stopwatch.elapsed,
        estado: 'error_${error.runtimeType}',
      );
      rethrow;
    }
  }

  static T medirSync<T>(String nombre, T Function() accion) {
    if (!habilitado) return accion();

    final stopwatch = Stopwatch()..start();
    try {
      final resultado = accion();
      stopwatch.stop();
      _registrar(nombre, stopwatch.elapsed, estado: 'ok');
      return resultado;
    } catch (error) {
      stopwatch.stop();
      _registrar(
        nombre,
        stopwatch.elapsed,
        estado: 'error_${error.runtimeType}',
      );
      rethrow;
    }
  }

  static void _registrar(
    String nombre,
    Duration duracion, {
    required String estado,
  }) {
    final milisegundos = duracion.inMicroseconds / 1000;
    debugPrint(
      '[TESIS_METRICA] '
      'dispositivo=$dispositivo '
      'repeticion=$repeticion '
      'metrica=$nombre '
      'duracion_ms=${milisegundos.toStringAsFixed(3)} '
      'estado=$estado',
    );
  }
}
