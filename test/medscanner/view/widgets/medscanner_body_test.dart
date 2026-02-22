// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cap_project/features/medscanner/medscanner.dart';
import 'package:cap_project/features/medscanner/widgets/medscanner_body.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MedscannerBody', () {
    testWidgets('renders Text', (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (context) => MedscannerCubit(),
          child: MaterialApp(home: MedscannerBody()),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
