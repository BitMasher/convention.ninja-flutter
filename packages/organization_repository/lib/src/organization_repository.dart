import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';

import 'models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateOrganizationConflict implements Exception {
  const CreateOrganizationConflict([
    this.message = 'Organization name is already in use.'
  ]);
  final String message;
}

class OrganizationRepository {
  OrganizationRepository({required authRepo, CacheClient? cache})
      : _authRepo = authRepo,
        _cache = cache ?? CacheClient();
  final AuthenticationRepository _authRepo;
  final CacheClient _cache;

  Future<Organization?> create(String name) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(Uri.parse('//convention.ninja/api/orgs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(CreateOrganizationRequest(name).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var org = Organization.fromJson(jsonDecode(response.body));
      _cache.write(key: org.id, value: org, lifetime: Duration(days: 1));
      return org;
    } else if(response.statusCode == 409) {
      throw CreateOrganizationConflict();
    }
    return null;
  }

  Organization? getCached(String id) {
    return _cache.read<Organization>(key: id);
  }

  Future<Organization?> get(String id, {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var org = _cache.read<Organization>(key: id);
    if (!skipCache && org != null) return org;
    var token = await _authRepo.currentUser.idToken;
    final response =
        await http.get(Uri.parse('//convention.ninja/api/orgs/$id'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      org = Organization.fromJson(jsonDecode(response.body));
      _cache.write(key: org.id, value: org, lifetime: Duration(days: 1));
      return org;
    }
    return null;
  }

  List<Organization>? getAllCached() {
    var isCached = _cache.read<bool>(key: '__org_all_cached__');
    if (isCached == true) {
      return _cache.readAll<Organization>();
    }
    return null;
  }

  Future<List<Organization>> getAll({bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }
    var isCached = _cache.read<bool>(key: '__org_all_cached__');
    if (isCached == true && !skipCache) {
      return _cache.readAll<Organization>();
    }
    var token = await _authRepo.currentUser.idToken;
    final response =
        await http.get(Uri.parse('//convention.ninja/api/orgs'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Organization>[];
        for (var value in arr) {
          var org = Organization.fromJson(value);
          _cache.write(key: org.id, value: org, lifetime: Duration(days: 1));
          ret.add(org);
        }
        _cache.write(
            key: '__org_all_cached__',
            value: true,
            lifetime: Duration(hours: 23));
        return ret;
      }
    }
    return [];
  }
}
