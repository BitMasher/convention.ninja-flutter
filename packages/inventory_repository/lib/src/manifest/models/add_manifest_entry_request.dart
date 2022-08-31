import 'package:json_annotation/json_annotation.dart';

part 'add_manifest_entry_request.g.dart';

@JsonSerializable()
class AddManifestEntryRequest {
  AddManifestEntryRequest(this.assetId);

  String assetId;

  Map<String, dynamic> toJson() => _$AddManifestEntryRequestToJson(this);
}