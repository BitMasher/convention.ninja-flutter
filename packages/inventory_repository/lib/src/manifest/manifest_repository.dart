import 'package:authentication_repository/authentication_repository.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_repository/src/manifest/models/models.dart';
import 'dart:convert';

class ManifestRepository {
  ManifestRepository({required authRepo}) : this._authRepo = authRepo;

  AuthenticationRepository _authRepo;

  Future<List<Manifest>> getManifests(String orgId) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/manifests'),
        headers: {
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var arr = jsonDecode(response.body);
      if (arr is List<dynamic>) {
        var ret = <Manifest>[];
        for (var value in arr) {
          ret.add(Manifest.fromJson(value));
        }
        return ret;
      }
    }
    return [];
  }

  Future<Manifest?> createManifest(String orgId) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/manifests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Manifest.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Manifest?> updateManifest(String orgId, String manifestId,
      String location, String responsibleParty, String extra) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.put(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(UpdateManifestRequest(
                location, ExternalParty(responsibleParty, extra))
            .toJson()));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Manifest.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> deleteManifest(String orgId, String manifestId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId'),
        headers: {
          'Authorization': 'Bearer $token',
        });
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<Manifest?> getManifest(String orgId, String manifestId) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId'),
        headers: {
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Manifest.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<ManifestEntry>> getManifestEntries(
      String orgId, String manifestId) async {
    if (_authRepo.currentUser == User.empty) {
      return [];
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.get(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId/entries'),
        headers: {
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var j = jsonDecode(response.body);
      var ret = <ManifestEntry>[];
      if (j is List<dynamic>) {
        for (var val in j) {
          ret.add(ManifestEntry.fromJson(val));
        }
        return ret;
      }
    }
    return [];
  }

  Future<ManifestEntry?> addManifestEntry(
      String orgId, String manifestId, String assetId) async {
    if (_authRepo.currentUser == User.empty) {
      return null;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId/entries'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(AddManifestEntryRequest(assetId)));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ManifestEntry.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> deleteManifestEntry(
      String orgId, String manifestId, String entryId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId/entries/$entryId'),
        headers: {
          'Authorization': 'Bearer $token',
        });
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> shipManifest(String orgId, String manifestId) async {
    if (_authRepo.currentUser == User.empty) {
      return false;
    }
    var token = await _authRepo.currentUser.idToken;
    final response = await http.post(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manifests/$manifestId/ship'
        ),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
