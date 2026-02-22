// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cap_project/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBody', () {
    testWidgets('renders Text', (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (context) => AuthCubit(),
          child: MaterialApp(home: AuthBody()),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
