import 'package:flutter_test/flutter_test.dart';

import 'package:pucesm_app/utils/metric_logger.dart';

void main() {
  test('medir conserva el resultado de una operación asíncrona', () async {
    final resultado = await MetricLogger.medir('prueba_async', () async => 42);

    expect(resultado, 42);
  });

  test('medir propaga los errores de la operación original', () async {
    await expectLater(
      MetricLogger.medir<void>(
        'prueba_error',
        () async => throw StateError('fallo esperado'),
      ),
      throwsStateError,
    );
  });

  test('medirSync conserva el resultado de una operación síncrona', () {
    final resultado = MetricLogger.medirSync('prueba_sync', () => 'ok');

    expect(resultado, 'ok');
  });
}
