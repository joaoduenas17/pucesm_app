import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pucesm_app/screens/home/home_screen.dart';

void main() {
  testWidgets('las secciones de inicio se recorren horizontalmente', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var selected = HomeSection.noticias;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setState) {
                return HomeSectionTabs(
                  selected: selected,
                  onChanged: (value) {
                    setState(() => selected = value);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    final tabs = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    expect(tabs, findsOneWidget);

    final initialPosition = tester.getCenter(find.text('PUCE TEC')).dx;
    await tester.drag(tabs, const Offset(-220, 0));
    await tester.pumpAndSettle();

    final visibleTab = find.text('PUCE TEC').hitTestable();
    expect(visibleTab, findsOneWidget);
    expect(
      tester.getCenter(find.text('PUCE TEC')).dx,
      lessThan(initialPosition),
    );

    await tester.tap(visibleTab);
    await tester.pump();
    expect(selected, HomeSection.pucetec);
    expect(tester.takeException(), isNull);
  });
}
