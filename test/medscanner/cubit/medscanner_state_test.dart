// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:cap_project/medscanner/cubit/cubit.dart';

void main() {
  group('MedscannerState', () {
    test('supports value equality', () {
      expect(
        MedscannerState(),
        equals(
          const MedscannerState(),
        ),
      );
    });

    group('constructor', () {
      test('can be instantiated', () {
        expect(
          const MedscannerState(),
          isNotNull,
        );
      });
    });

    group('copyWith', () {
      test(
        'copies correctly '
        'when no argument specified',
        () {
          const medscannerState = MedscannerState(
            customProperty: 'My property',
          );
          expect(
            medscannerState.copyWith(),
            equals(medscannerState),
          );
        },
      );

      test(
        'copies correctly '
        'when all arguments specified',
        () {
          const medscannerState = MedscannerState(
            customProperty: 'My property',
          );
          final otherMedscannerState = MedscannerState(
            customProperty: 'My property 2',
          );
          expect(medscannerState, isNot(equals(otherMedscannerState)));

          expect(
            medscannerState.copyWith(
              customProperty: otherMedscannerState.customProperty,
            ),
            equals(otherMedscannerState),
          );
        },
      );
    });
  });
}
