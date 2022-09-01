
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../model/models/model.dart';
import 'asset_tag.dart';

part 'asset.g.dart';

@JsonSerializable()
class Asset extends Equatable {
  Asset(this.id, this.createdAt, this.updatedAt, this.organizationId, this.modelId, this.model, this.serialNumber, this.roomId, this.assetTags);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String organizationId;
  final String modelId;
  final Model? model;
  final String serialNumber;
  @JsonKey(fromJson: _nullString)
  final String roomId;
  @JsonKey(defaultValue: [])
  final List<AssetTag> assetTags;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
  Map<String, dynamic> toJson() => _$AssetToJson(this);

  @override
  List<Object> get props => [id, organizationId, modelId, serialNumber, roomId, assetTags];

  @override
  String toString() {
    return '$id\n$roomId\n${model?.toString()}\n${assetTags.map((t)=>t.tagId).join(',')}';
  }

  static String _nullString(Map<String, dynamic> json) => json['Valid'] ? json['String'] : '';
}