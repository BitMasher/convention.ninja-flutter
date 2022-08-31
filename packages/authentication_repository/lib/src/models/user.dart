import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;

import 'api_user.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    fbUser,
    email,
    name,
    this.photo,
    apiUser
  }) : _fbUser = fbUser, _apiUser = apiUser, _email = email, _name = name;

  /// The current user's email address.
  String? get email => _apiUser?.email ?? _email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  String? get name => _apiUser?.name ?? _name;
  String? get displayName => _apiUser?.displayName;

  final String? _name;
  final String? _email;

  /// Url for the current user's photo.
  final String? photo;

  final fba.User? _fbUser;
  final ApiUser? _apiUser;

  Future<String?> get idToken async => await _fbUser!.getIdToken();

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  bool get isOnboarded => this._apiUser != null;

  @override
  List<Object?> get props => [email, id, name, photo];
}