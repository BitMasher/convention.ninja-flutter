import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:inventory_repository/src/model/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateModelConflict implements Exception {
  const CreateModelConflict([this.message = 'Model already exists.']);

  final String message;
}

class ModelRepository {
  ModelRepository({required authRepo, CacheClient? cache})
      : this._authRepo = authRepo,
        _cache = cache ?? CacheClient();

  AuthenticationRepository _authRepo;
  CacheClient _cache;

  List<Model>? getModelsCached(String orgId) {
    var isCached = _cache.read<bool>(key: '__models_all_${orgId}_cached__');
    if (isCached == true) {
      return _cache
          .readAll<Model>()
          .where((e) => e.organizationId == orgId)
          .toList();
    }
    return null;
  }

  Future<List<Model>> getModels(String orgId, {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }

    var isCached = _cache.read<bool>(key: '__models_all_${orgId}_cached__');
    if (isCached == true && !skipCache) {
      return _cache
          .readAll<Model>()
          .where((e) => e.organizationId == orgId)
          .toList();
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/models'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Model>[];
        for (var value in arr) {
          var model = Model.fromJson(value);
          _cache.write(
              key: model.id, value: model, lifetime: Duration(minutes: 15));
          ret.add(model);
        }
        _cache.write(
            key: '__models_all_${orgId}_cached__',
            value: true,
            lifetime: Duration(minutes: 14));
        return ret;
      }
    }
    return [];
  }

  Future<Model?> createModel(String orgId, String name, String categoryId,
      String manufacturerId) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/models'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            CreateModelRequest(name, categoryId, manufacturerId).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var model = Model.fromJson(jsonDecode(response.body));
      _cache.write(
          key: model.id, value: model, lifetime: Duration(minutes: 15));
      return model;
    } else if (response.statusCode == 409) {
      throw CreateModelConflict();
    }
    return null;
  }

  Future<Model?> updateModel(String orgId, String modelId,
      {String? name, String? categoryId, String? manufacturerId}) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    var req = UpdateModelRequest(name, categoryId, manufacturerId);
    if (req.isEmpty) {
      return null;
    }
    final response = await http.patch(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/models/$modelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(req.toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var model = Model.fromJson(jsonDecode(response.body));
      _cache.write(
          key: model.id, value: model, lifetime: Duration(minutes: 15));
      return model;
    } else if (response.statusCode == 409) {
      throw CreateModelConflict();
    }
    return null;
  }

  Future<bool> deleteModel(String orgId, String modelId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/models/$modelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _cache.invalidate(key: modelId);
      return true;
    }
    return false;
  }
}
