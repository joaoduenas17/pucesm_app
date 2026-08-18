import 'package:flutter_test/flutter_test.dart';

import 'package:pucesm_app/models/course_item.dart';
import 'package:pucesm_app/models/news_item.dart';

void main() {
  test('NewsItem tolera identificadores numéricos en texto', () {
    final item = NewsItem.fromJson({
      'id': '42',
      'title': 'Noticia',
      'date_created': '2026-08-17 10:30:00',
    });

    expect(item.id, 42);
    expect(item.title, 'Noticia');
    expect(item.dateCreated, DateTime(2026, 8, 17, 10, 30));
  });

  test('CourseItem normaliza números y booleanos del API', () {
    final item = CourseItem.fromJson({
      'id': '7',
      'title': 'Software',
      'views': '125',
      'id_type': '1',
      'price': '99.50',
      'active': 1,
      'acordions_course': <dynamic>[],
    });

    expect(item.id, 7);
    expect(item.views, 125);
    expect(item.idType, 1);
    expect(item.price, 99.5);
    expect(item.active, isTrue);
  });
}
