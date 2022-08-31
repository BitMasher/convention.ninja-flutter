// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) => Asset(
      json['id'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
      json['organizationId'] as String,
      json['modelId'] as String,
      json['model'] == null
          ? null
          : Model.fromJson(json['model'] as Map<String, dynamic>),
      json['serialNumber'] as String,
      Asset._nullString(json['roomId'] as Map<String, dynamic>),
      (json['assetTags'] as List<dynamic>?)
              ?.map((e) => AssetTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'organizationId': instance.organizationId,
      'modelId': instance.modelId,
      'model': instance.model,
      'serialNumber': instance.serialNumber,
      'roomId': instance.roomId,
      'assetTags': instance.assetTags,
    };
