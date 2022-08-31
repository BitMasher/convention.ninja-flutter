import 'dart:async';

import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/api_user.dart';
import 'models/models.dart';

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class LogInWithGoogleFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The associated error message.
  final String message;
}

class LogInWithFacebookFailure implements Exception {
  const LogInWithFacebookFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithFacebookFailure.fromCode(String code) {
    return LogInWithFacebookFailure(
      code,
    );
  }

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

class AuthenticationRepository {
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) {
    this._cache = cache ?? CacheClient();
    this._firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;
    this._updateStream = StreamController<User>();
    this._fbUserStream =
        _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      var user = firebaseUser == null ? User.empty : firebaseUser.toUser(null);
      if (user != User.empty) {
        var token = await user.idToken;
        final response = await http
            .get(Uri.parse('//convention.ninja/api/users/me'), headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
        if (response.statusCode >= 200 && response.statusCode < 300) {
          user =
              firebaseUser!.toUser(ApiUser.fromJson(jsonDecode(response.body)));
        }
      }
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
    _fbUserStream.listen((event) {
      _updateStream.add(event);
    });
  }

  late final CacheClient _cache;
  late final firebase_auth.FirebaseAuth _firebaseAuth;
  late final Stream<User> _fbUserStream;
  late final StreamController<User> _updateStream;

  static const userCacheKey = '__user_cache_key__';

  Stream<User> get user {
    return _updateStream.stream;
  }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  Future<void> logInWithGoogle() async {
    try {
      final googleProvider = firebase_auth.GoogleAuthProvider();
      var userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (e) {
      throw LogInWithGoogleFailure(e.toString());
    }
  }

  Future<void> logInWithFacebook() async {
    try {
      late final firebase_auth.AuthCredential credential;
      final facebookProvider = firebase_auth.FacebookAuthProvider();
      final userCredential =
          await _firebaseAuth.signInWithPopup(facebookProvider);
      credential = userCredential.credential!;
      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithFacebookFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithFacebookFailure();
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw LogOutFailure();
    }
  }

  Future<bool> onboard(String name, String email, String? displayName) async {
    if (this.currentUser == User.empty) {
      return false;
    }
    var token = await this.currentUser.idToken;
    final response = await http.post(Uri.parse('//convention.ninja/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'displayName': displayName ?? ''
        }));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var apiUser = ApiUser.fromJson(jsonDecode(response.body));
      _updateStream.add(this._firebaseAuth.currentUser!.toUser(apiUser));
      return true;
    }
    return false;
  }
}

extension on firebase_auth.User {
  User toUser(ApiUser? apiUser) {
    return User(
        id: uid,
        email: email,
        name: displayName,
        photo: photoURL,
        fbUser: this,
        apiUser: apiUser);
  }
}
