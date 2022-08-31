import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_repository/src/manufacturer/models/models.dart';
import 'dart:convert';

class ManufacturerRepository {
  ManufacturerRepository({required authRepo, CacheClient? cache})
      : _authRepo = authRepo,
        _cache = cache ?? CacheClient();
  final AuthenticationRepository _authRepo;
  final CacheClient _cache;

  List<Manufacturer>? getManufacturersCached(String orgId) {
    var isCached =
        _cache.read<bool>(key: '__manufacturer_all_${orgId}_cached__');
    if (isCached == true) {
      return _cache
          .readAll<Manufacturer>()
          .where((element) => element.organizationId == orgId)
          .toList();
    }
    return null;
  }

  Future<List<Manufacturer>> getManufacturers(String orgId,
      {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }

    var isCached =
        _cache.read<bool>(key: '__manufacturer_all_${orgId}_cached__');
    if (isCached == true && !skipCache) {
      return _cache
          .readAll<Manufacturer>()
          .where((element) => element.organizationId == orgId)
          .toList();
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/manufacturers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Manufacturer>[];
        for (var value in arr) {
          var mfg = Manufacturer.fromJson(value);
          _cache.write(
              key: mfg.id, value: mfg, lifetime: Duration(minutes: 15));
          ret.add(mfg);
        }
        _cache.write(
            key: '__manufacturer_all_${orgId}_cached__',
            value: true,
            lifetime: Duration(minutes: 14));
        return ret;
      }
    }
    return [];
  }

  Future<Manufacturer?> createManufacturer(String orgId, String name) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/manufacturers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(CreateManufacturerRequest(name).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var mfg = Manufacturer.fromJson(jsonDecode(response.body));
      _cache.write(key: mfg.id, value: mfg, lifetime: Duration(minutes: 15));
      return mfg;
    }
    return null;
  }

  Future<Manufacturer?> updateManufacturer(
      String orgId, String manufacturerId, String name) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.put(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manufacturers/$manufacturerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(UpdateManufacturerRequest(name).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var mfg = Manufacturer.fromJson(jsonDecode(response.body));
      _cache.write(key: mfg.id, value: mfg, lifetime: Duration(minutes: 15));
      return mfg;
    }
    return null;
  }

  Future<bool> deleteManufacturer(String orgId, String manufacturerId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manufacturers/$manufacturerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _cache.invalidate(key: manufacturerId);
      return true;
    }
    return false;
  }
}
