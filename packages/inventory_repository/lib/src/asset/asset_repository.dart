import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_repository/src/asset/models/models.dart';
import 'dart:convert';

class AssetRepository {
  AssetRepository({required authRepo, CacheClient? cache})
      : this._authRepo = authRepo,
        this._cache = cache ?? CacheClient();
  AuthenticationRepository _authRepo;
  CacheClient _cache;

  Future<Asset?> getAssetByTag(String orgId, String tagId,
      {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    if (!skipCache) {
      var tag = _cache.read<String>(key: '_tag_${orgId}_${tagId}');
      if (tag != null) {
        var asset = _cache.read<Asset>(key: tag);
        if (asset != null) {
          return asset;
        }
      }
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/barcode/$tagId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var asset = Asset.fromJson(jsonDecode(response.body));
      _cache.write(key: asset.id, value: asset, lifetime: Duration(minutes: 5));
      _cache.write(
          key: '_tag_${orgId}_${tagId}',
          value: asset.id,
          lifetime: Duration(minutes: 15));
      return asset;
    }
    return null;
  }

  Future<Asset?> getAsset(String orgId, String assetId,
      {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }

    if (!skipCache) {
      var asset = _cache.read<Asset>(key: assetId);
      if (asset != null) {
        return asset;
      }
    }

    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var asset = Asset.fromJson(jsonDecode(response.body));
      _cache.write(key: asset.id, value: asset, lifetime: Duration(minutes: 5));
      asset.assetTags.forEach((element) {
        _cache.write(
            key: "_tag_${orgId}_${element.tagId}",
            value: asset.id,
            lifetime: Duration(minutes: 15));
      });
      return asset;
    }
    return null;
  }

  List<Asset>? getAssetsCached(String orgId) {
    var isCached = _cache.read<bool>(key: '__assets_all_${orgId}_cached__');
    if (isCached == true) {
      return _cache
          .readAll<Asset>()
          .where((element) => element.organizationId == orgId)
          .toList();
    }
    return null;
  }

  Future<List<Asset>> getAssets(String orgId, {bool skipCache = false}) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }
    var isCached = _cache.read<bool>(key: '__assets_all_${orgId}_cached__');
    if (isCached == true && !skipCache) {
      return _cache
          .readAll<Asset>()
          .where((element) => element.organizationId == orgId)
          .toList();
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/assets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Asset>[];
        for (var value in arr) {
          var asset = Asset.fromJson(value);
          _cache.write(key: asset.id, value: asset, lifetime: Duration(minutes: 5));
          asset.assetTags.forEach((element) {
            _cache.write(
                key: "_tag_${orgId}_${element.tagId}",
                value: asset.id,
                lifetime: Duration(minutes: 15));
          });
          ret.add(asset);
        }
        _cache.write(key: '__assets_all_${orgId}_cached__', value: true, lifetime: Duration(minutes: 4));
        return ret;
      }
    }
    return [];
  }

  Future<Asset?> createAsset(String orgId, String modelId,
      String? serialNumber, List<String> tags) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/assets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(CreateAssetRequest(serialNumber, modelId, tags).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var asset = Asset.fromJson(jsonDecode(response.body));
      // _cache.write(key: asset.id, value: asset, lifetime: Duration(minutes: 5));
      var realAsset = await getAsset(orgId, asset.id, skipCache: true);
      if(realAsset != null) {
        return realAsset;
      }
      return asset;
    }
    return null;
  }

  Future<Asset?> updateAsset(String orgId, String assetId,
      {String? modelId, String? serialNumber, String? roomId}) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    var req = UpdateAssetRequest(modelId, roomId, serialNumber);
    if (req.isEmpty) {
      return null;
    }
    final response = await http.patch(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(req.toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var asset = Asset.fromJson(jsonDecode(response.body));
      _cache.write(key: asset.id, value: asset, lifetime: Duration(minutes: 5));
      return asset;
    }
    return null;
  }

  Future<AssetTag?> createAssetBarcode(
      String orgId, String assetId, String tagId) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId/barcodes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(CreateBarcodeRequest(tagId).toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _cache.write(key: '_tag_${orgId}_${tagId}', value: assetId, lifetime: Duration(minutes: 15));
      return AssetTag.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> deleteAssetBarcode(
      String orgId, String assetId, String barcodeId, String tagId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId/barcodes/$barcodeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if(response.statusCode >= 200 && response.statusCode < 300) {
      _cache.invalidate(key: '_tag_${orgId}_${tagId}');
      return true;
    }
    return false;
  }

  Future<bool> deleteAsset(String orgId, String assetId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if(response.statusCode >= 200 && response.statusCode < 300) {
      _cache.invalidate(key: assetId);
      return true;
    }
    return false;
  }
}
