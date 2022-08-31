import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_repository/src/category/models/models.dart';
import 'dart:convert';

class CategoryRepository {
  CategoryRepository({required authRepo, CacheClient? cache})
      : _authRepo = authRepo,
        _cache = cache ?? CacheClient();
  final AuthenticationRepository _authRepo;
  final CacheClient _cache;

  List<Category>? getCategoriesCached(String orgId) {
    var isCached = _cache.read<bool>(key: '__category_all_${orgId}_cached__');
    if(isCached == true) {
      return _cache
          .readAll<Category>()
          .where((element) => element.organizationId == orgId)
          .toList();
    }
    return null;
  }

  Future<List<Category>> getCategories(String orgId,
      {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }

    var isCached = _cache.read<bool>(key: '__category_all_${orgId}_cached__');
    if (isCached == true && !skipCache) {
      return _cache
          .readAll<Category>()
          .where((element) => element.organizationId == orgId)
          .toList();
    }

    var token = await _authRepo.currentUser.idToken;
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
          var cat = Category.fromJson(value);
          _cache.write(
              key: cat.id, value: cat, lifetime: Duration(minutes: 15));
          ret.add(cat);
        }
        _cache.write(
            key: '__category_all_${orgId}_cached__',
            value: true,
            lifetime: Duration(minutes: 14));
        return ret;
      }
    }
    return [];
  }

  Future<Category?> createCategory(String orgId, String name) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(CreateCategoryRequest(name).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var cat = Category.fromJson(jsonDecode(response.body));
      _cache.write(key: cat.id, value: cat, lifetime: Duration(minutes: 15));
      return cat;
    }
    return null;
  }

  Future<Category?> updateCategory(
      String orgId, String categoryId, String name) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.put(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(UpdateCategoryRequest(name).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var cat = Category.fromJson(jsonDecode(response.body));
      _cache.write(key: cat.id, value: cat, lifetime: Duration(minutes: 15));
      return cat;
    }
    return null;
  }

  Future<bool> deleteCategory(String orgId, String categoryId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _cache.invalidate(key: categoryId);
      return true;
    }
    return false;
  }
}
