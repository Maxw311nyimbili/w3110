// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cap_project/forum/forum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForumPage', () {
    group('route', () {
      test('is routable', () {
        expect(ForumPage.route(), isA<MaterialPageRoute>());
      });
    });

    testWidgets('renders ForumView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: ForumPage()));
      expect(find.byType(ForumView), findsOneWidget);
    });
  });
}
