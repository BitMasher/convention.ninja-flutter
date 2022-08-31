
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../asset/models/asset.dart';

part 'manifest_entry.g.dart';

@JsonSerializable()
class ManifestEntry extends Equatable {
  ManifestEntry(this.id, this.createdAt, this.updatedAt, this.organizationId, this.manifestId, this.assetId, this.asset);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String organizationId;
  final String manifestId;
  final String assetId;
  final Asset? asset;

  factory ManifestEntry.fromJson(Map<String, dynamic> json) => _$ManifestEntryFromJson(json);
  Map<String, dynamic> toJson() => _$ManifestEntryToJson(this);

  @override
  List<Object> get props => [id, organizationId, manifestId, assetId];
}