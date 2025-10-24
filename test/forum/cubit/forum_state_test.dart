// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:cap_project/forum/cubit/cubit.dart';

void main() {
  group('ForumState', () {
    test('supports value equality', () {
      expect(
        ForumState(),
        equals(
          const ForumState(),
        ),
      );
    });

    group('constructor', () {
      test('can be instantiated', () {
        expect(
          const ForumState(),
          isNotNull,
        );
      });
    });

    group('copyWith', () {
      test(
        'copies correctly '
        'when no argument specified',
        () {
          const forumState = ForumState(
            customProperty: 'My property',
          );
          expect(
            forumState.copyWith(),
            equals(forumState),
          );
        },
      );

      test(
        'copies correctly '
        'when all arguments specified',
        () {
          const forumState = ForumState(
            customProperty: 'My property',
          );
          final otherForumState = ForumState(
            customProperty: 'My property 2',
          );
          expect(forumState, isNot(equals(otherForumState)));

          expect(
            forumState.copyWith(
              customProperty: otherForumState.customProperty,
            ),
            equals(otherForumState),
          );
        },
      );
    });
  });
}
