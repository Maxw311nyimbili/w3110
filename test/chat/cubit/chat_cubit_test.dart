// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cap_project/chat/cubit/cubit.dart';

void main() {
  group('ChatCubit', () {
    group('constructor', () {
      test('can be instantiated', () {
        expect(
          ChatCubit(),
          isNotNull,
        );
      });
    });

    test('initial state has default value for customProperty', () {
      final chatCubit = ChatCubit();
      expect(chatCubit.state.customProperty, equals('Default Value'));
    });

    blocTest<ChatCubit, ChatState>(
      'yourCustomFunction emits nothing',
      build: ChatCubit.new,
      act: (cubit) => cubit.yourCustomFunction(),
      expect: () => <ChatState>[],
    );
  });
}
