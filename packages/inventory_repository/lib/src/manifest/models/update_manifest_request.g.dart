// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_manifest_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateManifestRequest _$UpdateManifestRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateManifestRequest(
      json['roomId'] as String,
      ExternalParty.fromJson(
          json['responsibleExternalParty'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateManifestRequestToJson(
        UpdateManifestRequest instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'responsibleExternalParty': instance.responsibleExternalParty,
    };
