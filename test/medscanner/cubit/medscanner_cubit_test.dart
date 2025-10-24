// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cap_project/medscanner/cubit/cubit.dart';

void main() {
  group('MedscannerCubit', () {
    group('constructor', () {
      test('can be instantiated', () {
        expect(
          MedscannerCubit(),
          isNotNull,
        );
      });
    });

    test('initial state has default value for customProperty', () {
      final medscannerCubit = MedscannerCubit();
      expect(medscannerCubit.state.customProperty, equals('Default Value'));
    });

    blocTest<MedscannerCubit, MedscannerState>(
      'yourCustomFunction emits nothing',
      build: MedscannerCubit.new,
      act: (cubit) => cubit.yourCustomFunction(),
      expect: () => <MedscannerState>[],
    );
  });
}
