// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManifestEntry _$ManifestEntryFromJson(Map<String, dynamic> json) =>
    ManifestEntry(
      json['id'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
      json['organizationId'] as String,
      json['manifestId'] as String,
      json['assetId'] as String,
      json['asset'] == null
          ? null
          : Asset.fromJson(json['asset'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ManifestEntryToJson(ManifestEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'organizationId': instance.organizationId,
      'manifestId': instance.manifestId,
      'assetId': instance.assetId,
      'asset': instance.asset,
    };
