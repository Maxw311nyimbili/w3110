import 'package:auth_repository/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group('AuthCubit', () {
    test('initial state is unauthenticated', () {
      final cubit = AuthCubit(authRepository: authRepository);
      expect(cubit.state.status, AuthStatus.initial);
    });

    blocTest<AuthCubit, AuthState>(
      'signInWithGoogle emits authenticated when successful',
      build: () {
        when(
          () => authRepository.signInWithGoogleFirebase(),
        ).thenAnswer((_) async => 'mock_id_token');
        when(() => authRepository.exchangeIdToken(any())).thenAnswer(
          (_) async => AuthTokens(
            accessToken: 'abc123',
            refreshToken: 'xyz789',
          ),
        );
        when(() => authRepository.saveTokens(any())).thenAnswer((_) async {});
        when(
          () => authRepository.getCurrentUser(),
        ).thenAnswer((_) async => User(id: '1', email: 'test@test.com'));
        return AuthCubit(authRepository: authRepository);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        AuthState(
          status: AuthStatus.authenticated,
          user: User(id: '1', email: 'test@test.com'),
        ),
      ],
    );
  });
}
