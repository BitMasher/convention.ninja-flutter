// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetTag _$AssetTagFromJson(Map<String, dynamic> json) => AssetTag(
      json['id'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
      json['tagId'] as String,
      json['assetId'] as String,
      json['organizationId'] as String,
    );

Map<String, dynamic> _$AssetTagToJson(AssetTag instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tagId': instance.tagId,
      'assetId': instance.assetId,
      'organizationId': instance.organizationId,
    };
