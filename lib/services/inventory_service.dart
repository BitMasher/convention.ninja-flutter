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

class Manufacturer {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String organizationId;

  const Manufacturer(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.name,
      required this.organizationId,
      this.deletedAt});

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
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

class Model {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String organizationId;
  final String manufacturerId;
  final Manufacturer? manufacturer;
  final String categoryId;
  final Category? category;

  const Model(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.name,
      required this.organizationId,
      required this.categoryId,
      required this.manufacturerId,
      this.category,
      this.manufacturer,
      this.deletedAt});

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        deletedAt: json.containsKey('deletedAt') &&
                json['deletedAt'] != null &&
                json['deletedAt']['Valid']
            ? DateTime.parse(json['deletedAt'])
            : null,
        name: json['name'],
        organizationId: json['organizationId'],
        categoryId: json['categoryId'],
        manufacturerId: json['manufacturerId'],
        category: json.containsKey('category')
            ? Category.fromJson(json['category'])
            : null,
        manufacturer: json.containsKey('manufacturer')
            ? Manufacturer.fromJson(json['manufacturer'])
            : null);
  }
}

class AssetTag {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String tagId;
  final String assetId;
  final String organizationId;

  const AssetTag(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.tagId,
      required this.assetId,
      required this.organizationId,
      this.deletedAt});

  factory AssetTag.fromJson(Map<String, dynamic> json) {
    return AssetTag(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json.containsKey('deletedAt') &&
              json['deletedAt'] != null &&
              json['deletedAt']['Valid']
          ? DateTime.parse(json['deletedAt'])
          : null,
      tagId: json['tagId'],
      assetId: json['assetId'],
      organizationId: json['organizationId'],
    );
  }
}

class Asset {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String organizationId;
  final String modelId;
  final Model? model;
  final String? serialNumber;
  final String roomId;
  final List<AssetTag> assetTags;

  const Asset(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.organizationId,
      required this.modelId,
      required this.roomId,
      this.serialNumber,
      this.assetTags = const [],
      this.model,
      this.deletedAt});

  factory Asset.fromJson(Map<String, dynamic> json) {
    List<AssetTag> tags = [];
    if (json['assetTags'] is List<dynamic>) {
      tags = (json['assetTags'] as List<dynamic>)
          .map((e) => AssetTag.fromJson(e))
          .toList();
    }
    return Asset(
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        deletedAt: json.containsKey('deletedAt') &&
                json['deletedAt'] != null &&
                json['deletedAt']['Valid']
            ? DateTime.parse(json['deletedAt'])
            : null,
        organizationId: json['organizationId'],
        modelId: json['modelId'],
        assetTags: tags,
        roomId: json['roomId'],
        model:
            json.containsKey('model') ? Model.fromJson(json['model']) : null);
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

  static Future<Category?> createCategory(String orgId, String name) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'name': name}));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Category.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<Category?> updateCategory(
      String orgId, String categoryId, String name) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.put(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'name': name}));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Category.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<bool> deleteCategory(String orgId, String categoryId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    return false;
  }

  static Future<List<Manufacturer>> getManufacturers(String orgId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
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
          ret.add(Manufacturer.fromJson(value));
        }
        return ret;
      }
    }
    return [];
  }

  static Future<Manufacturer?> createManufacturer(
      String orgId, String name) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/manufacturers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'name': name}));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Manufacturer.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<Manufacturer?> updateManufacturer(
      String orgId, String manufacturerId, String name) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.put(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manufacturers/$manufacturerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'name': name}));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Manufacturer.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<bool> deleteManufacturer(
      String orgId, String manufacturerId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/manufacturers/$manufacturerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    return false;
  }

  static Future<List<Model>> getModels(String orgId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
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
          ret.add(Model.fromJson(value));
        }
        return ret;
      }
    }
    return [];
  }

  static Future<Model?> createModel(String orgId, String name,
      String categoryId, String manufacturerId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/models'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'categoryId': categoryId,
          'manufacturerId': manufacturerId
        }));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Model.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<Model?> updateModel(String orgId, String modelId,
      {String? name, String? categoryId, String? manufacturerId}) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    var payload = <String, String>{};
    if (name != null && name.isNotEmpty) {
      payload['name'] = name;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      payload['categoryId'] = categoryId;
    }
    if (manufacturerId != null && manufacturerId.isNotEmpty) {
      payload['manufacturerId'] = manufacturerId;
    }
    if (payload.keys.isEmpty) {
      return null;
    }
    final response = await http.patch(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/models/$modelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Model.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<bool> deleteModel(String orgId, String modelId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/models/$modelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    return false;
  }

  static Future<List<Asset>> getAssets(String orgId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
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
          ret.add(Asset.fromJson(value));
        }
        return ret;
      }
    }
    return [];
  }

  static Future<Asset?> createAsset(String orgId, String modelId,
      String serialNumber, List<String> tags) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.post(
        Uri.parse('//convention.ninja/api/orgs/$orgId/inventory/assets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'serialNumber': serialNumber,
          'modelId': modelId,
          'assetTags': tags,
        }));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Asset.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<Asset?> updateAsset(String orgId, String assetId,
      {String? modelId, String? serialNumber, String? roomId}) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    var payload = <String, String>{};
    if (modelId != null && modelId.isNotEmpty) {
      payload['modelId'] = modelId;
    }
    if (roomId != null && roomId.isNotEmpty) {
      payload['roomId'] = roomId;
    }
    if (serialNumber != null && serialNumber.isNotEmpty) {
      payload['serialNumber'] = serialNumber;
    }
    if (payload.keys.isEmpty) {
      return null;
    }
    final response = await http.patch(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Asset.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<AssetTag?> createAssetBarcode(
      String orgId, String assetId, String tagId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.post(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId/barcodes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{tagId: tagId}));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AssetTag.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<bool> deleteAssetBarcode(
      String orgId, String assetId, String barcodeId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId/barcodes/$barcodeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    return false;
  }

  static Future<bool> deleteAsset(String orgId, String assetId) async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final response = await http.delete(
        Uri.parse(
            '//convention.ninja/api/orgs/$orgId/inventory/assets/$assetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    return false;
  }
}
