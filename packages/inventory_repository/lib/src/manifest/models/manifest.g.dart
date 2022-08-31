// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Manifest _$ManifestFromJson(Map<String, dynamic> json) => Manifest(
      json['id'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
      json['organizationId'] as String,
      Manifest._nullStringParser(json['locationId'] as Map<String, dynamic>),
      ExternalParty.nullParser(
          json['responsibleExternalParty'] as Map<String, dynamic>),
      Manifest._nullTimeParser(json['shipDate'] as Map<String, dynamic>),
      (json['entries'] as List<dynamic>?)
              ?.map((e) => ManifestEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ManifestToJson(Manifest instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'organizationId': instance.organizationId,
      'locationId': instance.roomId,
      'responsibleExternalParty': instance.responsibleExternalParty,
      'shipDate': instance.shipDate?.toIso8601String(),
      'entries': instance.entries,
    };
