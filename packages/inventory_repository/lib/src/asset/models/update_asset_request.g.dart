// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_asset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAssetRequest _$UpdateAssetRequestFromJson(Map<String, dynamic> json) =>
    UpdateAssetRequest(
      json['modelId'] as String?,
      json['roomId'] as String?,
      json['serialNumber'] as String?,
    );

Map<String, dynamic> _$UpdateAssetRequestToJson(UpdateAssetRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('modelId', instance.modelId);
  writeNotNull('roomId', instance.roomId);
  writeNotNull('serialNumber', instance.serialNumber);
  return val;
}
