import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'external_party.dart';
import 'manifest_entry.dart';

part 'manifest.g.dart';

@JsonSerializable()
class Manifest extends Equatable {
  Manifest(this.id, this.createdAt, this.updatedAt, this.organizationId,
      this.roomId, this.responsibleExternalParty, this.shipDate, this.entries);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String organizationId;
  @JsonKey(fromJson: _nullStringParser, name: 'locationId')
  final String? roomId;
  @JsonKey(fromJson: ExternalParty.nullParser)
  final ExternalParty? responsibleExternalParty;
  @JsonKey(fromJson: _nullTimeParser)
  final DateTime? shipDate;
  @JsonKey(defaultValue: [])
  final List<ManifestEntry> entries;

  @override
  List<Object?> get props =>
      [id, organizationId, roomId, responsibleExternalParty, shipDate, entries];

  factory Manifest.fromJson(Map<String, dynamic> json) =>
      _$ManifestFromJson(json);

  Map<String, dynamic> toJson() => _$ManifestToJson(this);

  static DateTime? _nullTimeParser(Map<String, dynamic> json) {
    return json['Valid'] ? DateTime.parse(json['Time']) : null;
  }

  static String? _nullStringParser(Map<String, dynamic> json) {
    return json['Valid'] ? json['String'] : null;
  }
}
