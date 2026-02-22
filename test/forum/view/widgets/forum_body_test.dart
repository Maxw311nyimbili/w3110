// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cap_project/forum/forum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForumBody', () {
    testWidgets('renders Text', (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (context) => ForumCubit(),
          child: MaterialApp(home: ForumBody()),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
