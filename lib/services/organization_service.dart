import 'dart:convert';
import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class Organization {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String ownerId;

  const Organization({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.ownerId,
    this.deletedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        deletedAt: json.containsKey('deletedAt') &&
                json['deletedAt'] != null &&
                json['deletedAt']['Valid']
            ? DateTime.parse(json['deletedAt'])
            : null,
        name: json['name'],
        ownerId: json['ownerId']);
  }
}

class OrganizationService {
  static Future<Organization?> get(String id) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response =
        await http.get(Uri.parse('//convention.ninja/api/orgs/$id'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Organization.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<List<Organization>> getAll() async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response =
        await http.get(Uri.parse('//convention.ninja/api/orgs'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Organization>[];
        for (var value in arr) {
          ret.add(Organization.fromJson(value));
        }
        return ret;
      }
    }

    return [];
  }
}
