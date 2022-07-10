import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class Category {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String organizationId;

  const Category(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.name,
      required this.organizationId,
      this.deletedAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        deletedAt: json.containsKey('deletedAt') &&
                json['deletedAt'] != null &&
                json['deletedAt']['Valid']
            ? DateTime.parse(json['deletedAt'])
            : null,
        name: json['name'],
        organizationId: json['organizationId']);
  }
}

class InventoryService {
  static Future<List<Category>> getCategories(String orgId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.get(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Category>[];
        for (var value in arr) {
          ret.add(Category.fromJson(value));
        }
        return ret;
      }
    }
    return [];
  }
}
