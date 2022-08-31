// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_model_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateModelRequest _$UpdateModelRequestFromJson(Map<String, dynamic> json) =>
    UpdateModelRequest(
      json['name'] as String?,
      json['categoryId'] as String?,
      json['manufacturerId'] as String?,
    );

Map<String, dynamic> _$UpdateModelRequestToJson(UpdateModelRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('categoryId', instance.categoryId);
  writeNotNull('manufacturerId', instance.manufacturerId);
  return val;
}
