// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:cap_project/chat/cubit/cubit.dart';

void main() {
  group('ChatState', () {
    test('supports value equality', () {
      expect(
        ChatState(),
        equals(
          const ChatState(),
        ),
      );
    });

    group('constructor', () {
      test('can be instantiated', () {
        expect(
          const ChatState(),
          isNotNull,
        );
      });
    });

    group('copyWith', () {
      test(
        'copies correctly '
        'when no argument specified',
        () {
          const chatState = ChatState(
            customProperty: 'My property',
          );
          expect(
            chatState.copyWith(),
            equals(chatState),
          );
        },
      );

      test(
        'copies correctly '
        'when all arguments specified',
        () {
          const chatState = ChatState(
            customProperty: 'My property',
          );
          final otherChatState = ChatState(
            customProperty: 'My property 2',
          );
          expect(chatState, isNot(equals(otherChatState)));

          expect(
            chatState.copyWith(
              customProperty: otherChatState.customProperty,
            ),
            equals(otherChatState),
          );
        },
      );
    });
  });
}
