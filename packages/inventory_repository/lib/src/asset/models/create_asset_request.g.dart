// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_asset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAssetRequest _$CreateAssetRequestFromJson(Map<String, dynamic> json) =>
    CreateAssetRequest(
      json['serialNumber'] as String?,
      json['modelId'] as String,
      (json['assetTags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateAssetRequestToJson(CreateAssetRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('serialNumber', instance.serialNumber);
  val['modelId'] = instance.modelId;
  val['assetTags'] = instance.assetTags;
  return val;
}
