// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cap_project/features/medscanner/medscanner.dart';
import 'package:cap_project/features/medscanner/view/medscanner_page.dart';
import 'package:cap_project/features/medscanner/widgets/medscanner_body.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MedscannerPage', () {
    group('route', () {
      test('is routable', () {
        expect(MedscannerPage.route(), isA<MaterialPageRoute>());
      });
    });

    testWidgets('renders MedscannerView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: MedscannerPage()));
      expect(find.byType(MedscannerView), findsOneWidget);
    });
  });
}
