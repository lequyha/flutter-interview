// ignore_for_file: prefer_const_constructors

import 'package:auth_module/auth_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_module/user_module.dart';

class MockUser extends Mock implements User {}

void main() {
  group('AuthenticationState', () {
    group('AuthenticationState.unknown', () {
      test('supports value comparisons', () {
        expect(AuthenticationState.unknown(), AuthenticationState.unknown());
      });
    });

    group('AuthenticationState.authenticated', () {
      test('supports value comparisons', () {
        final user = MockUser();
        expect(
          AuthenticationState.authenticated(user),
          AuthenticationState.authenticated(user),
        );
      });
    });

    group('AuthenticationState.unauthenticated', () {
      test('supports value comparisons', () {
        expect(
          AuthenticationState.unauthenticated(),
          AuthenticationState.unauthenticated(),
        );
      });
    });
  });
}
