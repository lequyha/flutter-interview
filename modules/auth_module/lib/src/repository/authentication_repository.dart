import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:auth_module/src/exceptions/login_in_with_facebook_failure.dart';
import 'package:crypto/crypto.dart';
import 'package:auth_module/src/cache/cache.dart';
import 'package:auth_module/src/exceptions/login_in_with_google_failure.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_module/user_module.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final CacheClient _cache;
  final FacebookAuth _facebookSignIn;

  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookSignIn,
  }) : _cache = cache ?? CacheClient(),
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
       _facebookSignIn = facebookSignIn ?? FacebookAuth.instance;

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  static const userCacheKey = '__user_cache_key__';

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthenticationStatus.authenticated),
    );
  }

  Future<void> logOut() async {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();

  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      _controller.add(AuthenticationStatus.authenticated);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code).message;
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  Future<void> logInWithFacebook() async {
    try {
      final oauthCredential = await signInWithFacebook();
      await _firebaseAuth.signInWithCredential(oauthCredential);
      _controller.add(AuthenticationStatus.authenticated);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithFacebookFailure.fromCode(e.code).message;
    } catch (_) {
      throw const LogInWithFacebookFailure();
    }
  }

  Future<firebase_auth.OAuthCredential> signInWithFacebook() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);
    final result = await _facebookSignIn.login(nonce: nonce);

    final accessToken = result.accessToken;
    if (accessToken == null) {
      throw Exception('Login cancelled');
    }

    if (accessToken.type == AccessTokenType.limited) {
      return firebase_auth.OAuthProvider(
        'facebook.com',
      ).credential(idToken: accessToken.tokenString, rawNonce: rawNonce);
    } else {
      return firebase_auth.FacebookAuthProvider.credential(
        accessToken.tokenString,
      );
    }
  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
