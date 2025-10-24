// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cap_project/forum/cubit/cubit.dart';

void main() {
  group('ForumCubit', () {
    group('constructor', () {
      test('can be instantiated', () {
        expect(
          ForumCubit(),
          isNotNull,
        );
      });
    });

    test('initial state has default value for customProperty', () {
      final forumCubit = ForumCubit();
      expect(forumCubit.state.customProperty, equals('Default Value'));
    });

    blocTest<ForumCubit, ForumState>(
      'yourCustomFunction emits nothing',
      build: ForumCubit.new,
      act: (cubit) => cubit.yourCustomFunction(),
      expect: () => <ForumState>[],
    );
  });
}
