import 'package:json_annotation/json_annotation.dart';

part 'create_asset_request.g.dart';

@JsonSerializable()
class CreateAssetRequest {
  CreateAssetRequest(this.serialNumber, this.modelId, this.assetTags);

  @JsonKey(includeIfNull: false)
  String? serialNumber;
  String modelId;
  List<String> assetTags;

  Map<String, dynamic> toJson() => _$CreateAssetRequestToJson(this);
}
