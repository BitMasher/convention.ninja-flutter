// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_model_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateModelRequest _$CreateModelRequestFromJson(Map<String, dynamic> json) =>
    CreateModelRequest(
      json['name'] as String,
      json['categoryId'] as String,
      json['manufacturerId'] as String,
    );

Map<String, dynamic> _$CreateModelRequestToJson(CreateModelRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'categoryId': instance.categoryId,
      'manufacturerId': instance.manufacturerId,
    };
