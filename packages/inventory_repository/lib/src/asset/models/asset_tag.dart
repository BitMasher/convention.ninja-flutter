
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_tag.g.dart';

@JsonSerializable()
class AssetTag extends Equatable {
  AssetTag(this.id, this.createdAt, this.updatedAt, this.tagId, this.assetId, this.organizationId);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String tagId;
  final String assetId;
  final String organizationId;

  factory AssetTag.fromJson(Map<String, dynamic> json) => _$AssetTagFromJson(json);
  Map<String, dynamic> toJson() => _$AssetTagToJson(this);

  @override
  List<Object> get props => [id, tagId, assetId, organizationId];
}