// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      json['id'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
      json['name'] as String,
      json['organizationId'] as String,
      json['manufacturerId'] as String,
      json['categoryId'] as String,
      json['manufacturer'] == null
          ? null
          : Manufacturer.fromJson(json['manufacturer'] as Map<String, dynamic>),
      json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'organizationId': instance.organizationId,
      'manufacturerId': instance.manufacturerId,
      'categoryId': instance.categoryId,
      'manufacturer': instance.manufacturer,
      'category': instance.category,
    };
