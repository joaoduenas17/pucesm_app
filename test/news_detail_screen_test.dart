import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pucesm_app/models/news_item.dart';
import 'package:pucesm_app/screens/news/news_detail_screen.dart';

void main() {
  testWidgets('el detalle de noticia se adapta a una pantalla pequeña', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final item = NewsItem(
      id: 1,
      title: 'Una noticia institucional con un título suficientemente extenso',
      predescription: 'Resumen de la noticia.',
      descriptionHtml: '''
        <p>Contenido adaptable para pantallas pequeñas.</p>
        <p>Segundo párrafo con información académica para comprobar el desplazamiento.</p>
        <ul><li>Primer punto</li><li>Segundo punto</li></ul>
      ''',
      imageName: '',
      urlSlug: '/prueba-responsive',
      dateCreated: DateTime(2026, 8, 18, 10, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(1.3),
          ),
          child: NewsDetailScreen(item: item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(item.title), findsOneWidget);
    expect(find.text('Ver en la web'), findsOneWidget);
    expect(find.text('Sitio PUCE'), findsOneWidget);
    expect(
      find.text('Contenido adaptable para pantallas pequeñas.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Redes oficiales'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Redes oficiales'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
