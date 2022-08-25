import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String displayName;
  final String email;
  const User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.displayName,
    required this.email,
    this.deletedAt
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json.containsKey('deletedAt') &&
          json['deletedAt'] != null &&
          json['deletedAt']['Valid']
          ? DateTime.parse(json['deletedAt'])
          : null,
      name: json.containsKey('name') ? json['name'] ?? '' : '',
      displayName: json['displayName'],
      email: json.containsKey('email') ? json['email'] ?? '' : ''
    );
  }
}

class UserService {
  static bool _isOnboarded = false;
  static isOnboarded() {
    return _isOnboarded;
  }
  static Future<User?> me() async {
    var token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token == null) {
      return null;
    }
    final response = await http.get(
        Uri.parse('//convention.ninja/api/users/me'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if(response.statusCode >= 200 && response.statusCode < 300) {
      _isOnboarded = true;
      return User.fromJson(jsonDecode(response.body));
    }
    _isOnboarded = false;
    return null;
  }

  static Future<User?> onboard(String name, String email, String? displayName) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.post(
        Uri.parse('//convention.ninja/api/users'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }, body: jsonEncode(<String, String>{
      'name': name,
      'email': email,
      'displayName': displayName ?? ''
    }));
    if(response.statusCode >= 200 && response.statusCode < 300) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}